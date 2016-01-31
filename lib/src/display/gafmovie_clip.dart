part of stagexl_gaf;

/** Dispatched when playhead reached first frame of sequence */
// [Event(name="typeSequenceStart", type="starling.events.Event")]

/** Dispatched when playhead reached end frame of sequence */
// [Event(name="typeSequenceEnd", type="starling.events.Event")]

/** Dispatched whenever the movie has displayed its last frame. */
// [Event(name="complete", type="starling.events.Event")]

/// GAFMovieClip represents animation display object that is ready to be
/// used in Starling display list. It has all controls for animation familiar
/// from standard MovieClip ([play], [stop], [gotoAndPlay], etc.) and some more
/// like [loop], [nPlay], [setSequence] that helps manage playback

class GAFMovieClip extends DisplayObjectContainer implements Animatable, IGAFDisplayObject, IMaxSize {

  static final String EVENT_TYPE_SEQUENCE_START = "typeSequenceStart";
	static final String EVENT_TYPE_SEQUENCE_END = "typeSequenceEnd";

	static final Matrix HELPER_MATRIX = new Matrix.fromIdentity();

  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  Map<String, IGAFDisplayObject> _displayObjectsMap;
  Map<String, GAFPixelMaskDisplayObject> _pixelMasksMap;

  List<IGAFDisplayObject> _displayObjectsList;
  List<IGAFImage> _imagesList;
  List<GAFMovieClip> _mcVector;
  List<GAFPixelMaskDisplayObject> _pixelMasksList;

  CAnimationSequence _playingSequence;
  Rectangle _timelineBounds;
  Point _maxSize;
  //QuadBatch _boundsAndPivot;
  GAFTimelineConfig _config;
  GAFTimeline _gafTimeline;

  bool _loop = true;
  bool _skipFrames = true;
  bool _reseted;
  bool _masked;
  bool _inPlay;
  bool _hidden;
  bool _reverse;
  bool _started;
  bool _disposed;
  bool _hasFilter;
  bool _useClipping;
  bool _alphaLessMax;

  num _scale;
  num _contentScaleFactor;
  num _currentTime = 0;
  // Hold the current time spent animating
  num _lastFrameTime = 0;
  num _frameDuration;

  int _nextFrame;
  int _startFrame;
  int _finalFrame;
  int _currentFrame;
  int _totalFrames;

  CFilter _filterConfig;
  num _filterScale;

  bool _pivotChanged;
  bool _orientationChanged;

  // --------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  /// Creates a new GAFMovieClip instance.
  ///
  /// @param gafTimeline <code>GAFTimeline</code> from what <code>GAFMovieClip</code> will be created
  /// @param fps defines the frame rate of the movie clip. If not set - the stage config frame rate will be used instead.
  /// @param addToJuggler if <code>true - GAFMovieClip</code> will be added to <code>Starling.juggler</code>
  /// and removed automatically on <code>dispose</code>

 GAFMovieClip(GAFTimeline gafTimeline, [int fps]) {

   _gafTimeline = gafTimeline;
   _config = gafTimeline.config;
   _scale = gafTimeline.scale;
   _contentScaleFactor = gafTimeline.contentScaleFactor;

   _initialize(gafTimeline.textureAtlas, gafTimeline.gafAsset);

   if (_config.bounds != null) {
     _timelineBounds = _config.bounds.clone();
   }

   if (fps != null) {
     this.fps = fps;
   }

   _draw();
 }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
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

