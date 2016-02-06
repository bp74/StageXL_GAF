part of stagexl_gaf;

class BinGAFAssetConfigConverter {

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
  num _defaultScale;
  num _defaultContentScaleFactor;
  GAFAssetConfig _config;
  Map<String, Rectangle> _textureElementSizes; // Point by texture element id

  ByteData _data;
  int _dataPosition = 0;

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

  BinGAFAssetConfigConverter(String assetID, ByteBuffer bytes)
      : _data = new ByteData.view(bytes),
        _assetID = assetID,
        _textureElementSizes = new Map<String, Rectangle>();

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
    _config.compression = _readInt();
    _config.versionMajor = _readByte();
    _config.versionMinor = _readByte();
    _config.fileLength = _readUnsignedInt();

    if (_config.compression == SIGNATURE_GAC) {
      var decoder = new ZLibDecoder();
      var compressed = new Uint8List.view(_data.buffer, _dataPosition);
      var inputStream = new InputStream(compressed, byteOrder: LITTLE_ENDIAN);
      var uncompressed = decoder.decodeBuffer(inputStream) as Uint8List;
      _data = new ByteData.view(uncompressed.buffer);
      _dataPosition = 0;
    }

    if (_config.versionMajor < 4) {

      _currentTimeline = new GAFTimelineConfig("${_config.versionMajor}.${_config.versionMinor}");
      _currentTimeline.id = "0";
      _currentTimeline.assetID = this._assetID;
      _currentTimeline.framesCount = _readShort();
      _currentTimeline.bounds = _readRectangle();
      _currentTimeline.pivot = _readPoint();
      _config.timelines.add(_currentTimeline);

    } else {

      for (int i = 0, l = _readUnsignedInt(); i < l; i++) {
        _config.scaleValues.add(_readFloat());
      }

      for (int i = 0, l = _readUnsignedInt(); i < l; i++) {
        _config.csfValues.add(_readFloat());
      }
    }

