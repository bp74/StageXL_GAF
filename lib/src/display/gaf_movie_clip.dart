part of stagexl_gaf;

/** Dispatched when playhead reached first frame of sequence */
// [Event(name="typeSequenceStart", type="starling.events.Event")]

/** Dispatched when playhead reached end frame of sequence */
// [Event(name="typeSequenceEnd", type="starling.events.Event")]

/** Dispatched whenever the movie has displayed its last frame. */
// [Event(name="complete", type="starling.events.Event")]

/// The [GAFMovieClip] is an animated display object.
///
/// It has all controls for animation familiar from standard MovieClip
/// ([play], [stop], [gotoAndPlay], etc.) and some more like [loop],
/// [nPlay], [setSequence] that helps manage playback

class GAFMovieClip extends DisplayObjectContainer implements Animatable, MaxSize {

  static final String EVENT_TYPE_SEQUENCE_START = "typeSequenceStart";
	static final String EVENT_TYPE_SEQUENCE_END = "typeSequenceEnd";

  //--------------------------------------------------------------------------

  final GAFTimeline _gafTimeline;

  final Map<String, DisplayObject> _displayObjectsMap = new Map<String, DisplayObject>();
  final List<DisplayObject> _displayObjectsList = new List<DisplayObject>();

  final List<GAFImage> _imagesList = new List<GAFImage>();
  final List<GAFMovieClip> _movieClipList = new List<GAFMovieClip>();

  CAnimationSequence _playingSequence;
  Point _maxSize;

  bool _loop = true;
  bool _skipFrames = true;
  bool _reseted = false;
  bool _inPlay = false;
  bool _hidden = false;
  bool _reverse = false;
  bool _started = false;

  num _currentTime = 0.0;
  num _lastFrameTime = 0.0;
  num _frameDuration = 0.0;

  int _nextFrame = 0;
  int _startFrame = 0;
  int _finalFrame = 0;
  int _currentFrame = 0;

  //---------------------------------------------------------------------------

  /// Creates a new GAFMovieClip instance.
  ///
  /// @param gafTimeline [GAFTimeline] from what [GAFMovieClip] will be created
  /// @param fps defines the frame rate of the movie clip. If not set, the stage
  /// config frame rate will be used instead.

