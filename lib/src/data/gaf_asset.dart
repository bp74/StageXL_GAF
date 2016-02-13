part of stagexl_gaf;

class GAFAsset {

  final GAFAssetConfig config;
  final List<GAFTimeline> _timelines;
  final List<GAFTextureAtlas> _textureAtlases;

  GAFAsset(this.config)
      : _timelines = new List<GAFTimeline>(),
        _textureAtlases = new List<GAFTextureAtlas>();

  //--------------------------------------------------------------------------

  static Future<GAFAsset> load(String gafUrl, [num displayScale, num contentScale]) async {

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
    converter.defaultDisplayScale = displayScale;
    converter.defaultContentScale = contentScale;
    converter.ignoreSounds = true; // TODO: should be configurable
    converter.convert();

    var gafAsset = new GAFAsset(converter.config);

    // load gaf timelines

    for (GAFTimelineConfig gafTimelineConfig in gafAsset.config.timelines) {
      var gafTimeline = new GAFTimeline(gafAsset, gafTimelineConfig);
      gafTimeline.displayScale = displayScale ?? gafAsset.config.defaultDisplayScale;
      gafTimeline.contentScale = contentScale ?? gafAsset.config.defaultContentScale;
      gafAsset._timelines.add(gafTimeline);
    }

    // load gaf texture atlases

    for (CTextureAtlas ta in gafAsset.config.allTextureAtlases) {
      if (displayScale is num && displayScale != ta.displayScale) continue;
      for (CTextureAtlasContent taContent in ta.contents) {
        if (contentScale is num && contentScale != taContent.contentScale) continue;
        for (CTextureAtlasSource taSource in taContent.sources) {
          var gafTextureAtlas = new GAFTextureAtlas(ta, taContent, taSource);
          await gafTextureAtlas.load(folderURL);
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

  GAFBitmapData getGAFBitmapData(num displayScale, num contentScale, int regionID) {
    for (var ta in _textureAtlases) {
      if (ta.configScale.displayScale != displayScale) continue;
      if (ta.configScale.contentScale != contentScale) continue;
      var bitmapData = ta.getBitmapData(regionID);
      if (bitmapData != null) return bitmapData;
    }
    return null;
  }

}
