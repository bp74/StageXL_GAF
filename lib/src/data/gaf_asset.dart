part of stagexl_gaf;

class GAFAsset {

  final GAFAssetConfig config;
  final List<GAFTimeline> timelines = new List<GAFTimeline>();
  final List<GAFTextureAtlas> textureAtlases = new List<GAFTextureAtlas>();

  GAFAsset(this.config);

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
    var gafConverter = new GAFAssetConfigConverter(gafAssetID, false, gafBinary);
    var gafAssetConfig = gafConverter.convert();
    var gafAsset = new GAFAsset(gafAssetConfig);

    displayScale = displayScale ?? gafAsset.config.defaultDisplayScale;
    contentScale = contentScale ?? gafAsset.config.defaultContentScale;

    // load gaf timelines

    for (GAFTimelineConfig gafTimelineConfig in gafAsset.config.timelines) {
      var gafTimeline = new GAFTimeline(gafAsset, gafTimelineConfig);
      gafTimeline.displayScale = displayScale;
      gafTimeline.contentScale = contentScale;
      gafAsset.timelines.add(gafTimeline);
    }

    // load gaf texture atlases

    for (CTextureAtlas ta in gafAsset.config.textureAtlases) {
      for (CTextureAtlasContent taContent in ta.contents) {
        if (taContent.displayScale != displayScale) continue;
        if (taContent.contentScale != contentScale) continue;
        for (CTextureAtlasSource taSource in taContent.sources) {
          var gafTextureAtlas = new GAFTextureAtlas(ta, taContent, taSource);
          await gafTextureAtlas.load(folderURL);
          gafAsset.textureAtlases.add(gafTextureAtlas);
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

  //--------------------------------------------------------------------------

  GAFTimeline getGAFTimelineByID(int id) {
    for (var timeline in this.timelines) {
      if (timeline.id == id) return timeline;
    }
    return null;
  }

  GAFTimeline getGAFTimelineByLinkage(String linkage) {
    for (var timeline in this.timelines) {
      if (timeline.linkage == linkage) return timeline;
    }
    return null;
  }

  GAFBitmapData getGAFBitmapData(num displayScale, num contentScale, int regionID) {
    for (var ta in this.textureAtlases) {
      if (ta.configContent.displayScale != displayScale) continue;
      if (ta.configContent.contentScale != contentScale) continue;
      var gafBitmapData = ta.gafBitmapDatas[regionID];
      if (gafBitmapData != null) return gafBitmapData;
    }
    return null;
  }

}
