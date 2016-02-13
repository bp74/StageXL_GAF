part of stagexl_gaf;

class GAFTimelineConfig {

  String _version;
  CStage _stageConfig;

  int _id;
  String _assetID;

  CAnimationFrames _animationFrames;
  CAnimationObjects _animationObjects;
  CAnimationSequences _animationSequences;
  CTextFieldObjects _textFields;

  Map<int, String> _namedParts;
  String _linkage;

  List<String> _warnings;
  int _framesCount = 0;
  Rectangle _bounds;
  Point _pivot;
  Map _sounds;

  //--------------------------------------------------------------------------

  GAFTimelineConfig(String version) {
    _version = version;
    _animationFrames = new CAnimationFrames();
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

  void addSound(Map data, int frame) {
    var soundID = data["id"];
    var action = data["action"];
    var repeatCount = data["repeat"] ?? 1;
    var linkage = data["linkage"];
    _sounds[frame] = new CFrameSound(soundID, action, repeatCount, linkage);
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

  int getNamedPartID(String name) {
    for (int id in _namedParts.keys) {
      if (_namedParts[id] == name) return id;
    }
    return null;
  }

  //--------------------------------------------------------------------------

  CAnimationObjects get animationObjects => _animationObjects;

  set animationObjects(CAnimationObjects animationObjects) {
    _animationObjects = animationObjects;
  }

  CAnimationFrames get animationFrames => _animationFrames;

  set animationFrames(CAnimationFrames animationConfigFrames) {
    _animationFrames = animationConfigFrames;
  }

  CAnimationSequences get animationSequences => this._animationSequences;

  set animationSequences(CAnimationSequences animationSequences) {
    _animationSequences = animationSequences;
  }

  CTextFieldObjects get textFields => _textFields;

  set textFields(CTextFieldObjects textFields) {
    _textFields = textFields;
  }

  String get version => _version;

  List<String> get warnings => _warnings;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get assetID => _assetID;

  set assetID(String value) {
    _assetID = value;
  }

  Map<int, String> get namedParts => _namedParts;

  set namedParts(Map<int, String> value) {
    _namedParts = value;
  }

  String get linkage => _linkage;

  void set linkage(String value) {
    _linkage = value;
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

}
