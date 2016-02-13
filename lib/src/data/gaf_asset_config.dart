part of stagexl_gaf;

class GAFAssetConfig {

  static final int MAX_VERSION = 5;

  final String id;
  final CStage stageConfig = new CStage();

  final List<num> displayScaleValues = new List<num>();
  final List<num> contentScaleValues = new List<num>();
  final List<GAFTimelineConfig> timelines = new List<GAFTimelineConfig>();
  final List<CTextureAtlas> textureAtlases = new List<CTextureAtlas>();
  final List<CSound> sounds = new List<CSound>();

  int compression = 0;
  int versionMajor = 0;
  int versionMinor = 0;
  int fileLength = 0;
  num defaultDisplayScale = 1.0;
  num defaultContentScale = 1.0;

  GAFAssetConfig(this.id);

}
