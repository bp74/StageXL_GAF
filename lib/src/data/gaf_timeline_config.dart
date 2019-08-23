part of stagexl_gaf;

class GAFTimelineConfig {

  final int id;
  final String assetID;
  final String version;

  final List<CAnimationFrame> animationFrames = List<CAnimationFrame>();
  final List<CAnimationObject> animationObjects = List <CAnimationObject>();
  final List<CAnimationSequence> animationSequences = List<CAnimationSequence>();
  final List<CTextField> textFields = List<CTextField>();
  final Map<int, String> namedParts = Map<int, String>();
  final Map<int, CFrameSound> sounds = Map<int, CFrameSound>();

  String linkage = "";
  int framesCount = 0;
  Rectangle bounds;
  Point pivot;

  GAFTimelineConfig(this.id, this.assetID, this.version);

  //--------------------------------------------------------------------------

  CAnimationSequence getSequence(String sequenceID) {
    for (var sequence in animationSequences) {
      if (sequence.id == sequenceID) return sequence;
    }
    return null;
  }

  CAnimationSequence getSequenceByFrame(int frameNo) {
    for (var sequence in animationSequences) {
      if (sequence.isSequenceFrame(frameNo)) return sequence;
    }
    return null;
  }

  CAnimationSequence getSequenceByStartFrame(int frameNo) {
    for (var sequence in animationSequences) {
      if (sequence.startFrameNo == frameNo) return sequence;
    }
    return null;
  }

  CAnimationSequence getSequenceByEndFrame(int frameNo) {
    for (var sequence in animationSequences) {
      if (sequence.endFrameNo == frameNo) return sequence;
    }
    return null;
  }

  CTextField getTextField(int textFieldID) {
    for (var textField in textFields) {
      if (textField.id == textFieldID) return textField;
    }
    return null;
  }

  CFrameSound getSound(int frame) {
    return sounds[frame];
  }

  int getNamedPartID(String name) {
    for (int id in namedParts.keys) {
      if (namedParts[id] == name) return id;
    }
    return null;
  }

  void addSound(Map data, int frame) {
    var soundID = data["id"];
    var action = data["action"];
    var repeatCount = data["repeat"] ?? 1;
    var linkage = data["linkage"];
    sounds[frame] = CFrameSound(soundID, action, repeatCount, linkage);
  }

}