  /*
  /// Shows mask display object that exists with the specified ID.
  /// Used for debug purposes only!

  void showMaskByID(String id) {

    IGAFDisplayObject maskObject = _pixelMasksDictionary[id];
    DisplayObject maskAsDisplayObject = maskObject as DisplayObject;
    GAFPixelMaskDisplayObject pixelMaskObject = this._pixelMasksDictionary[id];

    if (maskObject != null && pixelMaskObject != null) {

      CAnimationFrame frameConfig = _config.animationConfigFrames.frames[this._currentFrame];
      CAnimationFrameInstance maskInstance = frameConfig.getInstanceByID(id);

      if (maskInstance != null) {
        this.getTransformMatrix(maskObject as IGAFDisplayObject, HELPER_MATRIX);
        maskInstance.applyTransformMatrix(maskObject.transformationMatrix, HELPER_MATRIX, this._scale);
        maskObject.invalidateOrientation();
      }

      ////////////////////////////////

      CFilter cFilter = new CFilter();
      List<num> cmf = new List<num>(20)..setAll(0, [1, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]);
      cFilter.addColorMatrixFilter(cmf);

      GAFFilter gafFilter = new GAFFilter();
      gafFilter.setConfig(cFilter, this._scale);

      maskAsDisplayObject.filter = gafFilter;

      ////////////////////////////////

      pixelMaskObject.pixelMask = null;
      this.addChild(maskAsDisplayObject);
    } else {
      print("WARNING: mask object is missing. It might be disposed.");
    }
  }

  /// Hides mask display object that previously has been shown using <code>showMaskByID</code> method.
  /// Used for debug purposes only!
  ///
  /// @param id Mask ID

  void hideMaskByID(String id) {

    IGAFDisplayObject maskObject = this._displayObjectsMap[id];
    DisplayObject maskAsDisplayObject = maskObject as DisplayObject;
    GAFPixelMaskDisplayObject pixelMaskObject = this._pixelMasksMap[id];
    if (maskObject != null && pixelMaskObject != null)
    {
      maskAsDisplayObject.filter = null;
      CAnimationFrame frameConfig = this._config.animationConfigFrames.frames[this._currentFrame];
      CAnimationFrameInstance maskInstance = frameConfig.getInstanceByID(id);
      if( maskInstance != null)
      {
        this.getTransformMatrix(maskObject as IGAFDisplayObject, HELPER_MATRIX);
        maskInstance.applyTransformMatrix(maskObject.transformationMatrix, HELPER_MATRIX, this._scale);
        maskObject.invalidateOrientation();
      }

      if (maskObject.parent == this)
      {
        this.removeChild(maskAsDisplayObject);
      }
      pixelMaskObject.pixelMask = maskAsDisplayObject;
    }
    else
    {
      print("WARNING: mask object is missing. It might be disposed.");
    }
  }

  */

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
    var sequences = _config.animationSequences;
    var sequence = sequences.getSequenceByFrame(this.currentFrame);
    return sequence?.id;
  }

  /// Set sequence to play
  ///
  /// @param id Sequence ID
  /// @param play Play or not immediately. <code>true</code> - starts playing from sequence start frame. <code>false</code> - go to sequence start frame and stop
  /// @return sequence to play

  CAnimationSequence setSequence(String id, [bool play = true]) {

    _playingSequence = _config.animationSequences.getSequenceByID(id);

    if (_playingSequence != null) {
      int startFrame = _reverse ? _playingSequence.endFrameNo - 1 : _playingSequence.startFrameNo;
      if( play) {
        this.gotoAndPlay(startFrame);
      } else {
        this.gotoAndStop(startFrame);
      }
    }

    return this._playingSequence;
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

    for (int i = 0; applyToAllChildren && i < _mcVector.length; i++) {
      _mcVector[i]._started = true;
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

    for (int i = 0; applyToAllChildren && i < _mcVector.length; i++) {
      _mcVector[i]._started = false;
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

    for (int i = 0; i < _mcVector.length; i++) {
      _mcVector[i].loop = loop;
    }
  }

  /// Advances all objects by a certain time (in seconds).
  ///
  /// @see starling.animation.IAnimatable

  bool advanceTime(num passedTime) {

    if (_disposed) {
      print("WARNING: GAFMovieClip is disposed but is not removed from the Juggler");
      return false;
    } else if (this._config.disposed) {
      this.dispose();
      return false;
    }

    if (_inPlay && _frameDuration != double.INFINITY) {

      _currentTime += passedTime;

      int framesToPlay = ((_currentTime - _lastFrameTime) / _frameDuration).round();

      if (_skipFrames) {
        //here we skip the drawing of all frames to be played right now, but the last one
        for (int i = 0; i < framesToPlay; ++i) {
          if (_inPlay) {
            _changeCurrentFrame((i + 1) != framesToPlay);
          } else {
            //if a playback was interrupted by some action or an event
            if (!this._disposed) _draw();
            break;
          }
        }
      } else if (framesToPlay > 0) {
        _changeCurrentFrame(false);
      }
    }

    if (_mcVector != null) {
      for (int i = 0; i < _mcVector.length; i++) {
        _mcVector[i].advanceTime(passedTime);
      }
    }

    return true;
  }

  /*
  /// Shows bounds of a whole animation with a pivot point.
  /// Used for debug purposes.

  void showBounds(bool value) {
    if (this._config.bounds != null)
    {
      if (!this._boundsAndPivot)
      {
        this._boundsAndPivot = new QuadBatch();
        this.updateBounds(this._config.bounds);
      }

      if( value != null)
      {
        this.addChild(this._boundsAndPivot);
      }
      else
      {
        this.removeChild(this._boundsAndPivot);
      }
    }
  }
  */

  void setFilterConfig(CFilter value, [num scale = 1]) {
    /*
    if (this._filterConfig != value || this._filterScale != scale)
    {
      if( value != null)
      {
        this._filterConfig = value;
        this._filterScale = scale;
        GAFFilter gafFilter;
        if (this.filter != null)
        {
          if (this.filter is GAFFilter)
          {
            gafFilter = this.filter as GAFFilter;
          }
          else
          {
            this.filter.dispose();
            gafFilter = new GAFFilter();
          }
        }
        else
        {
          gafFilter = new GAFFilter();
        }

        gafFilter.setConfig(this._filterConfig, this._filterScale);
        this.filter = gafFilter;
      }
      else
      {
        if (this.filter != null)
        {
          this.filter.dispose();
          this.filter = null;
        }
        this._filterConfig = null;
        this._filterScale = null;
      }
    }
    */
  }

  /** @ */
  void invalidateOrientation() {
    _orientationChanged = true;
  }

  /// Creates a new instance of GAFMovieClip.

  GAFMovieClip copy() {
    return new GAFMovieClip(_gafTimeline, this.fps);
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  // --------------------------------------------------------------------------

  void _gotoAndStop(dynamic frame) {
    _checkAndSetCurrentFrame(frame);
    _stop();
  }

  void _play([bool applyToAllChildren = false, bool calledByUser = false]) {

    if (_inPlay && !applyToAllChildren) return;

    if (this._totalFrames > 1) {
      _inPlay = true;
    }

    if (applyToAllChildren && _config.animationConfigFrames.frames.length > 0) {

      CAnimationFrame frameConfig = _config.animationConfigFrames.frames[_currentFrame];

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

        } else if (child is GAFPixelMaskDisplayObject) {

          for (var subChild in child.children) {
            if (subChild is GAFMovieClip) {
              if (calledByUser) {
                subChild.play(true);
              } else {
                subChild._play(true);
              }
            }
          }

          if (child.pixelMask is GAFMovieClip) {
            if (calledByUser) {
              child.pixelMask.play(true);
            } else {
              child.pixelMask._play(true);
            }
          }
        }
      }
    }

    _runActions();
    _reseted = false;
  }

  void _stop([bool applyToAllChildren = false, bool calledByUser = false]) {

    _inPlay = false;

    if (applyToAllChildren && _config.animationConfigFrames.frames.length > 0) {

      for (var child in this.children) {

        if (child is GAFMovieClip) {

          if (calledByUser) {
            child.stop(true);
          } else {
            child._stop(true);
          }

        } else if (child is GAFPixelMaskDisplayObject) {

          for (var subChild in child.children) {
            if (subChild is GAFMovieClip) {
              if (calledByUser) {
                subChild.stop(true);
              } else {
                subChild._stop(true);
              }
            }
          }

          if (child.pixelMask is GAFMovieClip) {
            if (calledByUser) {
              child.pixelMask.stop(true);
            } else {
              child.pixelMask._stop(true);
            }
          }
        }
      }
    }
  }

  void _checkPlaybackEvents() {

    if (this.hasEventListener(EVENT_TYPE_SEQUENCE_START)) {
      var sequence = _config.animationSequences.getSequenceStart(_currentFrame + 1);
      if (sequence != null) dispatchEventWith(EVENT_TYPE_SEQUENCE_START, false, sequence);
    }

    if (this.hasEventListener(EVENT_TYPE_SEQUENCE_END)) {
      var sequence = this._config.animationSequences.getSequenceEnd(_currentFrame + 1);
      if (sequence != null) dispatchEventWith(EVENT_TYPE_SEQUENCE_END, false, sequence);
    }

    if (this.hasEventListener(Event.COMPLETE)) {
      if (_currentFrame == _finalFrame) dispatchEventWith(Event.COMPLETE);
    }
  }

  void _runActions() {

    if (_config.animationConfigFrames.frames.length == 0) return;

    var actions = _config.animationConfigFrames.frames[_currentFrame].actions;

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
              switch (action.params.length) {
                case 4:
                  Map data = action.params[3];
                case 3:
                // cancelable param is not used
                case 2:
                  bool bubbles = (action.params[1] == "true" ? true : false);
                  break;
              }
              this.dispatchEventWith(type, bubbles, data);
            }

            if (type == CSound.GAF_PLAY_SOUND && GAF.autoPlaySounds) {
              _gafTimeline.startSound(this.currentFrame);
            }

            break;
        }
      }
    }
  }

  void _checkAndSetCurrentFrame(dynamic frame) {

    if (frame is int) {
      if (frame > _totalFrames) frame = _totalFrames;
    } else if (frame is String) {
      String label = frame;
      frame = _config.animationSequences.getStartFrameNo(label);
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
      //actions may interrupt playback and lead to content disposition
      if (!_disposed) _draw();
    }
  }

  void _clearDisplayList() {
    this.removeChildren();
    _pixelMasksMap.forEach((k,v) => v.removeChildren());
  }

  void _draw() {

    if (_config.debugRegions != null) {

      // Non optimized way when there are debug regions
      _clearDisplayList();

    } else {

      // Just hide the children to avoid dispatching a lot of events and alloc temporary arrays
      _displayObjectsMap.forEach((k,v) => v.alpha = 0);

      for (int i = 0; i < _mcVector.length; i++) {
        _mcVector[i]._hidden = true;
      }
    }

    List<CAnimationFrame> frames = this._config.animationConfigFrames.frames;

    if (frames.length > this._currentFrame) {

      int maskIndex = 0;
      GAFMovieClip movieClip = null;
//      GAFPixelMaskDisplayObject pixelMaskObject = null;

      Map animationObjectsMap = _config.animationObjects.animationObjectsMap;
      CAnimationFrame frameConfig = frames[_currentFrame];

      for (var instance in frameConfig.instances) {

        if (_displayObjectsMap.containsKey(instance.id) == false) continue;

        var displayObject = _displayObjectsMap[instance.id];
        var objectPivotMatrix = _getTransformMatrix(displayObject, HELPER_MATRIX);
        movieClip = displayObject is GAFMovieClip ? displayObject : null;

        if (movieClip != null) {
          if (movieClip.alpha < 0) {
            movieClip._reset();
          } else if (movieClip._reseted && movieClip._started) {
            movieClip._play(true);
          }
          movieClip._hidden = false;
        }

        if (instance.alpha <= 0) continue;

        displayObject.alpha = instance.alpha;

        //if display object is not a mask
        if (animationObjectsMap[instance.id].mask == false) {

          //if display object is under mask
          if (false && instance.maskID != null) {

            // TODO: fix this
            /*
            pixelMaskObject = _pixelMasksMap[instance.maskID];
            if (pixelMaskObject != null) {
              pixelMaskObject.addChild(displayObject);
              maskIndex++;

              instance.applyTransformMatrix(displayObject.transformationMatrix, objectPivotMatrix, _scale);
              displayObject.invalidateOrientation();
              displayObject.setFilterConfig(null);
              if (maskIndex == 1) this.addChild(pixelMaskObject);
            }
            */

          } else  {

            // TODO: fix this

            //if display object is not masked
            //if (pixelMaskObject != null ) {
            //  maskIndex = 0;
            //  pixelMaskObject = null;
            //}

            instance.applyTransformMatrix(displayObject.transformationMatrix, objectPivotMatrix, _scale);
            displayObject.invalidateOrientation();
            displayObject.setFilterConfig(instance.filter, this._scale);

            this.addChild(displayObject as DisplayObject);
          }

          if (movieClip != null && movieClip._started) {
            movieClip._play(true);
          }

          /*
          if (DebugUtility.RENDERING_DEBUG && displayObject is IGAFDebug)
          {
            List<int> colors = DebugUtility.getRenderingDifficultyColor(
                instance, this._alphaLessMax, this._masked, this._hasFilter);
            (displayObject as IGAFDebug).debugColors = colors;
          }
          */

        } else {

          maskIndex = 0;

          if (_displayObjectsMap.containsKey(instance.id)) {

            IGAFDisplayObject maskObject = _displayObjectsMap[instance.id];
            CAnimationFrameInstance maskInstance = frameConfig.getInstanceByID(instance.id);

            if (maskInstance != null) {
              _getTransformMatrix(maskObject, HELPER_MATRIX);
              maskInstance.applyTransformMatrix(maskObject.transformationMatrix, HELPER_MATRIX, this._scale);
              maskObject.invalidateOrientation();
            } else {
              throw new StateError("Unable to find mask with ID " + instance.id);
            }

            if (maskObject is GAFMovieClip) {
              if (maskObject._started) movieClip._play(true);
            }
          }
          /*else
          {
            throw new StateError("Unable to find mask with ID " + instance.id);
          }*/
        }
      }
    }

    _checkPlaybackEvents();
  }

  void _reset() {

    _gotoAndStop((_reverse ? _finalFrame : _startFrame) + 1);
    _reseted = true;
    _currentTime = 0;
    _lastFrameTime = 0;

    for(int i = 0; i < _mcVector.length; i++) {
      _mcVector[i]._reset();
    }
  }

  Matrix _getTransformMatrix(IGAFDisplayObject displayObject, [Matrix matrix = null]) {
    if (matrix == null) matrix = new Matrix.fromIdentity();
    matrix.copyFrom(displayObject.pivotMatrix);
    return matrix;
  }

  void _initialize(CTextureAtlas textureAtlas, GAFAsset gafAsset) {

    _displayObjectsMap = {};
    _displayObjectsList = [];
    _pixelMasksMap = {};
    _pixelMasksList = [];
    _imagesList = [];
    _mcVector = [];

    _currentFrame = 0;
    _totalFrames = this._config.framesCount;

    this.fps = _config.stageConfig != null ? _config.stageConfig.fps : 25;

    Map animationObjectsMap = _config.animationObjects.animationObjectsMap;

    DisplayObject displayObject;
    for (CAnimationObject animationObjectConfig in animationObjectsMap.values) {

      switch (animationObjectConfig.type) {

        case CAnimationObject.TYPE_TEXTURE:
          IGAFTexture texture = textureAtlas.getTexture(animationObjectConfig.regionID);
          if (texture is GAFScale9Texture && !animationObjectConfig.mask) {
            // GAFScale9Image doesn't work as mask
            displayObject = new GAFScale9Image(texture as GAFScale9Texture);
          } else {
            displayObject = new GAFImage(texture);
            //(displayObject as GAFImage)//.smoothing = this._smoothing; //not supported in StageXL
          }
          break;

        case CAnimationObject.TYPE_TEXTFIELD:
          CTextFieldObject tfObj = this._config.textFields.textFieldObjectsMap[animationObjectConfig.regionID];
          displayObject = new GAFTextField(tfObj, this._scale, this._contentScaleFactor);
          break;

        case CAnimationObject.TYPE_TIMELINE:
          GAFTimeline timeline = gafAsset._getGAFTimelineByID(animationObjectConfig.regionID);
          displayObject = new GAFMovieClip(timeline, this.fps);
          break;
      }

      if (animationObjectConfig.maxSize != null && displayObject is IMaxSize) {
        Point maxSize = new Point(
            animationObjectConfig.maxSize.x * this._scale,
            animationObjectConfig.maxSize.y * this._scale);
        (displayObject as IMaxSize).maxSize = maxSize;
      }

      _addDisplayObject(animationObjectConfig.instanceID, displayObject);

      /*
      if (animationObjectConfig.mask) {
        var pixelMaskDisplayObject = new GAFPixelMaskDisplayObject(this._gafTimeline.contentScaleFactor);
        pixelMaskDisplayObject.pixelMask = displayObject;
        _addDisplayObject(animationObjectConfig.instanceID, pixelMaskDisplayObject);
      }
      */

      if (_config.namedParts != null) {
        String instanceName = _config.namedParts[animationObjectConfig.instanceID];
        if (instanceName != null) {
          this[_config.namedParts[animationObjectConfig.instanceID]] = displayObject;
          displayObject.name = instanceName;
        }
      }
    }
  }

  void _addDisplayObject(String id, DisplayObject displayObject) {

    if (displayObject is GAFPixelMaskDisplayObject) {

      _pixelMasksMap[id] = displayObject;
      _pixelMasksList.add(displayObject);

    } else if (displayObject is IGAFDisplayObject){

      _displayObjectsMap[id] = displayObject;
      _displayObjectsList.add(displayObject);

      if (displayObject is IGAFImage) {
        _imagesList.add(displayObject as IGAFImage);
      } else if (displayObject is GAFMovieClip) {
        _mcVector.add(displayObject);
      }
    }
  }

  void updateBounds(Rectangle bounds) {
    /*
    this._boundsAndPivot.reset();
    //bounds
    if (bounds.width > 0 &&  bounds.height > 0)
    {
      Quad quad = new Quad(bounds.width * this._scale, 2, 0xff0000);
      quad.x = bounds.x * this._scale;
      quad.y = bounds.y * this._scale;
      this._boundsAndPivot.addQuad(quad);
      quad = new Quad(bounds.width * this._scale, 2, 0xff0000);
      quad.x = bounds.x * this._scale;
      quad.y = bounds.bottom * this._scale - 2;
      this._boundsAndPivot.addQuad(quad);
      quad = new Quad(2, bounds.height * this._scale, 0xff0000);
      quad.x = bounds.x * this._scale;
      quad.y = bounds.y * this._scale;
      this._boundsAndPivot.addQuad(quad);
      quad = new Quad(2, bounds.height * this._scale, 0xff0000);
      quad.x = bounds.right * this._scale - 2;
      quad.y = bounds.y * this._scale;
      this._boundsAndPivot.addQuad(quad);
    }
    //pivot point
    quad = new Quad(5, 5, 0xff0000);
    this._boundsAndPivot.addQuad(quad);
    */
  }

  //[Inline]
  void updateTransformMatrix() {
    if (_orientationChanged) {
      this.transformationMatrix = this.transformationMatrix;
      _orientationChanged = false;
    }
  }

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  /// Removes a child at a certain index. The index positions of any display
  /// objects above the child are decreased by 1. If requested, the child
  /// will be disposed right away.
  ///
  @override
  void removeChildAt(int index, [bool dispose = false]) {

    if (dispose) {

      DisplayObject child = this.getChildAt(index);

      if (child is IGAFDisplayObject) {

        int id = _mcVector.indexOf(child);
        if (id >= 0) _mcVector.removeAt(id);

        id = _imagesList.indexOf(child);
        if (id >= 0) _imagesList.removeAt(id);

        id = this._displayObjectsList.indexOf(child);
        if (id >= 0) {
          _displayObjectsList.removeAt(id);
          for (var key in _displayObjectsMap.keys) {
            if (_displayObjectsMap[key] == child) {
              _displayObjectsMap.remove(key);
              break;
            }
          }
        }

        id = _pixelMasksList.indexOf(child);
        if (id >= 0) {
          _pixelMasksList.removeAt(id);
          for (var key in _pixelMasksMap.keys) {
            if (_pixelMasksMap[key] == child) {
              _pixelMasksMap.remove(key);
              break;
            }
          }
        }
      }
    }

    return super.removeChildAt(index);
  }

  /** Returns a child object with a certain name (non-recursively). */
  @override
  DisplayObject getChildByName(String name) {

    for (int i = 0; i < _displayObjectsList.length; ++i) {
      if (_displayObjectsList[i].name == name) {
        return _displayObjectsList[i];
      }
    }

    return super.getChildByName(name);
  }

  /// Disposes all resources of the display object instance.

  void dispose() {

    if (_disposed) return;
    this.stop();

    for (int i = 0; i < _displayObjectsList.length; i++) {
      _displayObjectsList[i].dispose();
    }

    for (int i = 0; i < _pixelMasksList.length; i++) {
      _pixelMasksList[i].dispose();
    }

    if (_boundsAndPivot != null) {
      _boundsAndPivot.dispose();
      _boundsAndPivot = null;
    }

    _displayObjectsMap = null;
    _pixelMasksMap = null;
    _displayObjectsList= null;
    _pixelMasksList= null;
    _imagesList= null;
    _gafTimeline = null;
    _mcVector= null;
    _config = null;

    this.removeFromParent();
    _disposed = true;
  }

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  void _changeCurrentFrame(bool isSkipping) {

    var resetInvisibleChildren = false;

    _nextFrame = _currentFrame + (_reverse ? -1 : 1);
    _startFrame = (_playingSequence != null? _playingSequence.startFrameNo : 1) - 1;
    _finalFrame = (_playingSequence != null ? _playingSequence.endFrameNo : _totalFrames) - 1;

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

    //actions may interrupt playback and lead to content disposition

    if (_disposed) {
      return;
    } else if (_config.disposed) {
      this.dispose();
      return;
    }

    if(isSkipping == false) {
      // Draw will trigger events if any
      _draw();
    } else {
      _checkPlaybackEvents();
    }

    if( resetInvisibleChildren) {
      //reset timelines that aren't visible
      for (var movieClip in _mcVector) {
        if (movieClip._hidden) movieClip._reset();
      }
    }
  }

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  /// Specifies the number of the frame in which the playhead is located in
  /// the timeline of the GAFMovieClip instance. First frame is "1"

  int get currentFrame  => _currentFrame + 1;

  /// The total number of frames in the GAFMovieClip instance.

  int get totalFrames => _totalFrames;

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

  /// The individual frame rate for <code>GAFMovieClip</code>. If this value
  /// is lower than stage fps -  the <code>GAFMovieClip</code> will skip frames.

  num get fps {
    if (_frameDuration == double.INFINITY) return 0;
    return 1 / this._frameDuration;
  }

  set fps(num value) {

    if (value <= 0) {
      _frameDuration = double.INFINITY;
    } else {
      _frameDuration = 1 / value;
    }

    for(var movieClip in _mcVector) {
      movieClip.fps = value;
    }
  }

  /// If <code>true</code> animation will be playing in reverse mode

  bool get reverse => _reverse;

  void set reverse(bool value) {

    _reverse = value;

    for(var movieClip in _mcVector) {
      movieClip._reverse = value;
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

    for(var movieClip in _mcVector) {
      movieClip._skipFrames = value;
    }
  }

  Matrix get pivotMatrix {
    var matrix = new Matrix.fromIdentity();
    matrix.tx = this.pivotX;
    matrix.ty = this.pivotY;
    return matrix;
  }

}
