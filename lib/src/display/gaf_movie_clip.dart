part of stagexl_gaf;

/// The [GAFMovieClip] is an animated display object.
///
/// It has all controls for animation familiar from standard MovieClip
/// ([play], [stop], [gotoAndPlay], etc.) and some more like [loop],
/// [nPlay], [setSequence] that helps manage playback

class GAFMovieClip extends DisplayObjectContainer implements GAFDisplayObject, Animatable {

  static const String EVENT_TYPE_SEQUENCE_START = "typeSequenceStart";
	static const String EVENT_TYPE_SEQUENCE_END = "typeSequenceEnd";

  static const EventStreamProvider<Event> sequenceStartEvent = const EventStreamProvider<Event>(EVENT_TYPE_SEQUENCE_START);
  static const EventStreamProvider<Event> sequenceEndEvent = const EventStreamProvider<Event>(EVENT_TYPE_SEQUENCE_END);
  static const EventStreamProvider<Event> completeEvent = const EventStreamProvider<Event>(Event.COMPLETE);

  EventStream<Event> get onSequenceStart => GAFMovieClip.sequenceStartEvent.forTarget(this);
  EventStream<Event> get onSequenceEnd => GAFMovieClip.sequenceEndEvent.forTarget(this);
  EventStream<Event> get onComplete => GAFMovieClip.completeEvent.forTarget(this);

  //--------------------------------------------------------------------------

  final GAFTimeline _timeline;

  final Map<int, GAFDisplayObject> _displayObjects = new Map<int, GAFDisplayObject>();
  final List<GAFMovieClip> _movieClips = new List<GAFMovieClip>();

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

  CAnimationSequence _playingSequence = null;

  //---------------------------------------------------------------------------

  /// Creates a new GAFMovieClip instance.
  ///
  /// @param gafTimeline [GAFTimeline] from what [GAFMovieClip] will be created
  /// @param fps defines the frame rate of the movie clip. If not set, the stage
  /// config frame rate will be used instead.

  GAFMovieClip(GAFTimeline timeline, [num fps]) : _timeline = timeline {

    var config = _timeline.config;
    var scale = _timeline.scale;
    var csf = _timeline.contentScaleFactor;

    this.fps = fps ?? config.stageConfig?.fps ?? 25;

    for (CAnimationObject animationObject in config.animationObjects.all) {

      var displayObject = null;
      var type = animationObject.type;
      var regionID = animationObject.regionID;
      var instanceID = animationObject.instanceID;

      if (type == CAnimationObject.TYPE_TEXTURE) {
        var bitmapData = _timeline.textureAtlas.getBitmapData(regionID);
        displayObject = new GAFBitmap(bitmapData);
      } else if (type == CAnimationObject.TYPE_TEXTFIELD) {
        var textFieldObject = config.textFields.getTextFieldObject(regionID);
        displayObject = new GAFTextField(textFieldObject, scale, csf);
      } else if (type == CAnimationObject.TYPE_TIMELINE) {
        var mcTimeline = _timeline.gafAsset.getGAFTimelineByID(regionID);
        displayObject = new GAFMovieClip(mcTimeline, this.fps);
        _movieClips.add(displayObject);
      }

      _displayObjects[instanceID] = displayObject;

      if (config.namedParts != null) {
        var instanceName = config.namedParts[instanceID];
        if (instanceName != null) {
          //this[_config.namedParts[instanceID]] = displayObject;
          displayObject.name = instanceName;
        }
      }
    }

    _draw();
  }

  //--------------------------------------------------------------------------

  /// Specifies the number of the frame in which the playhead is located in
  /// the timeline of the GAFMovieClip instance. First frame is "1"

  int get currentFrame  => _currentFrame + 1;

  /// The total number of frames in the GAFMovieClip instance.

