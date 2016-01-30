part of stagexl_gaf;

class GAFTimelineConfig {

  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  String _version;
  CStage _stageConfig;

  String _id;
  String _assetID;

  List<CTextureAtlasScale> _allTextureAtlases;
  CTextureAtlasScale _textureAtlas;

  CAnimationFrames _animationConfigFrames;
  CAnimationObjects _animationObjects;
  CAnimationSequences _animationSequences;
  CTextFieldObjects _textFields;

  Map _namedParts;
  String _linkage;

  List<GAFDebugInformation> _debugRegions;

  List<String> _warnings;
  int _framesCount;
  Rectangle _bounds;
  Point _pivot;
  Map _sounds;
  bool _disposed;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  GAFTimelineConfig(String version) {
    _version = version;
    _animationConfigFrames = new CAnimationFrames();
    _animationObjects = new CAnimationObjects();
    _animationSequences = new CAnimationSequences();
    _textFields = new CTextFieldObjects();
    _sounds = new Map();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  void dispose() {
    _allTextureAtlases?.forEach((ta) => ta.dispose());
    _allTextureAtlases = null;
    _animationConfigFrames = null;
    _animationSequences = null;
    _animationObjects = null;
    _textureAtlas = null;
    _textFields = null;
    _namedParts = null;
    _warnings = null;
    _bounds = null;
    _sounds = null;
    _pivot = null;
    _disposed = true;
  }

  CTextureAtlasScale getTextureAtlasForScale(num scale) {
    for (CTextureAtlasScale cTextureAtlas in _allTextureAtlases) {
      if (MathUtility.equals(cTextureAtlas.scale, scale)) {
        return cTextureAtlas;
      }
    }

    return null;
  }

  void addSound(Object data, int frame) {
    _sounds[frame] = new CFrameSound(data);
  }

  CFrameSound getSound(int frame) {
    return _sounds[frame];
  }

  void addWarning(String text) {
    if (text == null) return;
    this._warnings ??= new List<String>();
    if (_warnings.indexOf(text) == -1) {
      print(text);
      _warnings.add(text);
    }
  }

  String getNamedPartID(String name) {
    for (String id in _namedParts) {
      if (_namedParts[id] == name) return id;
    }
    return null;
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  CTextureAtlasScale get textureAtlas => _textureAtlas;

  set textureAtlas(CTextureAtlasScale textureAtlas) {
    _textureAtlas = textureAtlas;
  }

  CAnimationObjects get animationObjects => _animationObjects;

  set animationObjects(CAnimationObjects animationObjects) {
    _animationObjects = animationObjects;
  }

  CAnimationFrames get animationConfigFrames => _animationConfigFrames;

  set animationConfigFrames(CAnimationFrames animationConfigFrames) {
    _animationConfigFrames = animationConfigFrames;
  }

  CAnimationSequences get animationSequences => this._animationSequences;

  set animationSequences(CAnimationSequences animationSequences) {
    _animationSequences = animationSequences;
  }

  CTextFieldObjects get textFields => _textFields;

  set textFields(CTextFieldObjects textFields) {
    _textFields = textFields;
  }

  List<CTextureAtlasScale> get allTextureAtlases => _allTextureAtlases;

  set allTextureAtlases(List<CTextureAtlasScale> allTextureAtlases) {
    _allTextureAtlases = allTextureAtlases;
  }

  String get version => _version;

  List<GAFDebugInformation> get debugRegions => _debugRegions;

  set debugRegions(List<GAFDebugInformation> debugRegions) {
    _debugRegions = debugRegions;
  }

  List<String> get warnings => _warnings;

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get assetID => _assetID;

  set assetID(String value) {
    _assetID = value;
  }

  Map get namedParts => _namedParts;

  set namedParts(Map value) {
    _namedParts = value;
  }

  String get linkage => _linkage;

  void set linkage(String value) {
    _linkage = value;
  }

  CStage get stageConfig => _stageConfig;

  set stageConfig(CStage stageConfig) {
    _stageConfig = stageConfig;
  }

  int get framesCount => _framesCount;

  set framesCount(int value) {
    _framesCount = value;
  }

  Rectangle get bounds => _bounds;

  set bounds(Rectangle value) {
    _bounds = value;
  }

  Point get pivot => _pivot;

  set pivot(Point value) {
    _pivot = value;
  }

  bool get disposed => _disposed;
}
