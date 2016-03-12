part of stagexl_gaf;

class GAFAsset {

  final GAFAssetConfig config;
  final List<GAFTimeline> timelines = new List<GAFTimeline>();
  final List<GAFTextureAtlas> textureAtlases = new List<GAFTextureAtlas>();
  //final List<GAFSound> sounds = new List<GAFSound>();

  final num displayScale;
  final num contentScale;

  GAFAsset._(this.config, this.displayScale, this.contentScale);

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

    displayScale = displayScale ?? gafAssetConfig.defaultDisplayScale;
    contentScale = contentScale ?? gafAssetConfig.defaultContentScale;
    var gafAsset = new GAFAsset._(gafAssetConfig, displayScale, contentScale);

    // load gaf timelines

    for (GAFTimelineConfig gafTimelineConfig in gafAssetConfig.timelines) {
      var gafTimeline = new GAFTimeline(gafAsset, gafTimelineConfig);
      gafAsset.timelines.add(gafTimeline);
    }

    // load gaf texture atlases

    for (CTextureAtlas ta in gafAssetConfig.textureAtlases) {
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

    for (CSound csound in gafAssetConfig.sounds) {
      //var sound = await Sound.load(folderURL + csound.source);
      //var gafSound = new GAFSound(csound, sound);
      //gafAsset.sounds.add(gafSound);
    }

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

  GAFBitmapData getGAFBitmapDataByID(int id) {
    for (var ta in this.textureAtlases) {
      var gafBitmapData = ta.gafBitmapDatas[id];
      if (gafBitmapData != null) return gafBitmapData;
    }
    return null;
  }

  GAFBitmapData getBitmapDataByName(String name) {
    for (var ta in this.textureAtlases) {
      for (var element in ta.config.elements) {
        if (element.linkage != name) continue;
        var gafBitmapData = ta.gafBitmapDatas[element.id];
        if (gafBitmapData != null) return gafBitmapData;
      }
    }
    return null;
  }

}
