part of stagexl_gaf;

class BinGAFAssetConfigConverter extends EventDispatcher {

  static const int SIGNATURE_GAF = 0x00474146;
  static const int SIGNATURE_GAC = 0x00474143;
  static const int HEADER_LENGTH = 36;

  //tags
  static const int TAG_END = 0;
  static const int TAG_DEFINE_ATLAS = 1;
  static const int TAG_DEFINE_ANIMATION_MASKS = 2;
  static const int TAG_DEFINE_ANIMATION_OBJECTS = 3;
  static const int TAG_DEFINE_ANIMATION_FRAMES = 4;
  static const int TAG_DEFINE_NAMED_PARTS = 5;
  static const int TAG_DEFINE_SEQUENCES = 6;
  static const int TAG_DEFINE_TEXT_FIELDS = 7; // v4.0
  static const int TAG_DEFINE_ATLAS2 = 8; // v4.0
  static const int TAG_DEFINE_STAGE = 9;
  static const int TAG_DEFINE_ANIMATION_OBJECTS2 = 10; // v4.0
  static const int TAG_DEFINE_ANIMATION_MASKS2 = 11; // v4.0
  static const int TAG_DEFINE_ANIMATION_FRAMES2 = 12; // v4.0
  static const int TAG_DEFINE_TIMELINE = 13; // v4.0
  static const int TAG_DEFINE_SOUNDS = 14; // v5.0
  static const int TAG_DEFINE_ATLAS3 = 15; // v5.0

  //filters
  static const int FILTER_DROP_SHADOW = 0;
  static const int FILTER_BLUR = 1;
  static const int FILTER_GLOW = 2;
  static const int FILTER_COLOR_MATRIX = 6;

  static final Rectangle sHelperRectangle = new Rectangle<num>(0, 0, 0, 0);
  static final Matrix sHelperMatrix = new Matrix.fromIdentity();

  String _assetID;
  ByteBufferReader _bytes;
  num _defaultScale;
  num _defaultContentScaleFactor;
  GAFAssetConfig _config;
  Map<String, Rectangle> _textureElementSizes; // Point by texture element id

  //int _time;
  bool _isTimeline;
  GAFTimelineConfig _currentTimeline;
  //bool _async;
  bool _ignoreSounds;

