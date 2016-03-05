part of slot_machine;

/// Created by Nazar on 27.11.2014.
///
/// This is the helper class for Slot Machine reel
///
///   /   \
///   | A |
///   |---|
///   | B |
///   |---|
///   | C |
///   \   /
///
///   http://gafmedia.com/

class SlotBar {

  final GAFMovieClip bar;

  final List<GAFMovieClip> _slots = new List<GAFMovieClip>(3);
  final math.Random _random = new math.Random();

  List<int> _spinResult;
  String _machineType;

  SlotBar(this.bar) {
    for (var i = 0; i < _slots.length; i++) {
      var name = "fruit${i + 1}";
      _slots[i] = bar.getChildByName(name);
    }
  }

  void playSequence(SequencePlaybackInfo sequence) {
    this.bar.loop = sequence.looped;
    this.bar.setSequence(sequence.name);
    if (sequence.name == "stop") showSpinResult();
  }

  void randomizeSlots(int maxTypes, String machineType) {
    for (var i = 0; i < _slots.length; i++) {
      var slotImagePos = _random.nextInt(maxTypes) + 1;
      var seqName = slotImagePos.toString() + "_" + machineType;
      _slots[i].setSequence(seqName, false);
    }
  }

  void setSpinResult(List<int> fruits, String machineType) {
    _spinResult = fruits;
    _machineType = machineType;
  }

  void showSpinResult() {
    for (var i = 0; i < _slots.length; i++) {
      var seqName = _spinResult[i].toString() + "_" + _machineType;
      _slots[i].setSequence(seqName, false);
    }
  }

  void switchSlotType(int maxSlots) {
    for (var i = 0; i < _slots.length; i++) {
      var curFrame = _slots[i].currentFrame - 1;
      var maxFrame = _slots[i].totalFrames;
      curFrame += maxSlots;
      if (curFrame >= maxFrame) curFrame = curFrame % maxSlots;
      _slots[i].gotoAndStop(curFrame + 1);
    }
  }
}

