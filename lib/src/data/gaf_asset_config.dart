part of stagexl_gaf;

class GAFAssetConfig {

  static final int MAX_VERSION = 5;

  String _id;
  int _compression;
  int _versionMajor;
  int _versionMinor;
  int _fileLength;
  List<num> _displayScaleValues;
  List<num> _contentScaleValues;
  num _defaultDisplayScale;
  num _defaultContentScale;

  CStage _stageConfig;

  List<GAFTimelineConfig> _timelines;
  List<CTextureAtlas> _allTextureAtlases;
  List<CSound> _sounds;

  GAFAssetConfig(String id) {
    _id = id;
    _displayScaleValues = new List<num>();
    _contentScaleValues = new List<num>();
    _timelines = new List<GAFTimelineConfig>();
    _allTextureAtlases = new List<CTextureAtlas>();
  }

  void addSound(CSound soundData) {
    _sounds ??= new List<CSound>();
    _sounds.add(soundData);
  }

  int get compression => _compression;

  set compression(int value) {
    _compression = value;
  }

  int get versionMajor => _versionMajor;

  set versionMajor(int value) {
    _versionMajor = value;
  }

  int get versionMinor => _versionMinor;

  set versionMinor(int value) {
    _versionMinor = value;
  }

  int get fileLength => _fileLength;

  set fileLength(int value) {
    _fileLength = value;
  }

  List<num> get displayScaleValues => _displayScaleValues;

  List<num> get contentScaleValues => _contentScaleValues;

  num get defaultDisplayScale => _defaultDisplayScale;

  set defaultDisplayScale(num value) {
    _defaultDisplayScale = value;
  }

  num get defaultContentScale => _defaultContentScale;

  set defaultContentScale(num value) {
    _defaultContentScale = value;
  }

  List<GAFTimelineConfig> get timelines => _timelines;

  List<CTextureAtlas> get allTextureAtlases => _allTextureAtlases;

  CStage get stageConfig => _stageConfig;

  void set stageConfig(CStage value) {
    _stageConfig = value;
  }

  String get id => _id;

  List<CSound> get sounds => _sounds;

}
