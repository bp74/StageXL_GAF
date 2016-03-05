part of slot_machine;

/// Created by Nazar on 27.11.2014.

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

  static const String _REWARD_COINS = "coins";
  static const String _REWARD_CHIPS = "chips";
  static const int _FRUIT_COUNT = 5;
  static const num _BAR_TIMEOUT = 0.2;

  GAFMovieClip _arm;
  GAFMovieClip _switchMachineBtn;
  GAFMovieClip _whiteBG;
  GAFMovieClip _rewardText;
  GAFMovieClip _bottomCoins;
  GAFMovieClip _winFrame;
  GAFMovieClip _spinningRays;
  List<SlotBar> _slotBars = new List<SlotBar>(3);
  List<GAFMovieClip> _centralCoins = new List<GAFMovieClip>(3);
  Juggler _juggler = new Juggler();

  int _state = MACHINE_STATE_INITIAL;
  String _rewardType = _REWARD_CHIPS;
  int _prize = 0;
  // Timer _timer: Timer;

  SlotMachine(GAFTimeline gafTimeline) : super(gafTimeline) {

    this.play(true);

    // Here we get pointers to inner Gaf objects for quick access
    var obj = this.getChildByName("obj");
    _arm = obj.getChildByName("arm");
    _switchMachineBtn = obj.getChildByName("swapBtn");
    _switchMachineBtn.stop();
    _switchMachineBtn.mouseChildren = false;
    _whiteBG = obj.getChildByName("white_exit");
    _bottomCoins = obj.getChildByName("wincoins");
    _rewardText = obj.getChildByName("wintext");
    _winFrame = obj.getChildByName("frame");
    _spinningRays = obj.getChildByName("spinning_rays");

    // Play the "start" sequence once and then play the "spin" sequence.
    _spinningRays.setSequence("start");
    _spinningRays.onSequenceEnd.first.then((e) {
      _spinningRays.setSequence("spin", true);
    });

    for(var child in this.children) {
      if (child == _arm || child == _switchMachineBtn) continue;
      if (child is! InteractiveObject) continue;
      InteractiveObject interactiveObject = child;
      interactiveObject.mouseEnabled = false;
    }

    for (int i = 0; i < _centralCoins.length; i++) {
      var prizeName = _getTextByPrize(i + 1);
      _centralCoins[i] = obj.getChildByName(prizeName);
    }

    for (int i = 0; i < _slotBars.length; i++) {
      var barName = "slot${i + 1}";
      var bar = obj.getChildByName(barName);
      _slotBars[i] = new SlotBar(bar);
      _slotBars[i].randomizeSlots(_FRUIT_COUNT, _rewardType);
    }

    _defaultPlacing();
  }

  //---------------------------------------------------------------------------

  GAFMovieClip get arm => _arm;
  GAFMovieClip get switchMachineBtn => _switchMachineBtn;

  //---------------------------------------------------------------------------

  void start() {
    if (_state == MACHINE_STATE_INITIAL) _nextState();
  }

  @override
  bool advanceTime(num time) {
    _juggler.advanceTime(time);
    return super.advanceTime(time);
  }

  void switchType() {
    if (_rewardType == _REWARD_CHIPS) {
      _rewardType = _REWARD_COINS;
    } else if (_rewardType == _REWARD_COINS) {
      _rewardType = _REWARD_CHIPS;
    }

    var state = _state - 1;
    if (state < 0) state = MACHINE_STATE_COUNT - 1;
    _state = state;
    _nextState();

    for (var i = 0; i < _slotBars.length; i++) {
      _slotBars[i].switchSlotType(_FRUIT_COUNT);
    }
  }

  //---------------------------------------------------------------------------

  // General callback for sequences
  // Used by Finite-state machine
  // see setAnimationStartedNextLoopDelegate and setAnimationFinishedPlayDelegate
  // for looped and non-looped sequences
  void _onFinishSequence(Event event) {
    _nextState();
  }

  void _defaultPlacing() {
    // Here we set default sequences if needed
    // Sequence names are used from flash labels
    _whiteBG.gotoAndStop("whiteenter");
    _winFrame.setSequence("stop");
    _arm.setSequence("stop");
    _bottomCoins.visible = false;
    _bottomCoins.loop = false;
    _rewardText.setSequence("notwin", true);

    for (int i = 0; i < _centralCoins.length; i++) {
      _centralCoins[i].visible = false;
    }
    for (int i = 0; i < _centralCoins.length; i++) {
      _slotBars[i].bar.setSequence("statics");
    }
  }

  /// This method describes Finite-state machine state switches in 2 cases:
  /// 1) specific sequence ended playing and callback called
  /// 2) by timer

  void _nextState() {

    _state = (_state + 1) % MACHINE_STATE_COUNT;
    _resetCallbacks();

    switch (_state) {

      case MACHINE_STATE_INITIAL:
        _defaultPlacing();
        break;

      case MACHINE_STATE_ARM_TOUCHED:
        _arm.setSequence("push");
        _arm.onSequenceEnd.listen(_onFinishSequence);
        break;

      case MACHINE_STATE_SPIN:
        _arm.setSequence("stop");
        _juggler.delayCall(_nextState, 3.0);
        for (int i = 0; i < _slotBars.length; i++) {
          var seqName = "rotation_" + _rewardType;
          var seq = new SequencePlaybackInfo(seqName, true);
          var sb = _slotBars[i];
          _juggler.delayCall(() => sb.playSequence(seq), _BAR_TIMEOUT * i);
        }
        break;

      case MACHINE_STATE_SPIN_END:
        _juggler.delayCall(_nextState, _BAR_TIMEOUT * 4.0);
        _generatePrize();
        List<List<int>> spinResult = _generateSpinResult(_prize);
        for (int i = 0; i < _slotBars.length; i++) {
          var seq = new SequencePlaybackInfo("stop", false);
          var sb = _slotBars[i];
          sb.setSpinResult(spinResult[i], _rewardType);
          _juggler.delayCall(() => sb.playSequence(seq), _BAR_TIMEOUT * i);
        }
        break;

      case MACHINE_STATE_WIN:
        _showPrize(_prize);
        break;

      case MACHINE_STATE_END:
        _whiteBG.play();
        _whiteBG.onSequenceEnd.listen(_onFinishSequence);
        break;
    }
  }

  void _resetCallbacks() {
    _whiteBG.removeEventListener(GAFMovieClip.EVENT_TYPE_SEQUENCE_END, _onFinishSequence);
    _arm.removeEventListener(GAFMovieClip.EVENT_TYPE_SEQUENCE_END, _onFinishSequence);
  }

  int _generatePrize() {
    ++_prize;
    if (_prize == PRIZE_COUNT) _prize = 0;
    return _prize;
  }

  /// Method returns machine spin result
  ///   4 3 1
  ///   2 2 2
  ///   1 1 5
  /// where numbers are fruit indexes

  List<List<int>> _generateSpinResult(int prize) {

    var result = new List<List<int>>(3);
    var random = new math.Random();
    var centralFruit = 0;

    for (int i = 0; i < 3; i++) {
      result[i] = new List<int>(3);
      result[i][0] = random.nextInt(_FRUIT_COUNT) + 1;
      result[i][2] = random.nextInt(_FRUIT_COUNT) + 1;
    }

    if (prize == PRIZE_NONE) {
      centralFruit = random.nextInt(_FRUIT_COUNT) + 1;
    } else if (prize == PRIZE_C1K) {
      centralFruit = random.nextInt(_FRUIT_COUNT ~/ 2) + 1;
    } else if (prize == PRIZE_C500K) {
      centralFruit = random.nextInt(_FRUIT_COUNT ~/ 2) + _FRUIT_COUNT ~/ 2 + 1;
    } else if (prize == PRIZE_C1000K) {
      centralFruit = _FRUIT_COUNT - 1;
    }

    if (prize == PRIZE_NONE) {
      result[0][1] = centralFruit;
      result[1][1] = centralFruit;
      result[2][1] = centralFruit;
      while (result[2][1] == result[1][1]) {
        // last fruit should be different
        result[2][1] = random.nextInt(_FRUIT_COUNT) + 1;
      }
    } else {
      for (int i = 0; i < result.length; i++) {
        result[i][1] = centralFruit;
      }
    }

    return result;
  }

  /// Here we switching to win animation

  void _showPrize(int prize) {

    var coinsBottomState = _getTextByPrize(prize) + "_" + _rewardType;
    _bottomCoins.visible = true;
    _bottomCoins.gotoAndStop(coinsBottomState);

    if (prize == PRIZE_NONE) {
      _nextState();
      return;
    }

    _winFrame.setSequence("win", true);
    _rewardText.setSequence(_getTextByPrize(prize));

    int idx = prize - 1;
    _centralCoins[idx].visible = true;
    _centralCoins[idx].play(true);
    _centralCoins[idx].setSequence(_rewardType);
    _juggler.delayCall(_nextState, 2.0);
  }

  String _getTextByPrize(int prize) {
    switch (prize) {
      case PRIZE_NONE: return "notwin";
      case PRIZE_C1K: return "win1k";
      case PRIZE_C500K: return "win500k";
      case PRIZE_C1000K: return "win1000k";
      default: return "";
    }
  }
}

