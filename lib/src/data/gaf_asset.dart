part of stagexl_gaf;

class GAFAsset {

  final GAFAssetConfig config;
  final List<GAFTimeline> _timelines;
  final List<GAFTextureAtlas> _textureAtlases;

  GAFAsset(this.config)
      : _timelines = new List<GAFTimeline>(),
        _textureAtlases = new List<GAFTextureAtlas>();

  //--------------------------------------------------------------------------

  static Future<GAFAsset> load(String gafUrl, [num scale, num contentScaleFactor]) async {

    var cutURL = gafUrl.split("?")[0];
    var lastIndex = cutURL.lastIndexOf("/");
    var folderURL = cutURL.substring(0, lastIndex + 1);

    int startIndex = gafUrl.lastIndexOf("/");
    int endIndex = gafUrl.lastIndexOf(".");
    startIndex = startIndex < 0 ? 0 : startIndex + 1;
    endIndex = endIndex < 0 ? 0x7fffffff : endIndex;

    // load gaf-binary and convert it into config classes

    var gafAssetID = gafUrl.substring(startIndex, endIndex);
    var gafRequest = HttpRequest.request(gafUrl, responseType: "arraybuffer");
    var gafBinary = (await gafRequest).response as ByteBuffer;

    var converter = new BinGAFAssetConfigConverter(gafAssetID, gafBinary);
    converter.defaultScale = scale;
    converter.defaultCSF = contentScaleFactor;
    converter.ignoreSounds = true; // TODO: should be configurable
    converter.convert();

    var gafAsset = new GAFAsset(converter.config);

    // load gaf timelines

    for (GAFTimelineConfig gafTimelineConfig in gafAsset.config.timelines) {
      var gafTimeline = new GAFTimeline(gafAsset, gafTimelineConfig);
      gafTimeline.scale = scale ?? gafAsset.config.defaultScale;
      gafTimeline.contentScaleFactor = contentScaleFactor ?? gafAsset.config.defaultContentScaleFactor;
      gafAsset._timelines.add(gafTimeline);
    }

    // load gaf texture atlases

    for (CTextureAtlasScale cScale in gafAsset.config.allTextureAtlases) {
      if (scale is num && scale != cScale.scale) continue;
      for (CTextureAtlasCSF cCSF in cScale.allContentScaleFactors) {
        if (contentScaleFactor is num && contentScaleFactor != cCSF.contentScaleFactor) continue;
        for (CTextureAtlasSource cSource in cCSF.sources) {
          var textureAtlasFormat = new GAFTextureAtlasFormat(cCSF, cSource);
          var textureAtlasLoader = new GAFTextureAtlasLoader(folderURL);
          print("load:  cSource: ${cSource.source}");
          var textureAtlas = await textureAtlasFormat.load(textureAtlasLoader);
          var gafTextureAtlas = new GAFTextureAtlas(cScale, cCSF, cSource, textureAtlas);
          gafAsset._textureAtlases.add(gafTextureAtlas);
        }
      }
    }

    // load gaf sounds

    /*
    List<CSound> csounds = converter.config.sounds;

    if (csounds != null && _ignoreSounds == false) {
      for (int i = 0; i < csounds.length; i++) {
        var soundUrl = folderURL + csounds[i].source;
        csounds[i].source = soundUrl;
        csounds[i].sound = await Sound.load(soundUrl);
        soundData.addSound(csounds[i], converter.config.id);
      }
    }
    */

    return gafAsset;
  }

  //--------------------------------------------------------------------------

  String get id => config.id;
  List<GAFTimeline> get timelines => _timelines;

  //--------------------------------------------------------------------------

  GAFTimeline getGAFTimelineByID(int id) {
    for (var timeline in _timelines) {
      if (timeline.id == id) return timeline;
    }
    return null;
  }

  GAFTimeline getGAFTimelineByLinkage(String linkage) {
    for (var timeline in _timelines) {
      if (timeline.linkage == linkage) return timeline;
    }
    return null;
  }

  /*
  GAFTextureAtlas getGAFTextureAtlas(num scale, num csf) {
    for (var textureAtlas in _textureAtlases) {
      if (textureAtlas.contentScaleFactor.scale != scale) continue;
      if (textureAtlas.contentScaleFactor.csf != csf) continue;
      return textureAtlas;
    }
    return null;
  }
  */

  GAFBitmapData getGAFBitmapData(num scale, num csf, int regionID) {
    for (var ta in _textureAtlases) {
      if (ta.scale.scale != scale) continue;
      if (ta.contentScaleFactor.contentScaleFactor != csf) continue;
      var bitmapData = ta.getBitmapData(regionID);
      if (bitmapData != null) return bitmapData;
    }
    return null;
  }

}