  // --------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  BinGAFAssetConfigConverter(String assetID, ByteBuffer bytes) {
    _bytes = new ByteBufferReader(bytes);
    _assetID = assetID;
    _textureElementSizes = new Map<String, Rectangle>();
  }

  void convert() {
    this.parseStart();
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  void parseStart() {

    _config = new GAFAssetConfig(_assetID);
    _config.compression = _bytes.readInt();
    _config.versionMajor = _bytes.readByte();
    _config.versionMinor = _bytes.readByte();
    _config.fileLength = _bytes.readUnsignedInt();

    if (_config.compression == SIGNATURE_GAC) {
      throw new StateError("TODO: Implement ZLIB decompress");
    }

    if (_config.versionMajor < 4) {

      _currentTimeline = new GAFTimelineConfig("${_config.versionMajor}.${_config.versionMinor}");
      _currentTimeline.id = "0";
      _currentTimeline.assetID = this._assetID;
      _currentTimeline.framesCount = this._bytes.readShort();
      _currentTimeline.bounds = new Rectangle<num>(_bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat());
      _currentTimeline.pivot = new Point(_bytes.readFloat(), _bytes.readFloat());
      _config.timelines.add(_currentTimeline);

    } else {

      for (int i = 0, l = _bytes.readUnsignedInt(); i < l; i++) {
        _config.scaleValues.add(_bytes.readFloat());
      }

      for (int i = 0, l = _bytes.readUnsignedInt(); i < l; i++) {
        _config.csfValues.add(_bytes.readFloat());
      }
    }

    this.readNextTag();
  }

  void checkForMissedRegions(GAFTimelineConfig timelineConfig) {

    if (timelineConfig.textureAtlas != null && timelineConfig.textureAtlas.contentScaleFactor.elements != null) {
      for (CAnimationObject ao in timelineConfig.animationObjects.animationObjectsMap.values) {
        if (ao.type == CAnimationObject.TYPE_TEXTURE && timelineConfig.textureAtlas.contentScaleFactor.elements .getElement(ao.regionID) == null) {
          timelineConfig.addWarning(WarningConstants.REGION_NOT_FOUND);
          break;
        }
      }
    }
  }

  void readNextTag() {

    int tagID = _bytes.readShort();
    int tagLength = _bytes.readUnsignedInt();

    switch (tagID) {

      case BinGAFAssetConfigConverter.TAG_DEFINE_STAGE:
        readStageConfig(_config);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS2:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS3:
        readTextureAtlasConfig(tagID);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS2:
        readAnimationMasks(tagID, _currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS2:
        readAnimationObjects(tagID, _currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_FRAMES:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_FRAMES2:
        readAnimationFrames(tagID);
        return;

      case BinGAFAssetConfigConverter.TAG_DEFINE_NAMED_PARTS:
        readNamedParts(_currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_SEQUENCES:
        readAnimationSequences(_currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_TEXT_FIELDS:
        readTextFields(_currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_SOUNDS:
        if (!_ignoreSounds) {
          readSounds(_config);
        } else {
          _bytes.position += tagLength;
        }
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_TIMELINE:
        _currentTimeline = readTimeline();
        break;

      case BinGAFAssetConfigConverter.TAG_END:
        if (_isTimeline) {
          _isTimeline = false;
        } else {
          _bytes.position = _bytes.length;
          this.endParsing();
          return;
        }
        break;

      default:
        print(WarningConstants.UNSUPPORTED_TAG);
        _bytes.position += tagLength;
        break;
    }

    readNextTag();
  }

  GAFTimelineConfig readTimeline() {

    GAFTimelineConfig timelineConfig = new GAFTimelineConfig("${_config.versionMajor}.${_config.versionMinor}");
    timelineConfig.id = _bytes.readUnsignedInt().toString();
    timelineConfig.assetID = _config.id;
    timelineConfig.framesCount = _bytes.readUnsignedInt();
    timelineConfig.bounds = new Rectangle<num>(_bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat());
    timelineConfig.pivot = new Point(_bytes.readFloat(), _bytes.readFloat());
    bool hasLinkage = _bytes.readbool();

    if (hasLinkage) {
      timelineConfig.linkage = _bytes.readUTF();
    }

    this._config.timelines.add(timelineConfig);

    this._isTimeline = true;

    return timelineConfig;
  }

  void readMaskMaxSizes() {

    for (GAFTimelineConfig timeline in this._config.timelines) {

      for (CAnimationFrame frame in timeline.animationConfigFrames.frames) {
        for (CAnimationFrameInstance frameInstance in frame.instances) {
          CAnimationObject animationObject = timeline.animationObjects.getAnimationObject(frameInstance.id);
          if (animationObject.mask) {

            if (animationObject.maxSize == null) {
              animationObject.maxSize = new Point(0, 0);
            }

            Point maxSize = animationObject.maxSize;

            if (animationObject.type == CAnimationObject.TYPE_TEXTURE) {
              sHelperRectangle.copyFrom(_textureElementSizes[animationObject.regionID]);
            } else if (animationObject.type == CAnimationObject.TYPE_TIMELINE) {
              GAFTimelineConfig maskTimeline;
              for (maskTimeline in _config.timelines) {
                if (maskTimeline.id == frameInstance.id) break;
              }
              sHelperRectangle.copyFrom(maskTimeline.bounds);
            } else if (animationObject.type == CAnimationObject.TYPE_TEXTFIELD) {
              CTextFieldObject textField = timeline.textFields.textFieldObjectsMap[animationObject.regionID];
              sHelperRectangle.setTo(-textField.pivotPoint.x, -textField.pivotPoint.y, textField.width, textField.height);
            }

            frameInstance.matrix.transformRectangle(sHelperRectangle, sHelperRectangle);
            maxSize.setTo(max(maxSize.x, (sHelperRectangle.width)).abs(), max(maxSize.y, (sHelperRectangle.height)).abs());
          }
        }
      }
    }
  }

  void endParsing() {
    //_bytes.clear();
    //_bytes = null;

    this.readMaskMaxSizes();

    int itemIndex = 0;
    if (_config.defaultScale is! num) {
      if (_defaultScale is num) {
        itemIndex = MathUtility.getItemIndex(_config.scaleValues, _defaultScale);
        if (itemIndex < 0) {
          parseError("${_defaultScale} + ${ErrorConstants.SCALE_NOT_FOUND}");
          return;
        }
      }
      _config.defaultScale = _config.scaleValues[itemIndex];
    }

    if (_config.defaultContentScaleFactor is! num) {
      itemIndex = 0;
      if (_defaultContentScaleFactor is num) {
        itemIndex = MathUtility.getItemIndex(_config.csfValues, _defaultContentScaleFactor);
        if (itemIndex < 0) {
          parseError("${_defaultContentScaleFactor} + ${ErrorConstants.CSF_NOT_FOUND}");
          return;
        }
      }
      _config.defaultContentScaleFactor = _config.csfValues[itemIndex];
    }

    for (CTextureAtlasScale textureAtlasScale in _config.allTextureAtlases) {
      for (CTextureAtlasCSF textureAtlasCSF in textureAtlasScale.allContentScaleFactors) {
        if (MathUtility.equals(_config.defaultContentScaleFactor, textureAtlasCSF.csf)) {
          textureAtlasScale.contentScaleFactor = textureAtlasCSF;
          break;
        }
      }
    }

    for (GAFTimelineConfig timelineConfig in _config.timelines) {
      timelineConfig.allTextureAtlases = _config.allTextureAtlases;
      for (CTextureAtlasScale textureAtlasScale in _config.allTextureAtlases) {
        if (MathUtility.equals(_config.defaultScale, textureAtlasScale.scale)) {
          timelineConfig.textureAtlas = textureAtlasScale;
        }
      }

      timelineConfig.stageConfig = this._config.stageConfig;
      this.checkForMissedRegions(timelineConfig);
    }

    this.dispatchEvent(new Event(Event.COMPLETE));
  }

  void readAnimationFrames(int tagID, [int startIndex = 0, num framesCount, CAnimationFrame prevFrame]) {

    if (framesCount is! num) {
      framesCount = _bytes.readUnsignedInt();
    }

    int filterLength = 0;
    int frameNumber = 0;
    int statesCount = 0;
    int filterType = 0;
    int stateID = 0;
    int zIndex = 0;
    num alpha = 1.0;
    Matrix matrix = new Matrix.fromIdentity();
    String maskID = "";
    bool hasMask = false;
    bool hasEffect = false;
    bool hasActions = false;
    bool hasColorTransform = false;
    bool hasChangesInDisplayList = false;

    GAFTimelineConfig timelineConfig = _config.timelines[_config.timelines.length - 1];
    CAnimationFrameInstance instance = null;
    CAnimationFrame currentFrame = null;
    CBlurFilterData blurFilter = null;
    Map blurFilters = {};
    CFilter filter = null;

    for (int i = startIndex; i < framesCount; i++) {

      frameNumber = _bytes.readUnsignedInt();

      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_FRAMES) {
        hasChangesInDisplayList = true;
        hasActions = false;
      } else {
        hasChangesInDisplayList = _bytes.readbool();
        hasActions = _bytes.readbool();
      }

      if (prevFrame != null) {
        currentFrame = prevFrame.clone(frameNumber);
        for (int n = prevFrame.frameNumber + 1; n < currentFrame.frameNumber; n++) {
          timelineConfig.animationConfigFrames.addFrame(prevFrame.clone(n));
        }
      } else {
        currentFrame = new CAnimationFrame(frameNumber);
        if (currentFrame.frameNumber > 1) {
          for (int n = 1; n < currentFrame.frameNumber; n++) {
            timelineConfig.animationConfigFrames.addFrame(new CAnimationFrame(n));
          }
        }
      }

      if (hasChangesInDisplayList) {

        statesCount = _bytes.readUnsignedInt();

        for (int j = 0; j < statesCount; j++) {
          hasColorTransform = _bytes.readbool();
          hasMask = _bytes.readbool();
          hasEffect = _bytes.readbool();

          stateID = _bytes.readUnsignedInt();
          zIndex = _bytes.readInt();
          alpha = _bytes.readFloat();
          matrix = new Matrix(_bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat());
          filter = null;

          if (hasColorTransform) {
            List<num> params = [_bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat()];
            filter ??= new CFilter();
            filter.addColorTransform(params);
          }

          if (hasEffect) {
            filter ??= new CFilter();
            filterLength = _bytes.readByte();

            for (int k = 0; k < filterLength; k++) {
              filterType = _bytes.readUnsignedInt();
              String warning;

              switch (filterType) {

                case BinGAFAssetConfigConverter.FILTER_DROP_SHADOW:
                  warning = readDropShadowFilter(filter);
                  break;

                case BinGAFAssetConfigConverter.FILTER_BLUR:
                  warning = readBlurFilter(filter);
                  blurFilter = filter.filterConfigs[filter.filterConfigs.length - 1] as CBlurFilterData;
                  if (blurFilter.blurX >= 2 && blurFilter.blurY >= 2) {
                    if (!blurFilters.containsKey(stateID)) {
                      blurFilters[stateID] = blurFilter;
                    }
                  } else {
                    blurFilters[stateID] = null;
                  }
                  break;

                case BinGAFAssetConfigConverter.FILTER_GLOW:
                  warning = readGlowFilter(filter);
                  break;

                case BinGAFAssetConfigConverter.FILTER_COLOR_MATRIX:
                  warning = readColorMatrixFilter(filter);
                  break;

                default:
                  print(WarningConstants.UNSUPPORTED_FILTERS);
                  break;
              }

              timelineConfig.addWarning(warning);
            }
          }

          if (hasMask) {
            maskID = _bytes.readUnsignedInt().toString();
          } else {
            maskID = "";
          }

          instance = new CAnimationFrameInstance(stateID.toString());
          instance.update(zIndex, matrix, alpha, maskID, filter);

          if (maskID.length > 0 && filter != null) {
            timelineConfig.addWarning(WarningConstants.FILTERS_UNDER_MASK);
          }

          currentFrame.addInstance(instance);
        }

        currentFrame.sortInstances();
      }

      if (hasActions) {

        for (int a = 0, count = _bytes.readUnsignedInt(); a < count; a++) {

          CFrameAction action = new CFrameAction();
          action.type = _bytes.readUnsignedInt();
          action.scope = _bytes.readUTF();

          int paramsLength = _bytes.readUnsignedInt();
          int paramsOffset = _bytes.position;
          while (_bytes.position < paramsOffset + paramsLength) {
            action.params.add(_bytes.readUTF());
          }

          if (action.type == CFrameAction.DISPATCH_EVENT &&
              action.params[0] == CSound.GAF_PLAY_SOUND &&
              action.params.length > 3) {
            if (_ignoreSounds) {
              continue; //do not add sound events if they're ignored
            }
            Map data = JSON.decode(action.params[3]);
            timelineConfig.addSound(data, frameNumber);
          }

          currentFrame.addAction(action);
        }
      }

      timelineConfig.animationConfigFrames.addFrame(currentFrame);

      prevFrame = currentFrame;
    } //end loop

    for (int n = prevFrame.frameNumber + 1; n <= timelineConfig.framesCount; n++) {
      timelineConfig.animationConfigFrames.addFrame(prevFrame.clone(n));
    }

    for (currentFrame in timelineConfig.animationConfigFrames.frames) {
      for (instance in currentFrame.instances) {
        if (blurFilters.containsKey(instance.id) && instance.filter != null) {
          blurFilter = instance.filter.getBlurFilter();
          if (blurFilter != null && blurFilter.resolution == 1) {
            blurFilter.blurX *= 0.5;
            blurFilter.blurY *= 0.5;
            blurFilter.resolution = 0.75;
          }
        }
      }
    }

    readNextTag();
  }

  void readTextureAtlasConfig(int tagID) {

    int i;
    int j;

    num scale = _bytes.readFloat();

    if (_config.scaleValues.indexOf(scale) == -1) {
      _config.scaleValues.add(scale);
    }

    CTextureAtlasScale textureAtlas = this.getTextureAtlasScale(scale);

    /////////////////////

    CTextureAtlasCSF contentScaleFactor;
    int atlasLength = _bytes.readByte();

    CTextureAtlasElements elements;
    if (textureAtlas.allContentScaleFactors.length > 0) {
      elements = textureAtlas.allContentScaleFactors[0].elements;
    }

    if (elements == null) {
      elements = new CTextureAtlasElements();
    }

    for (i = 0; i < atlasLength; i++) {

      String atlasID = _bytes.readUnsignedInt().toString();
      int sourceLength = _bytes.readByte();

      for (j = 0; j < sourceLength; j++) {
        String source = _bytes.readUTF();
        double csf = _bytes.readFloat();

        if (_config.csfValues.indexOf(csf) == -1) {
          _config.csfValues.add(csf);
        }

        contentScaleFactor = this.getTextureAtlasCSF(scale, csf);
        updateTextureAtlasSources(contentScaleFactor, atlasID, source);

        if (contentScaleFactor.elements == null) {
          contentScaleFactor.elements = elements;
        }
      }
    }

    /////////////////////

    int elementsLength = _bytes.readUnsignedInt();
    CTextureAtlasElement element = null;
    bool hasScale9Grid = false;
    Rectangle scale9Grid = null;
    Point pivot = null;
    Point topLeft = null;
    num elementScaleX = 1.0;
    num elementScaleY = 1.0;
    num elementWidth = 0;
    num elementHeight = 0;
    bool rotation = false;
    String linkageName = "";

    for (i = 0; i < elementsLength; i++) {
      pivot = new Point(_bytes.readFloat(), _bytes.readFloat());
      topLeft = new Point(_bytes.readFloat(), _bytes.readFloat());
      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS ||
          tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS2) {
        elementScaleX = elementScaleY = _bytes.readFloat();
      }

      double elementWidth = _bytes.readFloat();
      double elementHeight = _bytes.readFloat();
      String atlasID = _bytes.readUnsignedInt().toString();
      String elementAtlasID = _bytes.readUnsignedInt().toString();

      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS2 ||
          tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS3) {
        hasScale9Grid = _bytes.readbool();
        if (hasScale9Grid) {
          scale9Grid = new Rectangle(_bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat(), _bytes.readFloat());
        } else {
          scale9Grid = null;
        }
      }

      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS3) {
        elementScaleX = _bytes.readFloat();
        elementScaleY = _bytes.readFloat();
        rotation = _bytes.readbool();
        linkageName = _bytes.readUTF();
      }

      if (elements.getElement(elementAtlasID) == null) {
        element = new CTextureAtlasElement(elementAtlasID.toString(), atlasID.toString());
        element.region = new Rectangle((topLeft.x).round(), (topLeft.y), elementWidth, elementHeight).align();
        element.pivotMatrix = new Matrix(1 / elementScaleX, 0, 0, 1 / elementScaleY, -pivot.x / elementScaleX, -pivot.y / elementScaleY);
        element.scale9Grid = scale9Grid;
        element.linkage = linkageName;
        element.rotated = rotation;
        elements.addElement(element);

        if (element.rotated) {
          sHelperRectangle.setTo(0, 0, elementHeight, elementWidth);
        } else {
          sHelperRectangle.setTo(0, 0, elementWidth, elementHeight);
        }
        sHelperMatrix.copyFrom(element.pivotMatrix);
        num invertScale = 1 / scale;
        sHelperMatrix.scale(invertScale, invertScale);
        sHelperMatrix.transformRectangle(sHelperRectangle, sHelperRectangle);

        if (!_textureElementSizes.containsKey(elementAtlasID)) {
          _textureElementSizes[elementAtlasID] = sHelperRectangle.clone();
        } else {
          _textureElementSizes[elementAtlasID] = _textureElementSizes[elementAtlasID].boundingBox(sHelperRectangle);
        }
      }
    }
  }

  CTextureAtlasScale getTextureAtlasScale(num scale) {

    CTextureAtlasScale textureAtlasScale;
    List<CTextureAtlasScale> textureAtlasScales = _config.allTextureAtlases;

    int l = textureAtlasScales.length;
    for (int i = 0; i < l; i++) {
      if (MathUtility.equals(textureAtlasScales[i].scale, scale)) {
        textureAtlasScale = textureAtlasScales[i];
        break;
      }
    }

    if (textureAtlasScale == null) {
      textureAtlasScale = new CTextureAtlasScale();
      textureAtlasScale.scale = scale;
      textureAtlasScales.add(textureAtlasScale);
    }

    return textureAtlasScale;
  }

  CTextureAtlasCSF getTextureAtlasCSF(num scale, num csf) {

    CTextureAtlasScale textureAtlasScale = this.getTextureAtlasScale(scale);
    CTextureAtlasCSF textureAtlasCSF = textureAtlasScale.getTextureAtlasForCSF(csf);

    if (textureAtlasCSF == null) {
      textureAtlasCSF = new CTextureAtlasCSF(csf, scale);
      textureAtlasScale.allContentScaleFactors.add(textureAtlasCSF);
    }

    return textureAtlasCSF;
  }

  void updateTextureAtlasSources(CTextureAtlasCSF textureAtlasCSF, String atlasID, String source) {

    CTextureAtlasSource textureAtlasSource;
    List<CTextureAtlasSource> textureAtlasSources = textureAtlasCSF.sources;

    int l = textureAtlasSources.length;
    for (int i = 0; i < l; i++) {
      if (textureAtlasSources[i].id == atlasID) {
        textureAtlasSource = textureAtlasSources[i];
        break;
      }
    }

    if (textureAtlasSource == null) {
      textureAtlasSource = new CTextureAtlasSource(atlasID, source);
      textureAtlasSources.add(textureAtlasSource);
    }
  }

  void parseError(String message) {
    if (this.hasEventListener(ErrorEvent.ERROR)) {
      this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
    } else {
      throw new StateError(message);
    }
  }

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  GAFAssetConfig get config  => _config;

  String get assetID => _assetID;

  set ignoreSounds(bool ignoreSounds) {
    _ignoreSounds = ignoreSounds;
  }

  //--------------------------------------------------------------------------
  //
  //  STATIC METHODS
  //
  //--------------------------------------------------------------------------

  void readStageConfig(GAFAssetConfig config) {
    CStage stageConfig = new CStage();
    stageConfig.fps = _bytes.readByte();
    stageConfig.color = _bytes.readInt();
    stageConfig.width = _bytes.readUnsignedShort();
    stageConfig.height = _bytes.readUnsignedShort();
    config.stageConfig = stageConfig;
  }

  String readDropShadowFilter(CFilter filter) {
    List<num> color = readColorValue();
    num blurX = _bytes.readFloat();
    num blurY = _bytes.readFloat();
    num angle = _bytes.readFloat();
    num distance = _bytes.readFloat();
    num strength = _bytes.readFloat();
    bool inner = _bytes.readbool();
    bool knockout = _bytes.readbool();

    return filter.addDropShadowFilter(blurX, blurY, color[1], color[0], angle,
        distance, strength, inner, knockout);
  }

  String readBlurFilter(CFilter filter) {
    return filter.addBlurFilter(_bytes.readFloat(), _bytes.readFloat());
  }

  String readGlowFilter(CFilter filter) {
    List<num> color = readColorValue();
    num blurX = _bytes.readFloat();
    num blurY = _bytes.readFloat();
    num strength = _bytes.readFloat();
    bool inner = _bytes.readbool();
    bool knockout = _bytes.readbool();
    return filter.addGlowFilter(blurX, blurY, color[1], color[0], strength, inner, knockout);
  }

  String readColorMatrixFilter(CFilter filter) {
    List<num> matrix = new List<num>(20);
    for (int i = 0; i < 20; i++) {
      matrix[i] = _bytes.readFloat();
    }

    return filter.addColorMatrixFilter(matrix);
  }

  List<num> readColorValue() {
    int argbValue = _bytes.readUnsignedInt();
    num alpha = ((argbValue >> 24) & 0xFF) / 255.0;
    int color = argbValue & 0xFFFFFF;
    return [alpha, color];
  }

  void readAnimationMasks(int tagID, GAFTimelineConfig timelineConfig) {

    int length = _bytes.readUnsignedInt();
    int objectID;
    int regionID;
    String type;

    for (int i = 0; i < length; i++) {
      objectID = _bytes.readUnsignedInt();
      regionID = _bytes.readUnsignedInt();
      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS) {
        type = CAnimationObject.TYPE_TEXTURE;
      } else // BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS2
      {
        type = getAnimationObjectTypeString(_bytes.readUnsignedShort());
      }
      timelineConfig.animationObjects.addAnimationObject(new CAnimationObject(
          objectID.toString(), regionID.toString(), type, true));
    }
  }

  String getAnimationObjectTypeString(int type) {
    String typeString = CAnimationObject.TYPE_TEXTURE;
    switch (type) {
      case 0: typeString = CAnimationObject.TYPE_TEXTURE; break;
      case 1: typeString = CAnimationObject.TYPE_TEXTFIELD; break;
      case 2: typeString = CAnimationObject.TYPE_TIMELINE; break;
    }
    return typeString;
  }

  void readAnimationObjects(int tagID, GAFTimelineConfig timelineConfig) {
    int length = _bytes.readUnsignedInt();
    int objectID;
    int regionID;
    String type;

    for (int i = 0; i < length; i++) {
      objectID = _bytes.readUnsignedInt();
      regionID = _bytes.readUnsignedInt();
      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS) {
        type = CAnimationObject.TYPE_TEXTURE;
      } else {
        type = getAnimationObjectTypeString(_bytes.readUnsignedShort());
      }
      timelineConfig.animationObjects.addAnimationObject(new CAnimationObject(
          objectID.toString(), regionID.toString(), type, false));
    }
  }

  void readAnimationSequences(GAFTimelineConfig timelineConfig) {
    int length = _bytes.readUnsignedInt();
    String sequenceID;
    int startFrameNo;
    int endFrameNo;

    for (int i = 0; i < length; i++) {
      sequenceID = _bytes.readUTF();
      startFrameNo = _bytes.readShort();
      endFrameNo = _bytes.readShort();
      timelineConfig.animationSequences.addSequence(
          new CAnimationSequence(sequenceID, startFrameNo, endFrameNo));
    }
  }

  void readNamedParts(GAFTimelineConfig timelineConfig) {
    timelineConfig.namedParts = {};
    int length = _bytes.readUnsignedInt();
    int partID;
    for (int i = 0; i < length; i++) {
      partID = _bytes.readUnsignedInt();
      timelineConfig.namedParts[partID] = _bytes.readUTF();
    }
  }

  void readTextFields(GAFTimelineConfig timelineConfig) {

    int length = _bytes.readUnsignedInt();
    num pivotX;
    num pivotY;
    int textFieldID;
    num width;
    num height;
    String text;
    bool embedFonts;
    bool multiline;
    bool wordWrap;
    String restrict;
    bool editable;
    bool selectable;
    bool displayAsPassword;
    int maxChars;

    TextFormat textFormat;

    for (int i = 0; i < length; i++) {
      textFieldID = _bytes.readUnsignedInt();
      pivotX = _bytes.readFloat();
      pivotY = _bytes.readFloat();
      width = _bytes.readFloat();
      height = _bytes.readFloat();

      text = _bytes.readUTF();

      embedFonts = _bytes.readbool();
      multiline = _bytes.readbool();
      wordWrap = _bytes.readbool();

      bool hasRestrict = _bytes.readbool();
      if (hasRestrict) {
        restrict = _bytes.readUTF();
      }

      editable = _bytes.readbool();
      selectable = _bytes.readbool();
      displayAsPassword = _bytes.readbool();
      maxChars = _bytes.readUnsignedInt();

      // read textFormat
      int alignFlag = _bytes.readUnsignedInt();
      String align;
      switch (alignFlag) {
        case 0: align = TextFormatAlign.LEFT; break;
        case 1: align = TextFormatAlign.RIGHT; break;
        case 2: align = TextFormatAlign.CENTER; break;
        case 3: align = TextFormatAlign.JUSTIFY; break;
        case 4: align = TextFormatAlign.START; break;
        case 5: align = TextFormatAlign.END; break;
      }

      num blockIndent = _bytes.readUnsignedInt();
      bool bold = _bytes.readbool();
      bool bullet = _bytes.readbool();
      int color = _bytes.readUnsignedInt();

      String font = _bytes.readUTF();
      int indent = _bytes.readUnsignedInt();
      bool italic = _bytes.readbool();
      bool kerning = _bytes.readbool();
      int leading = _bytes.readUnsignedInt();
      num leftMargin = _bytes.readUnsignedInt();
      num letterSpacing = _bytes.readFloat();
      num rightMargin = _bytes.readUnsignedInt();
      int size = _bytes.readUnsignedInt();

      int l = _bytes.readUnsignedInt();
      List tabStops = [];
      for (int j = 0; j < l; j++) {
        tabStops.add(_bytes.readUnsignedInt());
      }

      String target = _bytes.readUTF();
      bool underline = _bytes.readbool();
      String url = _bytes.readUTF();

      /* String display = tagContent.readUTF();*/

      //TODO AS3 TextFormat has more features. Commented out. Problem?
      textFormat = new TextFormat(font, size, color,
          bold: bold,
          italic: italic,
          underline: underline,
          align: align,
          leftMargin: leftMargin,
          rightMargin: rightMargin,
          indent: blockIndent,
          leading: leading);
      /*
       /*url, target, */
				textFormat.bullet = bullet;
				textFormat.kerning = kerning;
				//textFormat.display = display;
				textFormat.letterSpacing = letterSpacing;
				textFormat.tabStops = tabStops;
				*/
      textFormat.indent = indent;

      CTextFieldObject textFieldObject = new CTextFieldObject(textFieldID.toString(), text, textFormat, width, height);
      textFieldObject.pivotPoint.x = -pivotX;
      textFieldObject.pivotPoint.y = -pivotY;
      textFieldObject.embedFonts = embedFonts;
      textFieldObject.multiline = multiline;
      textFieldObject.wordWrap = wordWrap;
      textFieldObject.restrict = restrict;
      textFieldObject.editable = editable;
      textFieldObject.selectable = selectable;
      textFieldObject.displayAsPassword = displayAsPassword;
      textFieldObject.maxChars = maxChars;
      timelineConfig.textFields.addTextFieldObject(textFieldObject);
    }
  }

  void readSounds(GAFAssetConfig config) {
    CSound soundData;
    int count = _bytes.readShort();
    for (int i = 0; i < count; i++) {
      soundData = new CSound();
      soundData.soundID = _bytes.readShort();
      soundData.linkageName = _bytes.readUTF();
      soundData.source = _bytes.readUTF();
      soundData.format = _bytes.readByte();
      soundData.rate = _bytes.readByte();
      soundData.sampleSize = _bytes.readByte();
      soundData.stereo = _bytes.readbool();
      soundData.sampleCount = _bytes.readUnsignedInt();
      config.addSound(soundData);
    }
  }

  void set defaultScale(num defaultScale) {
    _defaultScale = defaultScale;
  }

  void set defaultCSF(num csf) {
    _defaultContentScaleFactor = csf;
  }
}
