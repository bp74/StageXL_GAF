part of stagexl_gaf;

class GAFAsset {
  final GAFAssetConfig config;
  final num displayScale;
  final num contentScale;

  final List<GAFTimeline> timelines = <GAFTimeline>[];
  final List<GAFTextureAtlas> textureAtlases = <GAFTextureAtlas>[];
  final List<GAFSound> sounds = <GAFSound>[];

  GAFAsset._(this.config, this.displayScale, this.contentScale);

  //--------------------------------------------------------------------------

  static Future<GAFAsset> load(String gafUrl,
      [num displayScale, num contentScale]) async {
    var bundle = await GAFBundle.load([gafUrl]);
    var assetID = bundle.assetConfigs.first.id;
    return bundle.getAsset(assetID, displayScale, contentScale);
  }

  static Future<GAFAsset> loadZip(List<int> zip,
      [num displayScale, num contentScale]) async {
    var bundle = await GAFBundle.loadZip(zip);
    var assetID = bundle.assetConfigs.first.id;
    return bundle.getAsset(assetID, displayScale, contentScale);
  }

  static Future<GAFAsset> loadZipUrl(String zipUrl,
      [num displayScale, num contentScale]) async {
    var bundle = await GAFBundle.loadZipUrl(zipUrl);
    var assetID = bundle.assetConfigs.first.id;
    return bundle.getAsset(assetID, displayScale, contentScale);
  }

  //--------------------------------------------------------------------------

  String get id => config.id;

  //--------------------------------------------------------------------------

  GAFTimeline getGAFTimelineByID(int id) {
    for (var timeline in timelines) {
      if (timeline.id == id) return timeline;
    }
    return null;
  }

  GAFTimeline getGAFTimelineByLinkage(String linkage) {
    for (var timeline in timelines) {
      if (timeline.linkage == linkage) return timeline;
    }
    return null;
  }

  GAFBitmapData getGAFBitmapDataByID(int id) {
    for (var ta in textureAtlases) {
      var gafBitmapData = ta.gafBitmapDatas[id];
      if (gafBitmapData != null) return gafBitmapData;
    }
    return null;
  }

  GAFBitmapData getBitmapDataByLinkage(String linkage) {
    for (var ta in textureAtlases) {
      for (var element in ta.config.elements) {
        if (element.linkage != linkage) continue;
        var gafBitmapData = ta.gafBitmapDatas[element.id];
        if (gafBitmapData != null) return gafBitmapData;
      }
    }
    return null;
  }

  GAFSound getGAFSoundByID(int id) {
    for (var sound in sounds) {
      if (sound.config.id == id) return sound;
    }
    return null;
  }

  GAFSound getGAFSoundByLinkage(String linkage) {
    for (var sound in sounds) {
      if (sound.config.linkage == linkage) return sound;
    }
    return null;
  }
}
