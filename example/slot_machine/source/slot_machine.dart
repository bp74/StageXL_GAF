part of slot_machine;

class SlotMachine extends GAFMovieClip {
  static const int MACHINE_STATE_INITIAL = 0;
  static const int MACHINE_STATE_ARM_TOUCHED = 1;
  static const int MACHINE_STATE_SPIN = 2;
  static const int MACHINE_STATE_SPIN_END = 3;
  static const int MACHINE_STATE_WIN = 4;
  static const int MACHINE_STATE_END = 5;
  static const int MACHINE_STATE_COUNT = 6;

  static const int PRIZE_NONE = 0;
  static const int PRIZE_C1K = 1;
  static const int PRIZE_C500K = 2;
  static const int PRIZE_C1000K = 3;
  static const int PRIZE_COUNT = 4;

  static const String REWARD_COINS = 'coins';
  static const String REWARD_CHIPS = 'chips';
  static const int FRUIT_COUNT = 5;
  static const num BAR_TIMEOUT = 0.2;

  GAFMovieClip _arm;
  GAFMovieClip _switchMachineButton;
  GAFMovieClip _flash;
  GAFMovieClip _winText;
  GAFMovieClip _winCoins;
  GAFMovieClip _winFrame;

  final List<SlotBar> _slotBars = List<SlotBar>(3);
  final List<GAFMovieClip> _centralCoins = List<GAFMovieClip>(3);
  final Juggler _juggler = Juggler();

  int _prize = 0;
  int _state = MACHINE_STATE_INITIAL;
  String _rewardType = REWARD_CHIPS;

  //---------------------------------------------------------------------------

  SlotMachine(GAFTimeline gafTimeline) : super(gafTimeline) {
    play(true);

    var obj = getChildByName('obj') as DisplayObjectContainer;

    // Here we get pointers to inner Gaf objects for quick access

    _arm = obj.getChildByName('arm');
    _flash = obj.getChildByName('white_exit');
    _winCoins = obj.getChildByName('wincoins');
    _winText = obj.getChildByName('wintext');
    _winFrame = obj.getChildByName('frame');

    _switchMachineButton = obj.getChildByName('swapBtn');
    _switchMachineButton.stop();
    _switchMachineButton.mouseChildren = false;

    // Play the "start" sequence once and then play the "spin" sequence.

    var spinningRays = obj.getChildByName('spinning_rays') as GAFMovieClip;
    spinningRays.setSequence('start');
    spinningRays.onSequenceEnd.first.then((e) {
      spinningRays.setSequence('spin', true);
    });

    for (var child in children) {
      if (child == _arm || child == _switchMachineButton) continue;
      if (child is! InteractiveObject) continue;
      InteractiveObject interactiveObject = child;
      interactiveObject.mouseEnabled = false;
    }

    for (var i = 0; i < _centralCoins.length; i++) {
      var prizeName = _getTextByPrize(i + 1);
      _centralCoins[i] = obj.getChildByName(prizeName);
    }

    for (var i = 0; i < _slotBars.length; i++) {
      // ignore: prefer_single_quotes
      var bar = obj.getChildByName("slot${i + 1}");
      _slotBars[i] = SlotBar(bar);
      _slotBars[i].randomizeSlots(FRUIT_COUNT, _rewardType);
    }

    _defaultPlacing();
  }

  //---------------------------------------------------------------------------

  GAFMovieClip get arm => _arm;
  GAFMovieClip get switchMachineBtn => _switchMachineButton;

  //---------------------------------------------------------------------------

  @override
  bool advanceTime(num time) {
    _juggler.advanceTime(time);
    return super.advanceTime(time);
  }

  void pullArm() {
    if (_state == MACHINE_STATE_INITIAL) _nextState();
  }

  void switchType() {
    if (_rewardType == REWARD_CHIPS) {
      _rewardType = REWARD_COINS;
    } else if (_rewardType == REWARD_COINS) {
      _rewardType = REWARD_CHIPS;
    }

    _state = (_state - 1) % MACHINE_STATE_COUNT;
    _nextState();
    _slotBars.forEach((sb) => sb.switchSlotType(FRUIT_COUNT));
  }

  //---------------------------------------------------------------------------

  void _defaultPlacing() {
    // Here we set default sequences if needed
    // Sequence names are used from flash labels
    _flash.gotoAndStop('whiteenter');
    _winFrame.setSequence('stop');
    _arm.setSequence('stop');
    _winCoins.visible = false;
    _winCoins.loop = false;
    _winText.setSequence('notwin', true);
    _centralCoins.forEach((cc) => cc.visible = false);
    _slotBars.forEach((sb) => sb.bar.setSequence('statics'));
  }