    this.readNextTag();
  }

  void checkForMissedRegions(GAFTimelineConfig timelineConfig) {

    if (timelineConfig.textureAtlas != null && timelineConfig.textureAtlas.contentScaleFactor.elements != null) {
      for (CAnimationObject ao in timelineConfig.animationObjects.all) {
        if (ao.type == CAnimationObject.TYPE_TEXTURE && timelineConfig.textureAtlas.contentScaleFactor.elements .getElement(ao.regionID) == null) {
          timelineConfig.addWarning(WarningConstants.REGION_NOT_FOUND);
          break;
        }
      }
    }
  }

  void readNextTag() {

    int tagID = _readShort();
    int tagLength = _readUnsignedInt();

    switch (tagID) {

      case BinGAFAssetConfigConverter.TAG_DEFINE_STAGE:
        _readStageConfig(_config);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS2:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS3:
        readTextureAtlasConfig(tagID);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS2:
        _readAnimationMasks(tagID, _currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS2:
        _readAnimationObjects(tagID, _currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_FRAMES:
      case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_FRAMES2:
        readAnimationFrames(tagID);
        return;

      case BinGAFAssetConfigConverter.TAG_DEFINE_NAMED_PARTS:
        _readNamedParts(_currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_SEQUENCES:
        _readAnimationSequences(_currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_TEXT_FIELDS:
        _readTextFields(_currentTimeline);
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_SOUNDS:
        if (!_ignoreSounds) {
          _readSounds(_config);
        } else {
          _dataPosition += tagLength;
        }
        break;

      case BinGAFAssetConfigConverter.TAG_DEFINE_TIMELINE:
        _currentTimeline = readTimeline();
        break;

      case BinGAFAssetConfigConverter.TAG_END:
        if (_isTimeline) {
          _isTimeline = false;
        } else {
          _dataPosition = _data.lengthInBytes;
          this.endParsing();
          return;
        }
        break;

      default:
        print(WarningConstants.UNSUPPORTED_TAG);
        _dataPosition += tagLength;
        break;
    }

    readNextTag();
  }

  GAFTimelineConfig readTimeline() {

    GAFTimelineConfig timelineConfig = new GAFTimelineConfig("${_config.versionMajor}.${_config.versionMinor}");
    timelineConfig.id = _readUnsignedInt().toString();
    timelineConfig.assetID = _config.id;
    timelineConfig.framesCount = _readUnsignedInt();
    timelineConfig.bounds = _readRectangle();
    timelineConfig.pivot = _readPoint();
    bool hasLinkage = _readBool();

    if (hasLinkage) {
      timelineConfig.linkage = _readUTF();
    }

    this._config.timelines.add(timelineConfig);

    this._isTimeline = true;

    return timelineConfig;
  }

  void readMaskMaxSizes() {

    for (GAFTimelineConfig timeline in _config.timelines) {

      for (CAnimationFrame frame in timeline.animationFrames.all) {
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
              CTextFieldObject textField = timeline.textFields.getTextFieldObject(animationObject.regionID);
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

    this.readMaskMaxSizes();

    if (_config.defaultScale is! num) {
      int itemIndex = 0;
      if (_defaultScale is num) {
        itemIndex = _config.scaleValues.indexOf(_defaultScale);
        if (itemIndex < 0) {
          parseError("${_defaultScale} + ${ErrorConstants.SCALE_NOT_FOUND}");
          return;
        }
      }
      _config.defaultScale = _config.scaleValues[itemIndex];
    }

    if (_config.defaultContentScaleFactor is! num) {
      int itemIndex = 0;
      if (_defaultContentScaleFactor is num) {
        itemIndex = _config.csfValues.indexOf(_defaultContentScaleFactor);
        if (itemIndex < 0) {
          parseError("${_defaultContentScaleFactor} + ${ErrorConstants.CSF_NOT_FOUND}");
          return;
        }
      }
      _config.defaultContentScaleFactor = _config.csfValues[itemIndex];
    }

    for (CTextureAtlasScale textureAtlasScale in _config.allTextureAtlases) {
      for (CTextureAtlasCSF textureAtlasCSF in textureAtlasScale.allContentScaleFactors) {
        if (_isEquivalent(_config.defaultContentScaleFactor, textureAtlasCSF.csf)) {
          textureAtlasScale.contentScaleFactor = textureAtlasCSF;
          break;
        }
      }
    }

    for (GAFTimelineConfig timelineConfig in _config.timelines) {
      timelineConfig.allTextureAtlases = _config.allTextureAtlases;
      for (CTextureAtlasScale textureAtlasScale in _config.allTextureAtlases) {
        if (_isEquivalent(_config.defaultScale, textureAtlasScale.scale)) {
          timelineConfig.textureAtlas = textureAtlasScale;
        }
      }

      timelineConfig.stageConfig = this._config.stageConfig;
      this.checkForMissedRegions(timelineConfig);
    }
  }

  void readAnimationFrames(int tagID, [int startIndex = 0, num framesCount, CAnimationFrame prevFrame]) {

    if (framesCount is! num) {
      framesCount = _readUnsignedInt();
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

      frameNumber = _readUnsignedInt();

      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_FRAMES) {
        hasChangesInDisplayList = true;
        hasActions = false;
      } else {
        hasChangesInDisplayList = _readBool();
        hasActions = _readBool();
      }

      if (prevFrame != null) {
        currentFrame = prevFrame.clone(frameNumber);
        for (int n = prevFrame.frameNumber + 1; n < currentFrame.frameNumber; n++) {
          timelineConfig.animationFrames.addFrame(prevFrame.clone(n));
        }
      } else {
        currentFrame = new CAnimationFrame(frameNumber);
        if (currentFrame.frameNumber > 1) {
          for (int n = 1; n < currentFrame.frameNumber; n++) {
            timelineConfig.animationFrames.addFrame(new CAnimationFrame(n));
          }
        }
      }

      if (hasChangesInDisplayList) {

        statesCount = _readUnsignedInt();

        for (int j = 0; j < statesCount; j++) {
          hasColorTransform = _readBool();
          hasMask = _readBool();
          hasEffect = _readBool();

          stateID = _readUnsignedInt();
          zIndex = _readInt();
          alpha = _readFloat();
          matrix = _readMatrix();
          filter = null;

          if (hasColorTransform) {
            List<num> params = new List<num>.generate(7, (i) => _readFloat());
            filter ??= new CFilter();
            filter.addColorTransform(params);
          }

          if (hasEffect) {
            filter ??= new CFilter();
            filterLength = _readByte();

            for (int k = 0; k < filterLength; k++) {
              filterType = _readUnsignedInt();
              String warning;

              switch (filterType) {

                case BinGAFAssetConfigConverter.FILTER_DROP_SHADOW:
                  warning = _readDropShadowFilter(filter);
                  break;

                case BinGAFAssetConfigConverter.FILTER_BLUR:
                  warning = _readBlurFilter(filter);
                  blurFilter = filter.filterDatas.last as CBlurFilterData;
                  if (blurFilter.blurX >= 2 && blurFilter.blurY >= 2) {
                    if (!blurFilters.containsKey(stateID)) {
                      blurFilters[stateID] = blurFilter;
                    }
                  } else {
                    blurFilters[stateID] = null;
                  }
                  break;

                case BinGAFAssetConfigConverter.FILTER_GLOW:
                  warning = _readGlowFilter(filter);
                  break;

                case BinGAFAssetConfigConverter.FILTER_COLOR_MATRIX:
                  warning = _readColorMatrixFilter(filter);
                  break;

                default:
                  print(WarningConstants.UNSUPPORTED_FILTERS);
                  break;
              }

              timelineConfig.addWarning(warning);
            }
          }

          if (hasMask) {
            maskID = _readUnsignedInt().toString();
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

        for (int a = 0, count = _readUnsignedInt(); a < count; a++) {

          var type = _readUnsignedInt();
          var scope = _readUTF();
          var params = new List<String>();

          int paramsLength = _readUnsignedInt();
          int paramsOffset = _dataPosition;

          while (_dataPosition < paramsOffset + paramsLength) {
            params.add(_readUTF());
          }

          var action = new CFrameAction(type, scope, params);

          if (type == CFrameAction.DISPATCH_EVENT &&
              params[0] == CSound.GAF_PLAY_SOUND &&
              params.length > 3) {

            if (_ignoreSounds) continue; //do not add sound events if they're ignored
            Map data = JSON.decode(action.params[3]);
            timelineConfig.addSound(data, frameNumber);
          }

          currentFrame.addAction(action);
        }
      }

      timelineConfig.animationFrames.addFrame(currentFrame);

      prevFrame = currentFrame;
    } //end loop

    for (int n = prevFrame.frameNumber + 1; n <= timelineConfig.framesCount; n++) {
      timelineConfig.animationFrames.addFrame(prevFrame.clone(n));
    }

    for (currentFrame in timelineConfig.animationFrames.all) {
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

    num scale = _readFloat();

    if (_config.scaleValues.indexOf(scale) == -1) {
      _config.scaleValues.add(scale);
    }

    CTextureAtlasScale textureAtlas = this.getTextureAtlasScale(scale);

    /////////////////////

    CTextureAtlasCSF contentScaleFactor;
    int atlasLength = _readByte();

    CTextureAtlasElements elements;
    if (textureAtlas.allContentScaleFactors.length > 0) {
      elements = textureAtlas.allContentScaleFactors[0].elements;
    }

    if (elements == null) {
      elements = new CTextureAtlasElements();
    }

    for (i = 0; i < atlasLength; i++) {

      String atlasID = _readUnsignedInt().toString();
      int sourceLength = _readByte();

      for (j = 0; j < sourceLength; j++) {
        String source = _readUTF();
        double csf = _readFloat();

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

    int elementsLength = _readUnsignedInt();
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
      pivot = _readPoint();
      topLeft = _readPoint();
      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS ||
          tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS2) {
        elementScaleX = elementScaleY = _readFloat();
      }

      double elementWidth = _readFloat();
      double elementHeight = _readFloat();
      String atlasID = _readUnsignedInt().toString();
      String elementAtlasID = _readUnsignedInt().toString();

      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS2 ||
          tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS3) {
        hasScale9Grid = _readBool();
        scale9Grid = hasScale9Grid ? _readRectangle() : null;
      }

      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS3) {
        elementScaleX = _readFloat();
        elementScaleY = _readFloat();
        rotation = _readBool();
        linkageName = _readUTF();
      }

      if (elements.getElement(elementAtlasID) == null) {
        element = new CTextureAtlasElement(elementAtlasID.toString(), atlasID.toString());
        element.region.left = (topLeft.x).round();
        element.region.top =  (topLeft.y).round();
        element.region.right = (topLeft.x + elementWidth).round();
        element.region.bottom = (topLeft.y + elementHeight).round();
        element.pivotMatrix.translate(0.0 - pivot.x, 0.0 - pivot.y);
        element.pivotMatrix.scale(1.0 / elementScaleX, 1.0 / elementScaleY);
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
      if (_isEquivalent(textureAtlasScales[i].scale, scale)) {
        textureAtlasScale = textureAtlasScales[i];
        break;
      }
    }

    if (textureAtlasScale == null) {
      textureAtlasScale = new CTextureAtlasScale(scale);
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

    for (int i = 0; i < textureAtlasSources.length; i++) {
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
    throw new StateError(message);
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

  void set defaultScale(num defaultScale) {
    _defaultScale = defaultScale;
  }

  void set defaultCSF(num csf) {
    _defaultContentScaleFactor = csf;
  }

  //--------------------------------------------------------------------------
  //
  //  READER METHODS
  //
  //--------------------------------------------------------------------------

  double _readFloat() {
    var value = _data.getFloat32(_dataPosition, Endianness.LITTLE_ENDIAN);
    _dataPosition += 4;
    return value;
  }

  int _readByte() {
    var value = _data.getUint8(_dataPosition);
    _dataPosition += 1;
    return value;
  }

  int _readInt() {
    var value = _data.getInt32(_dataPosition, Endianness.LITTLE_ENDIAN);
    _dataPosition += 4;
    return value;
  }

  int _readShort() {
    var value = _data.getInt16(_dataPosition, Endianness.LITTLE_ENDIAN);
    _dataPosition += 2;
    return value;
  }

  int _readUnsignedShort() {
    var value = _data.getUint16(_dataPosition, Endianness.LITTLE_ENDIAN);
    _dataPosition += 2;
    return value;
  }

  int _readUnsignedInt() {
    var value = _data.getUint32(_dataPosition, Endianness.LITTLE_ENDIAN);
    _dataPosition += 4;
    return value;
  }

  bool _readBool() {
    var value = _data.getInt8(_dataPosition);
    _dataPosition += 1;
    return value != 0;
  }

  String _readUTF() {
    var length = _data.getUint16(_dataPosition, Endianness.LITTLE_ENDIAN);
    var string = new Uint8List.view(_data.buffer, _dataPosition + 2, length);
    _dataPosition += 2 + length;
    return UTF8.decode(string);
  }

  Matrix _readMatrix() {
    var a = _readFloat();
    var b = _readFloat();
    var c = _readFloat();
    var d = _readFloat();
    var tx = _readFloat();
    var ty = _readFloat();
    return new Matrix(a, b, c, d, tx, ty);
  }

  Rectangle<num> _readRectangle() {
    var left = _readFloat();
    var top = _readFloat();
    var width = _readFloat();
    var height = _readFloat();
    return new Rectangle<num>(left, top, width, height);
  }

  Point<num> _readPoint() {
    var x = _readFloat();
    var y = _readFloat();
    return new Point<num>(x, y);
  }

  void _readStageConfig(GAFAssetConfig config) {
    var fps = _readByte();
    var color = _readInt();
    var width = _readUnsignedShort();
    var height = _readUnsignedShort();
    config.stageConfig = new CStage(fps, color, width, height);
  }

  String _readDropShadowFilter(CFilter filter) {
    List<num> color = _readColorValue();
    num blurX = _readFloat();
    num blurY = _readFloat();
    num angle = _readFloat();
    num distance = _readFloat();
    num strength = _readFloat();
    bool inner = _readBool();
    bool knockout = _readBool();
    filter.addDropShadowFilter(blurX, blurY, color[1], color[0], angle, distance, strength, inner, knockout);
    return "";
  }

  String _readBlurFilter(CFilter filter) {
    num blurX = _readFloat();
    num blurY = _readFloat();
    filter.addBlurFilter(blurX, blurY);
    return "";
  }

  String _readGlowFilter(CFilter filter) {
    List<num> color = _readColorValue();
    num blurX = _readFloat();
    num blurY = _readFloat();
    num strength = _readFloat();
    bool inner = _readBool();
    bool knockout = _readBool();
    filter.addGlowFilter(blurX, blurY, color[1], color[0], strength, inner, knockout);
    return "";
  }

  String _readColorMatrixFilter(CFilter filter) {
    var matrix = new List<num>.generate(20, (i) => _readFloat());
    filter.addColorMatrixFilter(matrix);
    return "";
  }

  List<num> _readColorValue() {
    int argbValue = _readUnsignedInt();
    num alpha = ((argbValue >> 24) & 0xFF) / 255.0;
    int color = argbValue & 0xFFFFFF;
    return [alpha, color];
  }

  void _readAnimationMasks(int tagID, GAFTimelineConfig timelineConfig) {

    int length = _readUnsignedInt();
    int objectID;
    int regionID;
    String type;

    for (int i = 0; i < length; i++) {
      objectID = _readUnsignedInt();
      regionID = _readUnsignedInt();
      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS) {
        type = CAnimationObject.TYPE_TEXTURE;
      } else // BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS2
      {
        type = _getAnimationObjectTypeString(_readUnsignedShort());
      }
      timelineConfig.animationObjects.addAnimationObject(new CAnimationObject(
          objectID.toString(), regionID.toString(), type, true));
    }
  }

  String _getAnimationObjectTypeString(int type) {
    String typeString = CAnimationObject.TYPE_TEXTURE;
    switch (type) {
      case 0: typeString = CAnimationObject.TYPE_TEXTURE; break;
      case 1: typeString = CAnimationObject.TYPE_TEXTFIELD; break;
      case 2: typeString = CAnimationObject.TYPE_TIMELINE; break;
    }
    return typeString;
  }

  void _readAnimationObjects(int tagID, GAFTimelineConfig timelineConfig) {
    int length = _readUnsignedInt();
    int objectID;
    int regionID;
    String type;

    for (int i = 0; i < length; i++) {
      objectID = _readUnsignedInt();
      regionID = _readUnsignedInt();
      if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS) {
        type = CAnimationObject.TYPE_TEXTURE;
      } else {
        type = _getAnimationObjectTypeString(_readUnsignedShort());
      }
      timelineConfig.animationObjects.addAnimationObject(new CAnimationObject(
          objectID.toString(), regionID.toString(), type, false));
    }
  }

  void _readAnimationSequences(GAFTimelineConfig timelineConfig) {
    int length = _readUnsignedInt();
    String sequenceID;
    int startFrameNo;
    int endFrameNo;

    for (int i = 0; i < length; i++) {
      sequenceID = _readUTF();
      startFrameNo = _readShort();
      endFrameNo = _readShort();
      timelineConfig.animationSequences.addSequence(
          new CAnimationSequence(sequenceID, startFrameNo, endFrameNo));
    }
  }

  void _readNamedParts(GAFTimelineConfig timelineConfig) {
    timelineConfig.namedParts = {};
    int length = _readUnsignedInt();
    int partID;
    for (int i = 0; i < length; i++) {
      partID = _readUnsignedInt();
      timelineConfig.namedParts[partID] = _readUTF();
    }
  }

  void _readTextFields(GAFTimelineConfig timelineConfig) {

    int length = _readUnsignedInt();
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
      textFieldID = _readUnsignedInt();
      pivotX = _readFloat();
      pivotY = _readFloat();
      width = _readFloat();
      height = _readFloat();

      text = _readUTF();

      embedFonts = _readBool();
      multiline = _readBool();
      wordWrap = _readBool();

      bool hasRestrict = _readBool();
      if (hasRestrict) {
        restrict = _readUTF();
      }

      editable = _readBool();
      selectable = _readBool();
      displayAsPassword = _readBool();
      maxChars = _readUnsignedInt();

      // read textFormat
      int alignFlag = _readUnsignedInt();
      String align;
      switch (alignFlag) {
        case 0: align = TextFormatAlign.LEFT; break;
        case 1: align = TextFormatAlign.RIGHT; break;
        case 2: align = TextFormatAlign.CENTER; break;
        case 3: align = TextFormatAlign.JUSTIFY; break;
        case 4: align = TextFormatAlign.START; break;
        case 5: align = TextFormatAlign.END; break;
      }

      num blockIndent = _readUnsignedInt();
      bool bold = _readBool();
      bool bullet = _readBool();
      int color = _readUnsignedInt();

      String font = _readUTF();
      int indent = _readUnsignedInt();
      bool italic = _readBool();
      bool kerning = _readBool();
      int leading = _readUnsignedInt();
      num leftMargin = _readUnsignedInt();
      num letterSpacing = _readFloat();
      num rightMargin = _readUnsignedInt();
      int size = _readUnsignedInt();

      int l = _readUnsignedInt();
      List tabStops = [];
      for (int j = 0; j < l; j++) {
        tabStops.add(_readUnsignedInt());
      }

      String target = _readUTF();
      bool underline = _readBool();
      String url = _readUTF();

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

  void _readSounds(GAFAssetConfig config) {
    CSound soundData;
    int count = _readShort();
    for (int i = 0; i < count; i++) {
      soundData = new CSound();
      soundData.soundID = _readShort();
      soundData.linkageName = _readUTF();
      soundData.source = _readUTF();
      soundData.format = _readByte();
      soundData.rate = _readByte();
      soundData.sampleSize = _readByte();
      soundData.stereo = _readBool();
      soundData.sampleCount = _readUnsignedInt();
      config.addSound(soundData);
    }
  }

  bool _isEquivalent(num a, num b, [num epsilon=0.0001]) {
    return (a - epsilon < b) && (a + epsilon > b);
  }
}
