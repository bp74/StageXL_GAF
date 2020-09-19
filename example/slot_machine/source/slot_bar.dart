part of slot_machine;

class SlotBar {
  final GAFMovieClip bar;
  final List<GAFMovieClip> _slots = List<GAFMovieClip>(3);
  final math.Random _random = math.Random();

  List<int> _spinResult;
  String _machineType;

  SlotBar(this.bar) {
    for (var i = 0; i < _slots.length; i++) {
      _slots[i] = bar.getChildByName('fruit${i + 1}');
    }
  }

  void playSequence(SequencePlaybackInfo sequence) {
    bar.loop = sequence.looped;
    bar.setSequence(sequence.name);
    if (sequence.name == 'stop') showSpinResult();
  }

  void randomizeSlots(int maxTypes, String machineType) {
    for (var slot in _slots) {
      var slotImagePos = _random.nextInt(maxTypes) + 1;
      var sequenceName = '${slotImagePos}_${machineType}';
      slot.setSequence(sequenceName, false);
    }
  }

  void setSpinResult(List<int> fruits, String machineType) {
    _spinResult = fruits;
    _machineType = machineType;
  }

  void showSpinResult() {
    for (var i = 0; i < _slots.length; i++) {
      var seqName = _spinResult[i].toString() + '_' + _machineType;
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