  int get totalFrames => _timeline.config.framesCount;

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
    _frameDuration = value <= 0.0 ? double.INFINITY : 1.0 / value;
    for (var movieClip in _movieClips) {
      movieClip.fps = value;
    }
  }

  /// If ´true´ animation will be playing in reverse mode

  bool get reverse => _reverse;

  void set reverse(bool value) {
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

  void set skipFrames(bool value) {
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

  DisplayObject getChildByID(String id) {
    return _displayObjects[id];
  }

  /// Returns the mask display object that exists with the specified ID.
  /// Use to obtain animation's masks
  ///
  /// @param id Mask ID

  DisplayObject getMaskByID(String id) {
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
    var sequences = _timeline.config.animationSequences;
    var sequence = sequences.getSequenceByFrame(this.currentFrame);
    return sequence?.id;
  }

  /// Set sequence to play
  ///
  /// @param id Sequence ID
  /// @param play Play or not immediately. <code>true</code> - starts playing from sequence start frame. <code>false</code> - go to sequence start frame and stop

  CAnimationSequence setSequence(String id, [bool play = true]) {

    var sequences = _timeline.config.animationSequences;
    var sequence = _playingSequence = sequences.getSequenceByID(id);

    if (sequence != null) {
      int startFrame = _reverse ? sequence.endFrameNo - 1 : sequence.startFrameNo;
      if (play) {
        this.gotoAndPlay(startFrame);
      } else {
        this.gotoAndStop(startFrame);
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
    this.stop();
  }

  /// Starts playing animation at the specified frame. First frame is "1"
  ///
  /// @param frame A number representing the frame number, or a string
  /// representing the label of the frame, to which the playhead is sent.

  void gotoAndPlay(dynamic frame) {
    _checkAndSetCurrentFrame(frame);
    this.play();
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

  bool advanceTime(num passedTime) {

    if (_isPlaying && _frameDuration.isFinite) {

      _currentTime += passedTime;

      int framesToPlay = (_currentTime - _lastFrameTime) ~/ _frameDuration;

      if (_skipFrames) {
        //here we skip the drawing of all frames to be played right now, but the last one
        for (int i = 0; i < framesToPlay; ++i) {
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
    return new GAFMovieClip(_timeline, this.fps);
  }

  //--------------------------------------------------------------------------

  void _gotoAndStop(dynamic frame) {
    _checkAndSetCurrentFrame(frame);
    _stop();
  }

  void _play([bool applyToAllChildren = false, bool calledByUser = false]) {

    var config = _timeline.config;
    var frames = _timeline.config.animationFrames.all;

    if (_isPlaying && applyToAllChildren == false || this.off) return;
    if (config.framesCount > 1) _isPlaying = true;

    if (applyToAllChildren && frames.length > 0) {

      var frameConfig = frames[_currentFrame];

      for (var action in frameConfig.actions) {
        if (action.type == CFrameAction.STOP || (
            action.type == CFrameAction.GOTO_AND_STOP &&
                int.parse(action.params[0]) == this.currentFrame)) {
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

    var frames = _timeline.config.animationFrames.all;

    if (applyToAllChildren && frames.length > 0) {
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

    if (this.hasEventListener(EVENT_TYPE_SEQUENCE_START)) {
      var type = EVENT_TYPE_SEQUENCE_START;
      var sequences = _timeline.config.animationSequences;
      var sequence = sequences.getSequenceStart(_currentFrame + 1);
      if (sequence != null) _dispatchEventWith(type, false, sequence);
    }

    if (this.hasEventListener(EVENT_TYPE_SEQUENCE_END)) {
      var type = EVENT_TYPE_SEQUENCE_END;
      var sequences = _timeline.config.animationSequences;
      var sequence = sequences.getSequenceEnd(_currentFrame + 1);
      if (sequence != null) _dispatchEventWith(type, false, sequence);
    }

    if (this.hasEventListener(Event.COMPLETE)) {
      if (_currentFrame == _finalFrame) _dispatchEventWith(Event.COMPLETE);
    }
  }

  void _dispatchEventWith(String type, [bool bubbles = false, Object data]) {
    var event = new Event(type, bubbles);
    this.dispatchEvent(event);
    // TODO: create special event which holds [data].
  }

  void _runActions() {

    var animationFrames = _timeline.config.animationFrames.all;
    if (animationFrames.length == 0) return;

    var animationFrame =  animationFrames[_currentFrame];

    for (CFrameAction action in animationFrame.actions) {
      var params = action.params;
      if (action.type == CFrameAction.STOP) {
        this.stop();
      } else if (action.type == CFrameAction.PLAY) {
        this.play();
      } else if (action.type == CFrameAction.GOTO_AND_STOP) {
        this.gotoAndStop(params[0]);
      } else if (action.type == CFrameAction.GOTO_AND_PLAY) {
        this.gotoAndPlay(params[0]);
      } else if (action.type == CFrameAction.DISPATCH_EVENT) {
        var data = params.length >= 4 ? params[3] : null;
        var cancelable = params.length >= 3 ? params[2] == "true" : false;
        var bubbles = params.length >= 2 ? params[1] == "true" : false;
        var type = params.length >= 1 ? params[0] : null;
        if (hasEventListener(type)) _dispatchEventWith(type, bubbles, data);
        if (type == CSound.GAF_PLAY_SOUND) _timeline.startSound(currentFrame);
      }
    }
  }

  void _checkAndSetCurrentFrame(dynamic frame) {

    if (frame is int) {
      var frameCount = _timeline.config.framesCount;
      if (frame > frameCount) frame = frameCount;
    } else if (frame is String) {
      String label = frame;
      frame = _timeline.config.animationSequences.getStartFrameNo(label);
      if (frame == 0) throw new ArgumentError("Frame label '$label' not found");
    } else {
      frame = 1;
    }

    if (_playingSequence != null && _playingSequence.isSequenceFrame(frame) == null) {
      _playingSequence = null;
    }

    if (_currentFrame != frame - 1) {
      _currentFrame = frame - 1;
      _runActions();
    }
  }

  void _draw() {

    var animationObjects = _timeline.config.animationObjects;
    var animationFrames = _timeline.config.animationFrames.all;

    for (var displayObject in _displayObjects.values) {
      displayObject.off = true;
    }

    if (animationFrames.length > _currentFrame) {

      var frameConfig = animationFrames[_currentFrame];
      for (var instance in frameConfig.instances) {

        var animationObject = animationObjects.getAnimationObject(instance.id);
        if (animationObject == null) continue;

        var displayObject = _displayObjects[instance.id];
        if (displayObject == null) continue;

        displayObject.off = false;
        displayObject.visible = animationObject.mask ? false : true;
        displayObject.alpha = animationObject.mask ? 0.3 : instance.alpha;
        displayObject.filters.clear();
        this.addChild(displayObject);

        if (displayObject is GAFMovieClip) {
          if (instance.alpha < 0.0) {
            displayObject._reset();
          } else if (displayObject._isReset && displayObject._isStart) {
            displayObject._play(true);
          }
        }

        var displayObjectMatrix = displayObject.transformationMatrix;
        displayObjectMatrix.copyFrom(instance.matrix);
        displayObjectMatrix.scale(_timeline.scale, _timeline.scale);

        if (displayObject is GAFBitmap) {
          // TODO: remove this, see GAFBitmapData
          var matrix = displayObject.bitmapData.transformationMatrix;
          displayObjectMatrix.prepend(matrix);
        }

        if (animationObject.mask == false && instance.maskID != null) {
          var mask = _displayObjects[instance.maskID];
          if (mask is Bitmap) {
            // TODO: avoid memory allocations for filter/matrix
            var filter = new AlphaMaskFilter(mask.bitmapData);
            filter.matrix.copyFromAndInvert(displayObject.transformationMatrix);
            filter.matrix.prepend(mask.transformationMatrix);
            displayObject.filters.add(filter);
          } else {
            throw new StateError("MovieClip masks not yet supported.");
          }
        }

        var filterConfig = instance.filter;
        var filterScale = _timeline.scale;
        // TODO: apply filters

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
    var frameCount = _timeline.config.framesCount;
    var sequence = _playingSequence;

    _nextFrame = _currentFrame + (_reverse ? -1 : 1);
    _startFrame = (sequence != null? sequence.startFrameNo : 1) - 1;
    _finalFrame = (sequence != null ? sequence.endFrameNo : frameCount) - 1;

    if (_nextFrame >= _startFrame && _nextFrame <= _finalFrame) {
      _currentFrame = _nextFrame;
      _lastFrameTime += _frameDuration;
    } else if (_loop == false) {
      this.stop();
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