  void _nextState([_]) {
    _state = (_state + 1) % MACHINE_STATE_COUNT;

    if (_state == MACHINE_STATE_INITIAL) {
      _defaultPlacing();
    } else if (_state == MACHINE_STATE_ARM_TOUCHED) {
      _arm.setSequence('push');
      _arm.onSequenceEnd.first.then(_nextState);
    } else if (_state == MACHINE_STATE_SPIN) {
      _arm.setSequence('stop');
      _juggler.delay(3.0).then(_nextState);
      for (var i = 0; i < _slotBars.length; i++) {
        var seqName = 'rotation_' + _rewardType;
        var seq = SequencePlaybackInfo(seqName, true);
        var sb = _slotBars[i];
        _juggler.delay(BAR_TIMEOUT * i).then((f) => sb.playSequence(seq));
      }
    } else if (_state == MACHINE_STATE_SPIN_END) {
      _juggler.delay(BAR_TIMEOUT * 4).then(_nextState);
      _prize = (_prize + 1) % PRIZE_COUNT;
      var spinResult = _generateSpinResult(_prize);
      for (var i = 0; i < _slotBars.length; i++) {
        var slotBar = _slotBars[i];
        var seq = SequencePlaybackInfo('stop', false);
        slotBar.setSpinResult(spinResult[i], _rewardType);
        _juggler.delay(BAR_TIMEOUT * i).then((f) => slotBar.playSequence(seq));
      }
    } else if (_state == MACHINE_STATE_WIN) {
      _showPrize(_prize);
    } else if (_state == MACHINE_STATE_END) {
      _flash.play();
      _flash.onSequenceEnd.first.then(_nextState);
    }
  }

  /// Method returns machine spin result
  ///   4 3 1
  ///   2 2 2
  ///   1 1 5
  /// where numbers are fruit indexes

  List<List<int>> _generateSpinResult(int prize) {
    var result = List<List<int>>(3);
    var random = math.Random();
    var centralFruit = 0;

    for (var i = 0; i < 3; i++) {
      result[i] = List<int>(3);
      result[i][0] = random.nextInt(FRUIT_COUNT) + 1;
      result[i][2] = random.nextInt(FRUIT_COUNT) + 1;
    }

    if (prize == PRIZE_NONE) {
      centralFruit = random.nextInt(FRUIT_COUNT) + 1;
    } else if (prize == PRIZE_C1K) {
      centralFruit = random.nextInt(FRUIT_COUNT ~/ 2) + 1;
    } else if (prize == PRIZE_C500K) {
      centralFruit = random.nextInt(FRUIT_COUNT ~/ 2) + FRUIT_COUNT ~/ 2 + 1;
    } else if (prize == PRIZE_C1000K) {
      centralFruit = FRUIT_COUNT - 1;
    }

    if (prize == PRIZE_NONE) {
      result[0][1] = centralFruit;
      result[1][1] = centralFruit;
      result[2][1] = centralFruit;
      while (result[2][1] == result[1][1]) {
        // last fruit should be different
        result[2][1] = random.nextInt(FRUIT_COUNT) + 1;
      }
    } else {
      for (var i = 0; i < result.length; i++) {
        result[i][1] = centralFruit;
      }
    }

    return result;
  }

  /// Here we switching to win animation

  void _showPrize(int prize) {
    var coinsBottomState = _getTextByPrize(prize) + '_' + _rewardType;
    _winCoins.visible = true;
    _winCoins.gotoAndStop(coinsBottomState);

    if (prize == PRIZE_NONE) {
      _nextState();
      return;
    }

    _winFrame.setSequence('win', true);
    _winText.setSequence(_getTextByPrize(prize));

    var idx = prize - 1;
    _centralCoins[idx].visible = true;
    _centralCoins[idx].play(true);
    _centralCoins[idx].setSequence(_rewardType);
    _juggler.delay(2.0).then(_nextState);
  }

  String _getTextByPrize(int prize) {
    switch (prize) {
      case PRIZE_NONE:
        return 'notwin';
      case PRIZE_C1K:
        return 'win1k';
      case PRIZE_C500K:
        return 'win500k';
      case PRIZE_C1000K:
        return 'win1000k';
      default:
        return '';
    }
  }
}
