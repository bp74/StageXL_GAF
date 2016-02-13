part of stagexl_gaf;

class GAFAssetConfig {

  static final int MAX_VERSION = 5;

  final String id;
  final List<num> displayScaleValues;
  final List<num> contentScaleValues;
  final List<GAFTimelineConfig> timelines;
  final List<CTextureAtlas> textureAtlases;
  final List<CSound> sounds;

  int compression = 0;
  int versionMajor = 0;
  int versionMinor = 0;
  int fileLength = 0;
  num defaultDisplayScale = 1.0;
  num defaultContentScale = 1.0;

  CStage stageConfig = null;

  GAFAssetConfig(this.id)
      : this.displayScaleValues = new List<num>(),
        this.contentScaleValues = new List<num>(),
        this.timelines = new List<GAFTimelineConfig>(),
        this.textureAtlases = new List<CTextureAtlas>(),
        this.sounds = new List<CSound>();

}