  GAFMovieClip(GAFTimeline gafTimeline, [int fps])
      : _gafTimeline = gafTimeline {

   this.fps = fps ?? gafTimeline.config.stageConfig?.fps ?? 25;

   for (CAnimationObject animationObject in gafTimeline.config.animationObjects.all) {

     var displayObject = null;
     var regionID = animationObject.regionID;
     var instanceID = animationObject.instanceID;

     if (animationObject.type == CAnimationObject.TYPE_TEXTURE) {
       var texture = gafTimeline.textureAtlas.getTexture(regionID);
       displayObject = new GAFImage(texture);
       _imagesList.add(displayObject);
     } else if (animationObject.type == CAnimationObject.TYPE_TEXTFIELD) {
       var textFieldObject = gafTimeline.config.textFields.getTextFieldObject(regionID);
       displayObject = new GAFTextField(textFieldObject, gafTimeline.scale, gafTimeline.contentScaleFactor);
     } else if (animationObject.type == CAnimationObject.TYPE_TIMELINE) {
       var timeline = gafTimeline.gafAsset.getGAFTimelineByID(regionID);
       displayObject = new GAFMovieClip(timeline, this.fps);
       _movieClipList.add(displayObject);
     }

     if (displayObject is MaxSize && animationObject.maxSize is Point) {
       var x = animationObject.maxSize.x * gafTimeline.scale;
       var y = animationObject.maxSize.y * gafTimeline.scale;
       displayObject.maxSize = new Point<num>(x, y);
     }

     _displayObjectsMap[instanceID] = displayObject;
     _displayObjectsList.add(displayObject);

     if (gafTimeline.config.namedParts != null) {
       var instanceName = gafTimeline.config.namedParts[instanceID];
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

  int get totalFrames => _gafTimeline.config.framesCount;

  /// Indicates whether GAFMovieClip instance already in play

  bool get inPlay => _inPlay;

  /// Indicates whether GAFMovieClip instance continue playing from start
  /// frame after playback reached animation end

  bool get loop => _loop;

  set loop(bool loop) {
    _loop = loop;
  }

  Point get maxSize => _maxSize;

  set maxSize(Point value) {
    _maxSize = value;
  }

  /// The individual frame rate for this [GAFMovieClip].
  ///
  /// If the value is lower than stage fps, then the [GAFMovieClip] will
  /// skip frames.

  num get fps {
    return _frameDuration.isInfinite ? 1.0 / _frameDuration : 0.0;
  }

  set fps(num value) {
    _frameDuration = value <= 0.0 ? double.INFINITY : 1.0 / value;
    _movieClipList.forEach((mc) => mc.fps = fps);
  }

  /// If ´true´ animation will be playing in reverse mode

  bool get reverse => _reverse;

  void set reverse(bool value) {
    _reverse = value;
    _movieClipList.forEach((mc) => mc.reverse = value);
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
    _movieClipList.forEach((mc) => mc.skipFrames = value);
  }

  void set transformationMatrix(Matrix value) {
    throw new UnimplementedError("transformationMatrix setter");
  }

  //--------------------------------------------------------------------------

  /// Returns the child display object that exists with the specified ID.
  /// Use to obtain animation's parts
  ///
  /// @param id Child ID
  /// @return The child display object with the specified ID

  DisplayObject getChildByID(String id) {
    return _displayObjectsMap[id];
  }

  /// Returns the mask display object that exists with the specified ID.
  /// Use to obtain animation's masks
  ///
  /// @param id Mask ID
  /// @return The mask display object with the specified ID

  DisplayObject getMaskByID(String id) {
    return _displayObjectsMap[id];
  }

  /// Clear playing sequence. If animation already in play just continue
  /// playing without sequence limitation

  void clearSequence() {
    _playingSequence = null;
  }

  /// Returns id of the sequence where animation is right now. If there
  /// is no sequences - returns null.
  ///
  /// @return id of the sequence

  String get currentSequence {
    var sequences = _gafTimeline.config.animationSequences;
    var sequence = sequences.getSequenceByFrame(this.currentFrame);
    return sequence?.id;
  }

  /// Set sequence to play
  ///
  /// @param id Sequence ID
  /// @param play Play or not immediately. <code>true</code> - starts playing from sequence start frame. <code>false</code> - go to sequence start frame and stop
  /// @return sequence to play

  CAnimationSequence setSequence(String id, [bool play = true]) {

    var sequences = _gafTimeline.config.animationSequences;
    var sequence = sequences.getSequenceByID(id);

    _playingSequence = sequence;

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

    _started = true;

    if (applyToAllChildren) {
      for (var movieClip in _movieClipList) {
        movieClip._started = true;
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

    _started = false;

    if (applyToAllChildren) {
      for (var movieClip in _movieClipList) {
        movieClip._started = false;
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

    for (var movieClip in _movieClipList) {
      movieClip.loop = loop;
    }
  }

  /// Advances all objects by a certain time (in seconds).
  ///
  /// @see starling.animation.IAnimatable

  bool advanceTime(num passedTime) {

    if (_inPlay && _frameDuration != double.INFINITY) {

      _currentTime += passedTime;

      int framesToPlay = ((_currentTime - _lastFrameTime) / _frameDuration).round();

      if (_skipFrames) {
        //here we skip the drawing of all frames to be played right now, but the last one
        for (int i = 0; i < framesToPlay; ++i) {
          if (_inPlay) {
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

    for (int i = 0; i < _movieClipList.length; i++) {
      _movieClipList[i].advanceTime(passedTime);
    }

    return true;
  }

  /// Creates a new instance of GAFMovieClip.

  GAFMovieClip copy() {
    return new GAFMovieClip(_gafTimeline, this.fps);
  }

  //--------------------------------------------------------------------------

  void _gotoAndStop(dynamic frame) {
    _checkAndSetCurrentFrame(frame);
    _stop();
  }

  void _play([bool applyToAllChildren = false, bool calledByUser = false]) {

    var config = _gafTimeline.config;
    var frames = _gafTimeline.config.animationFrames.all;

    if (_inPlay && !applyToAllChildren) return;
    if (config.framesCount > 1) _inPlay = true;

    if (applyToAllChildren && frames.length > 0) {

      CAnimationFrame frameConfig = frames[_currentFrame];

      if (frameConfig.actions != null) {
        for (CFrameAction action in frameConfig.actions.length) {
          if (action.type == CFrameAction.STOP || (
              action.type == CFrameAction.GOTO_AND_STOP &&
                  int.parse(action.params[0]) == this.currentFrame)) {
            _inPlay = false;
            return;
          }
        }
      }

      for (var child in this.children) {
        if (child is GAFMovieClip) {
          if (calledByUser) {
            child.play(true);
          } else {
            child._play(true);
          }
        }
      }
    }

    _runActions();
    _reseted = false;
  }

  void _stop([bool applyToAllChildren = false, bool calledByUser = false]) {

    var frames = _gafTimeline.config.animationFrames.all;

    _inPlay = false;

    if (applyToAllChildren && frames.length > 0) {
      for (var child in this.children) {
        if (child is GAFMovieClip) {
          if (calledByUser) {
            child.stop(true);
          } else {
            child._stop(true);
          }
        }
      }
    }
  }

  void _checkPlaybackEvents() {

    if (this.hasEventListener(EVENT_TYPE_SEQUENCE_START)) {
      var sequence = _gafTimeline.config.animationSequences.getSequenceStart(_currentFrame + 1);
      if (sequence != null) _dispatchEventWith(EVENT_TYPE_SEQUENCE_START, false, sequence);
    }

    if (this.hasEventListener(EVENT_TYPE_SEQUENCE_END)) {
      var sequence = _gafTimeline.config.animationSequences.getSequenceEnd(_currentFrame + 1);
      if (sequence != null) _dispatchEventWith(EVENT_TYPE_SEQUENCE_END, false, sequence);
    }

    if (this.hasEventListener(Event.COMPLETE)) {
      if (_currentFrame == _finalFrame) _dispatchEventWith(Event.COMPLETE);
    }
  }

  void _dispatchEventWith(String type, [bool bubbles = false, Object data = null]) {
    var event = new Event(type, bubbles);
    this.dispatchEvent(event);
    // TODO: create special event which holds [data].
  }

  void _runActions() {

    if (_gafTimeline.config.animationFrames.all.length == 0) return;

    var actions = _gafTimeline.config.animationFrames.all[_currentFrame].actions;

    if (actions != null) {

      for(CFrameAction action in actions) {

        switch (action.type) {

          case CFrameAction.STOP:
            this.stop();
            break;

          case CFrameAction.PLAY:
            this.play();
            break;

          case CFrameAction.GOTO_AND_STOP:
            this.gotoAndStop(action.params[0]);
            break;

          case CFrameAction.GOTO_AND_PLAY:
            this.gotoAndPlay(action.params[0]);
            break;

          case CFrameAction.DISPATCH_EVENT:
            String type = action.params[0];

            if (this.hasEventListener(type)) {
              var data = action.params.length >= 4 ? action.params[3] : null;
              var cancelable = action.params.length >= 3 ? action.params[2] == "true" : false;
              var bubbles = action.params.length >= 2 ? action.params[1] == "true" : false;
              this._dispatchEventWith(type, bubbles, data);
            }

            if (type == CSound.GAF_PLAY_SOUND /* && GAF.autoPlaySounds */ ) {
              _gafTimeline.startSound(this.currentFrame);
            }

            break;
        }
      }
    }
  }

  void _checkAndSetCurrentFrame(dynamic frame) {

    if (frame is int) {
      var frameCount = _gafTimeline.config.framesCount;
      if (frame > frameCount) frame = frameCount;
    } else if (frame is String) {
      String label = frame;
      frame = _gafTimeline.config.animationSequences.getStartFrameNo(label);
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

    _displayObjectsMap.forEach((k,v) => v.off = true);
    _movieClipList.forEach((mc) => mc._hidden = true);

    var animationObjects = _gafTimeline.config.animationObjects;
    var animationFrames = _gafTimeline.config.animationFrames.all;

    if (animationFrames.length > _currentFrame) {

      var frameConfig = animationFrames[_currentFrame];
      for (var instance in frameConfig.instances) {

        var animationObject = animationObjects.getAnimationObject(instance.id);
        if (animationObject == null) continue;

        var displayObject = _displayObjectsMap[instance.id];
        if (displayObject == null) continue;

        if (displayObject is GAFMovieClip) {
          if (displayObject.alpha < 0.0) {  // TODO: this is impossible!
            displayObject._reset();
          } else if (displayObject._reseted && displayObject._started) {
            displayObject._play(true);
          }
          displayObject._hidden = false;
        }

        displayObject.off = animationObject.mask;
        displayObject.alpha = animationObject.mask ? 0.3 : instance.alpha;
        displayObject.filters.clear();

        displayObject.transformationMatrix.copyFrom(instance.matrix);
        displayObject.transformationMatrix.scale(_gafTimeline.scale, _gafTimeline.scale);
        displayObject.addTo(this); // TODO: this is slow

        if (displayObject is GAFImage) {
          // TODO: We should remove this by addint the pivot to the vxList
          var pivotMatrix = displayObject.assetTexture.pivotMatrix;
          displayObject.transformationMatrix.prepend(pivotMatrix);
        }

        if (animationObject.mask == false && instance.maskID.length > 0) {
          var mask = _displayObjectsMap[instance.maskID];
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
        var filterScale = _gafTimeline.scale;
        // TODO: apply filters

      }
    }

    _checkPlaybackEvents();
  }

  void _reset() {
    _gotoAndStop((_reverse ? _finalFrame : _startFrame) + 1);
    _reseted = true;
    _currentTime = 0;
    _lastFrameTime = 0;
    _movieClipList.forEach((mc) => mc._reset());
  }

  //--------------------------------------------------------------------------

  void _changeCurrentFrame(bool isSkipping) {

    var resetInvisibleChildren = false;
    var frameCount = _gafTimeline.config.framesCount;

    _nextFrame = _currentFrame + (_reverse ? -1 : 1);
    _startFrame = (_playingSequence != null? _playingSequence.startFrameNo : 1) - 1;
    _finalFrame = (_playingSequence != null ? _playingSequence.endFrameNo : frameCount) - 1;

    if (_nextFrame >= _startFrame && _nextFrame <= _finalFrame) {
      _currentFrame = _nextFrame;
      _lastFrameTime += _frameDuration;
    } else if (!_loop) {
      this.stop();
    } else {
      _currentFrame = _reverse ? _finalFrame : _startFrame;
      _lastFrameTime += _frameDuration;
      resetInvisibleChildren = true;
    }

    _runActions();

    if(isSkipping == false) {
      // Draw will trigger events if any
      _draw();
    } else {
      _checkPlaybackEvents();
    }

    if( resetInvisibleChildren) {
      //reset timelines that aren't visible
      for (var movieClip in _movieClipList) {
        if (movieClip._hidden) movieClip._reset();
      }
    }
  }

}
