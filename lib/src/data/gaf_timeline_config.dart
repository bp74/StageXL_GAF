part of stagexl_gaf;

class GAFTimelineConfig {

  final String version;
  final int id;
  final String assetID;

  final CAnimationFrames animationFrames = new CAnimationFrames();
  final CAnimationObjects animationObjects = new CAnimationObjects();
  final CAnimationSequences animationSequences = new CAnimationSequences();
  final CTextFieldObjects textFields = new CTextFieldObjects();
  final Map<int, String> namedParts = new Map<int, String>();
  final Map<int, CFrameSound> sounds = new Map<int, CFrameSound>();
  final List<String> warnings = new List<String>();

  String linkage = "";
  int framesCount = 0;
  Rectangle bounds = null;
  Point pivot = null;

  GAFTimelineConfig(this.id, this.assetID, this.version);

  //--------------------------------------------------------------------------

  void addSound(Map data, int frame) {
    var soundID = data["id"];
    var action = data["action"];
    var repeatCount = data["repeat"] ?? 1;
    var linkage = data["linkage"];
    sounds[frame] = new CFrameSound(soundID, action, repeatCount, linkage);
  }

  CFrameSound getSound(int frame) {
    return sounds[frame];
  }

  void addWarning(String text) {
    if (text == null) return;
    if (warnings.indexOf(text) == -1) {
      print(text);
      warnings.add(text);
    }
  }

  int getNamedPartID(String name) {
    for (int id in namedParts.keys) {
      if (namedParts[id] == name) return id;
    }
    return null;
  }

}
