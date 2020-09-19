part of stagexl_gaf;

/// The [GAFMovieClip] is an animated display object.
///
/// It has all controls for animation familiar from standard MovieClip
/// ([play], [stop], [gotoAndPlay], etc.) and some more like [loop],
/// [nPlay], [setSequence] that helps manage playback

class GAFMovieClip extends DisplayObjectContainer
    implements GAFDisplayObject, Animatable {
  static const EventStreamProvider<SequenceEvent> sequenceStartEvent =
      EventStreamProvider<SequenceEvent>(SequenceEvent.SEQUENCE_START);

  static const EventStreamProvider<SequenceEvent> sequenceEndEvent =
      EventStreamProvider<SequenceEvent>(SequenceEvent.SEQUENCE_END);

  static const EventStreamProvider<Event> completeEvent =
      EventStreamProvider<Event>(Event.COMPLETE);

  EventStream<SequenceEvent> get onSequenceStart =>
      GAFMovieClip.sequenceStartEvent.forTarget(this);

  EventStream<SequenceEvent> get onSequenceEnd =>
      GAFMovieClip.sequenceEndEvent.forTarget(this);

  EventStream<Event> get onComplete =>
      GAFMovieClip.completeEvent.forTarget(this);

  //--------------------------------------------------------------------------

  final GAFTimeline timeline;
  @override
  final Matrix pivotMatrix = Matrix.fromIdentity();

  final Map<int, GAFDisplayObject> _displayObjects = <int, GAFDisplayObject>{};
  final List<GAFMovieClip> _movieClips = <GAFMovieClip>[];

  bool _loop = true;
  bool _reverse = false;
  bool _skipFrames = true;

  bool _isReset = true;
  bool _isStart = false;
  bool _isPlaying = false;

  num _currentTime = 0.0;
  num _lastFrameTime = 0.0;
  num _frameDuration = 0.0;

  int _nextFrame = 0;
  int _startFrame = 0;
  int _finalFrame = 0;
  int _currentFrame = 0;

  CAnimationSequence _playingSequence;

  //---------------------------------------------------------------------------

  /// Creates a GAFMovieClip instance.
  ///
  /// @param gafTimeline [GAFTimeline] from what [GAFMovieClip] will be created
  /// @param fps defines the frame rate of the movie clip. If not set, the stage
  /// config frame rate will be used instead.

  GAFMovieClip(this.timeline, [num fps]) {
    var displayScale = timeline.gafAsset.displayScale;
    var contentScale = timeline.gafAsset.contentScale;
    var gafAsset = timeline.gafAsset;
    var config = timeline.config;

    this.fps = fps ?? gafAsset.config.stageConfig.fps;

    for (var animationObject in config.animationObjects) {
      var displayObject;
      var type = animationObject.type;
      var regionID = animationObject.regionID;
      var instanceID = animationObject.instanceID;

      if (type == CAnimationObject.TYPE_TEXTURE) {
        var bitmapData = gafAsset.getGAFBitmapDataByID(regionID);
        displayObject = GAFBitmap(bitmapData);
      } else if (type == CAnimationObject.TYPE_TEXTFIELD) {
        var textField = config.getTextField(regionID);
        displayObject = GAFTextField(textField, displayScale, contentScale);
      } else if (type == CAnimationObject.TYPE_TIMELINE) {
        var mcTimeline = gafAsset.getGAFTimelineByID(regionID);
        displayObject = GAFMovieClip(mcTimeline, this.fps);
        _movieClips.add(displayObject);
      }

      _displayObjects[instanceID] = displayObject;

      if (config.namedParts != null) {
        var instanceName = config.namedParts[instanceID];
        if (instanceName != null) displayObject.name = instanceName;
      }
    }

    _draw();
  }

  //--------------------------------------------------------------------------

  /// Specifies the number of the frame in which the playhead is located in
  /// the timeline of the GAFMovieClip instance. First frame is "1"

  int get currentFrame => _currentFrame + 1;

  /// The total number of frames in the GAFMovieClip instance.

  int get totalFrames => timeline.config.framesCount;

  /// Indicates whether GAFMovieClip instance is playing

  bool get isPlaying => _isPlaying;

  /// Indicates whether GAFMovieClip instance continue playing from start
  /// frame after playback reached animation end

  bool get loop => _loop;

  set loop(bool loop) {
    _loop = loop;
  }

  /// The individual frame rate for this [GAFMovieClip].
  ///
  /// If the value is lower than stage fps, then the [GAFMovieClip] will
  /// skip frames.

  num get fps {
    return _frameDuration.isFinite ? 1.0 / _frameDuration : 0.0;
  }

  set fps(num value) {
    _frameDuration = value <= 0.0 ? double.infinity : 1.0 / value;
    for (var movieClip in _movieClips) {
      movieClip.fps = value;
    }
  }

  /// If ´true´ animation will be playing in reverse mode

  bool get reverse => _reverse;

  set reverse(bool value) {
    _reverse = value;
    for (var movieClip in _movieClips) {
      movieClip.reverse = value;
    }
  }

  /// Indicates whether GAFMovieClip instance should skip frames when
  /// application fps drops down or play every frame not depending on
  /// application fps.
  ///
  /// Value false will force GAFMovieClip to play each frame not depending on
  /// application fps (the same behavior as in regular Flash Movie Clip).
  ///
  /// Value true will force GAFMovieClip to play animation "in time".
  /// And when application fps drops down it will start skipping frames
  /// (default behavior).

  bool get skipFrames => _skipFrames;

  set skipFrames(bool value) {
    _skipFrames = value;
    for (var movieClip in _movieClips) {
      movieClip.skipFrames = value;
    }
  }

  //--------------------------------------------------------------------------

  /// Returns the child display object that exists with the specified ID.
  /// Use to obtain animation's parts
  ///
  /// @param id Child ID

  DisplayObject getChildByID(int id) {
    return _displayObjects[id];
  }

  /// Returns the mask display object that exists with the specified ID.
  /// Use to obtain animation's masks
  ///
  /// @param id Mask ID

  DisplayObject getMaskByID(int id) {
    return _displayObjects[id];
  }

  /// Clear playing sequence. If animation already in play just continue
  /// playing without sequence limitation

  void clearSequence() {
    _playingSequence = null;
  }

  /// Returns id of the sequence where animation is right now. If there
  /// is no sequences - returns null.

  String get currentSequence {
    var sequence = timeline.config.getSequenceByFrame(currentFrame);
    return sequence?.id;
  }

  /// Set sequence to play
  ///
  /// @param id Sequence ID
  /// @param play Play or not immediately. <code>true</code> - starts playing from sequence start frame. <code>false</code> - go to sequence start frame and stop

  CAnimationSequence setSequence(String id, [bool play = true]) {
    var sequence = _playingSequence = timeline.config.getSequence(id);

    if (sequence != null) {
      var startFrame =
          _reverse ? sequence.endFrameNo - 1 : sequence.startFrameNo;
      if (play) {
        gotoAndPlay(startFrame);
      } else {
        gotoAndStop(startFrame);
      }
    }

    return _playingSequence;
  }

  /// Moves the playhead in the timeline of the movie clip play() or play(false).
  ///
  /// Or moves the playhead in the timeline of the movie clip and all child movie
  /// clips play(true). Use play(true) in case when animation contain nested
  /// timelines for correct playback right after initialization (like you see
  /// in the original swf file).
  ///
  /// @param applyToAllChildren Specifies whether playhead should be moved in the timeline of the movie clip
  /// (<code>false</code>) or also in the timelines of all child movie clips (<code>true</code>).

  void play([bool applyToAllChildren = false]) {
    _isStart = true;

    if (applyToAllChildren) {
      for (var movieClip in _movieClips) {
        movieClip._isStart = true;
      }
    }

    _play(applyToAllChildren, true);
  }

  /// Stops the playhead in the movie clip stop() or stop(false).
  ///
  /// Or stops the playhead in the movie clip and in all child movie clips stop(true).
  /// Use stop(true) in case when animation contain nested timelines for full stop the
  /// playhead in the movie clip and in all child movie clips.
  ///
  /// @param applyToAllChildren Specifies whether playhead should be stopped in the timeline of the
  /// movie clip (<code>false</code>) or also in the timelines of all child movie clips (<code>true</code>)

  void stop([bool applyToAllChildren = false]) {
    _isStart = false;

    if (applyToAllChildren) {
      for (var movieClip in _movieClips) {
        movieClip._isStart = false;
      }
    }

    _stop(applyToAllChildren, true);
  }

  /// Brings the playhead to the specified frame of the movie clip and stops
  /// it there. First frame is "1"
  ///
  /// @param frame A number representing the frame number, or a string
  /// representing the label of the frame, to which the playhead is sent.

  void gotoAndStop(dynamic frame) {
    _checkAndSetCurrentFrame(frame);
    stop();
  }

  /// Starts playing animation at the specified frame. First frame is "1"
  ///
  /// @param frame A number representing the frame number, or a string
  /// representing the label of the frame, to which the playhead is sent.

  void gotoAndPlay(dynamic frame) {
    _checkAndSetCurrentFrame(frame);
    play();
  }

  /// Set the [loop] value to the GAFMovieClip instance and for the all children.

  void loopAll(bool loop) {
    this.loop = loop;
    for (var movieClip in _movieClips) {
      movieClip.loop = loop;
    }
  }

  /// Advances all objects by a certain time (in seconds).
  ///
  /// @see starling.animation.IAnimatable

  @override
  bool advanceTime(num passedTime) {
    if (_isPlaying && _frameDuration.isFinite) {
      _currentTime += passedTime;

      var framesToPlay = (_currentTime - _lastFrameTime) ~/ _frameDuration;

      if (_skipFrames) {
        //here we skip the drawing of all frames to be played right now, but the last one
        for (var i = 0; i < framesToPlay; ++i) {
          if (_isPlaying) {
            _changeCurrentFrame((i + 1) != framesToPlay);
          } else {
            _draw();
            break;
          }
        }
      } else if (framesToPlay > 0) {
        _changeCurrentFrame(false);
      }
    }

    for (var movieClip in _movieClips) {
      movieClip.advanceTime(passedTime);
    }

    return true;
  }

  /// Creates a clone of this [GAFMovieClip].

  GAFMovieClip clone() {
    return GAFMovieClip(timeline, fps);
  }

  //--------------------------------------------------------------------------

  void _gotoAndStop(dynamic frame) {
    _checkAndSetCurrentFrame(frame);
    _stop();
  }

  void _play([bool applyToAllChildren = false, bool calledByUser = false]) {
    var config = timeline.config;
    var frames = timeline.config.animationFrames;

    if (_isPlaying && applyToAllChildren == false || off) return;
    if (config.framesCount > 1) _isPlaying = true;

    if (applyToAllChildren && frames.isNotEmpty) {
      var frameConfig = frames[_currentFrame];

      for (var action in frameConfig.actions) {
        if (action.type == CFrameAction.STOP ||
            (action.type == CFrameAction.GOTO_AND_STOP &&
                int.parse(action.params[0]) == currentFrame)) {
          _isPlaying = false;
          return;
        }
      }

      for (var movieClip in _movieClips) {
        if (calledByUser) {
          movieClip.play(true);
        } else {
          movieClip._play(true);
        }
      }
    }

    _runActions();
    _isReset = false;
  }

  void _stop([bool applyToAllChildren = false, bool calledByUser = false]) {
    _isPlaying = false;

    var frames = timeline.config.animationFrames;

    if (applyToAllChildren && frames.isNotEmpty) {
      for (var movieClip in _movieClips) {
        if (calledByUser) {
          movieClip.stop(true);
        } else {
          movieClip._stop(true);
        }
      }
    }
  }

  void _checkPlaybackEvents() {
    var config = timeline.config;

    if (hasEventListener(SequenceEvent.SEQUENCE_START)) {
      var type = SequenceEvent.SEQUENCE_START;
      var data = config.getSequenceByStartFrame(_currentFrame + 1);
      if (data != null) dispatchEvent(SequenceEvent(type, false, data));
    }

    if (hasEventListener(SequenceEvent.SEQUENCE_END)) {
      var type = SequenceEvent.SEQUENCE_END;
      var data = config.getSequenceByEndFrame(_currentFrame + 1);
      if (data != null) dispatchEvent(SequenceEvent(type, false, data));
    }

    if (hasEventListener(Event.COMPLETE)) {
      if (_currentFrame == _finalFrame) {
        dispatchEvent(Event(Event.COMPLETE, false));
      }
    }
  }

  void _runActions() {
    var animationFrames = timeline.config.animationFrames;
    if (animationFrames.isEmpty) return;

    var animationFrame = animationFrames[_currentFrame];

    for (var action in animationFrame.actions) {
      var params = action.params;
      if (action.type == CFrameAction.STOP) {
        stop();
      } else if (action.type == CFrameAction.PLAY) {
        play();
      } else if (action.type == CFrameAction.GOTO_AND_STOP) {
        gotoAndStop(params[0]);
      } else if (action.type == CFrameAction.GOTO_AND_PLAY) {
        gotoAndPlay(params[0]);
      } else if (action.type == CFrameAction.DISPATCH_EVENT) {
        var data = params.length >= 4 ? params[3] : null;
        //var cancelable = params.length >= 3 ? params[2] == "true" : false;
        var bubbles = params.length >= 2 ? params[1] == 'true' : false;
        var type = params.isNotEmpty ? params[0] : null;
        if (hasEventListener(type)) {
          dispatchEvent(ActionEvent(type, bubbles, data));
        }
        if (type == CSound.GAF_PLAY_SOUND) timeline.startSound(currentFrame);
      }
    }
  }

  void _checkAndSetCurrentFrame(dynamic frame) {
    if (frame is int) {
      var frameCount = timeline.config.framesCount;
      if (frame > frameCount) frame = frameCount;
    } else if (frame is String) {
      var sequence = timeline.config.getSequence(frame as String);
      if (sequence == null)
        throw ArgumentError("Frame label '$frame' not found");
      frame = sequence.startFrameNo;
    } else {
      frame = 1;
    }

    if (_playingSequence?.isSequenceFrame(frame) == false) {
      _playingSequence = null;
    }

    if (_currentFrame != frame - 1) {
      _currentFrame = frame - 1;
      _runActions();
      _draw();
    }
  }

  void _draw() {
    for (var displayObject in _displayObjects.values) {
      displayObject.off = true;
    }

    var displayScale = timeline.gafAsset.displayScale;
    var animationFrames = timeline.config.animationFrames;

    if (animationFrames.length > _currentFrame) {
      var frameConfig = animationFrames[_currentFrame];
      for (var instance in frameConfig.instances) {
        var displayObject = _displayObjects[instance.id];
        if (displayObject == null) continue;

        displayObject.off = false;
        displayObject.alpha = instance.alpha;
        displayObject.filters.clear();
        addChild(displayObject);

        if (displayObject is GAFMovieClip) {
          if (instance.alpha < 0.0) {
            displayObject._reset();
          } else if (displayObject._isReset && displayObject._isStart) {
            displayObject._play(true);
          }
        }

        var im = instance.matrix;
        var pm = displayObject.pivotMatrix;
        var tm = displayObject.transformationMatrix;

        tm.a = pm.a * im.a + pm.b * im.c;
        tm.b = pm.a * im.b + pm.b * im.d;
        tm.c = pm.c * im.a + pm.d * im.c;
        tm.d = pm.c * im.b + pm.d * im.d;
        tm.tx = pm.tx * im.a + pm.ty * im.c + im.tx * displayScale;
        tm.ty = pm.tx * im.b + pm.ty * im.d + im.ty * displayScale;

        if (instance.maskID != null) {
          var mask = _displayObjects[instance.maskID];
          if (mask is Bitmap) {
            var filter = AlphaMaskFilter((mask as Bitmap).bitmapData);
            filter.matrix.copyFromAndInvert(displayObject.transformationMatrix);
            filter.matrix.prepend(mask.transformationMatrix);
            displayObject.filters.add(filter);
            mask.visible = false;
          } else {
            throw StateError('MovieClip masks not yet supported.');
          }
        }

        if (instance.filter != null) {
          for (var filterData in instance.filter.filterDatas) {
            if (filterData is CColorMatrixFilterData) {
              var colorMatrix = filterData.colorMatrix;
              var colorOffset = filterData.colorOffset;
              var colorMatrixFilter =
                  ColorMatrixFilter(colorMatrix, colorOffset);
              displayObject.filters.add(colorMatrixFilter);
            } else if (filterData is CBlurFilterData) {
              var blurX = filterData.blurX.round();
              var blurY = filterData.blurY.round();
              var blurFilter = BlurFilter(blurX, blurY);
              displayObject.filters.add(blurFilter);
            }
          }
        }
      }
    }

    _checkPlaybackEvents();
  }

  void _reset() {
    _gotoAndStop((_reverse ? _finalFrame : _startFrame) + 1);
    _isReset = true;
    _currentTime = 0;
    _lastFrameTime = 0;

    for (var movieClip in _movieClips) {
      movieClip._reset();
    }
  }

  void _changeCurrentFrame(bool isSkipping) {
    var resetInvisibleChildren = false;
    var frameCount = timeline.config.framesCount;
    var sequence = _playingSequence;

    _nextFrame = _currentFrame + (_reverse ? -1 : 1);
    _startFrame = (sequence != null ? sequence.startFrameNo : 1) - 1;
    _finalFrame = (sequence != null ? sequence.endFrameNo : frameCount) - 1;

    if (_nextFrame >= _startFrame && _nextFrame <= _finalFrame) {
      _currentFrame = _nextFrame;
      _lastFrameTime += _frameDuration;
    } else if (_loop == false) {
      stop();
    } else {
      _currentFrame = _reverse ? _finalFrame : _startFrame;
      _lastFrameTime += _frameDuration;
      resetInvisibleChildren = true;
    }

    _runActions();

    if (isSkipping == false) {
      // Draw will trigger events if any
      _draw();
    } else {
      _checkPlaybackEvents();
    }

    if (resetInvisibleChildren) {
      //reset timelines that aren't visible
      for (var movieClip in _movieClips) {
        if (movieClip.off) movieClip._reset();
      }
    }
  }
}
