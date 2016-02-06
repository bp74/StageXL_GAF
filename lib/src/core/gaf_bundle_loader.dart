part of stagexl_gaf;

/// The GAFAssetConverter simply converts loaded GAF file into
/// [GAFTimeline] object that is used to create [GAFMovieClip] animation
/// display object ready to be used in starling display list. If GAF file is
/// created as Bundle it converts as [GAFBundle].
///
/// Here is the simple rules to understand what is [GAFTimeline], [GAFBundle]
/// and [GAFMovieClip]:
///
/// * [GAFBundle] is a storage for all [GAFTimeline]s.
/// * [GAFTimeline] is like a library symbol in Flash IDE.
/// * [GAFMovieClip] is like an instance of Flash [MovieClip].

class GAFBundleLoader {

  String _id;
  bool _ignoreSounds = false;

  /// Creates a new [GAFBundleLoader] instance.
  ///
  /// @param id The id of the converter.
  ///
  /// If it is not empty [GAFBundleLoader] sets the [name] of produced
  /// bundle equal to this id.

  GAFBundleLoader([String id = null]) {
    _id = id;
  }

  //--------------------------------------------------------------------------

  /// The id of the converter.
  /// If it is not empty [GAFBundleLoader] sets the [name] of produced
  /// bundle equal to this id.

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  bool get ignoreSounds => _ignoreSounds;

  set ignoreSounds(bool ignoreSounds) {
    _ignoreSounds = ignoreSounds;
  }
  //--------------------------------------------------------------------------

  /// Converts a GAF file into a [GAFTimeline] or [GAFBundle] depending on content.

  Future<GAFBundle> load(String gafUrl, [num defaultScale, num defaultContentScaleFactor]) async {

    GAFGFXData gfxData = new GAFGFXData();
    GAFSoundData soundData  = new GAFSoundData();

    GAFBundle gafBundle = new GAFBundle();
    gafBundle.name = id != null && id.length > 0 ? id : null;
    gafBundle.soundData = soundData;

    //--------------

    var request = await html.HttpRequest.request(gafUrl, responseType: "arraybuffer");
    ByteBuffer configSource = request.response;
    String gafAssetID = getAssetId(gafUrl);

    var converter = new BinGAFAssetConfigConverter(gafAssetID, configSource);
    converter.defaultScale = defaultScale;
    converter.defaultCSF = defaultContentScaleFactor;
    converter.ignoreSounds = _ignoreSounds;
    converter.convert();

    String folderURL = getFolderURL(gafUrl);
    GAFAssetConfig config = converter.config;
    String configID = gafUrl;

    //--------------

    GAFAsset gafAsset = new GAFAsset(config);
    gafBundle._addGAFAsset(gafAsset);

    for (GAFTimelineConfig config in config.timelines) {

      for (CTextureAtlasScale cScale in config.allTextureAtlases) {
        if (defaultScale is num && !_isEquivalent(defaultScale, cScale.scale)) continue;

        for (CTextureAtlasCSF cCSF in cScale.allContentScaleFactors) {
          if (defaultContentScaleFactor is num && !_isEquivalent(defaultContentScaleFactor, cCSF.csf)) continue;

          for (CTextureAtlasSource taSource in cCSF.sources) {
            if (taSource.source == "no_atlas") continue;
            var textureUrl = folderURL + taSource.source;
            var texture = await BitmapData.load(textureUrl);
            var taGFX = new TAGFXSourceBitmapData(texture, TAGFXBase.SOURCE_TYPE_BITMAP_DATA);
            gfxData.addTAGFX(cScale.scale, cCSF.csf, taSource.id, taGFX);
          }
        }
      }

      GAFTimeline gafTimeline = new GAFTimeline(config);
      gafTimeline.gafgfxData = gfxData;
      gafTimeline.gafSoundData = soundData;
      gafTimeline.gafAsset = gafAsset;
      gafAsset.addGAFTimeline(gafTimeline);
    }

    //--------------

    List<CSound> csounds = converter.config.sounds;

    if (csounds != null && _ignoreSounds == false) {
      for (int i = 0; i < csounds.length; i++) {
        var soundUrl = folderURL + csounds[i].source;
        csounds[i].source = soundUrl;
        csounds[i].sound = await Sound.load(soundUrl);
        soundData.addSound(csounds[i], converter.config.id);
      }
    }

    //--------------

    return gafBundle;
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  static String getFolderURL(String url) {
    String cutURL = url.split("?")[0];
    int lastIndex = cutURL.lastIndexOf("/");
    return cutURL.substring(0, lastIndex + 1);
  }

  String getAssetId(String configName) {
    int startIndex = configName.lastIndexOf("/");
    int endIndex = configName.lastIndexOf(".");
    startIndex = startIndex < 0 ? 0 : startIndex + 1;
    endIndex = endIndex < 0 ? 0x7fffffff : endIndex;
    return configName.substring(startIndex, endIndex);
  }

  //--------------------------------------------------------------------------

  bool _isEquivalent(num a, num b, [num epsilon=0.0001]) {
    return (a - epsilon < b) && (a + epsilon > b);
  }
}
