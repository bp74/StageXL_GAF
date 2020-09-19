part of stagexl_gaf;

class GAFAssetConfig {
  static final int MAX_VERSION = 5;

  final String id;
  final CStage stageConfig = CStage();

  final List<num> displayScaleValues = <num>[];
  final List<num> contentScaleValues = <num>[];
  final List<GAFTimelineConfig> timelines = <GAFTimelineConfig>[];
  final List<CTextureAtlas> textureAtlases = <CTextureAtlas>[];
  final List<CSound> sounds = <CSound>[];

  int compression = 0;
  int versionMajor = 0;
  int versionMinor = 0;
  int fileLength = 0;
  num defaultDisplayScale = 1.0;
  num defaultContentScale = 1.0;

  GAFAssetConfig(this.id);
}
