part of stagexl_gaf;

class GAFAssetConfig {

  static final int MAX_VERSION = 5;

  String _id;
  int _compression;
  int _versionMajor;
  int _versionMinor;
  int _fileLength;
  List<num> _scaleValues;
  List<num> _csfValues;
  num _defaultScale;
  num _defaultContentScaleFactor;

  CStage _stageConfig;

  List<GAFTimelineConfig> _timelines;
  List<CTextureAtlasScale> _allTextureAtlases;
  List<CSound> _sounds;

  GAFAssetConfig(String id) {
    _id = id;
    _scaleValues = new List<num>();
    _csfValues = new List<num>();
    _timelines = new List<GAFTimelineConfig>();
    _allTextureAtlases = new List<CTextureAtlasScale>();
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

  List<num> get scaleValues => _scaleValues;

  List<num> get csfValues => _csfValues;

  num get defaultScale => _defaultScale;

  set defaultScale(num value) {
    _defaultScale = value;
  }

  num get defaultContentScaleFactor => _defaultContentScaleFactor;

  set defaultContentScaleFactor(num value) {
    _defaultContentScaleFactor = value;
  }

  List<GAFTimelineConfig> get timelines => _timelines;

  List<CTextureAtlasScale> get allTextureAtlases => _allTextureAtlases;

  CStage get stageConfig => _stageConfig;

  void set stageConfig(CStage value) {
    _stageConfig = value;
  }

  String get id => _id;

  List<CSound> get sounds => _sounds;

}
