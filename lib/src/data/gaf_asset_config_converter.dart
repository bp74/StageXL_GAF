part of stagexl_gaf;

class GAFAssetConfigConverter {

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
  static const int FILTER_BEVEL = 3;           // suppressed by GAFConverter
  static const int FILTER_GRADIENT_GLOW = 4;   // suppressed by GAFConverter
  static const int FILTER_CONVOLUTION = 5;     // suppressed by GAFConverter
  static const int FILTER_COLOR_MATRIX = 6;
  static const int FILTER_GRADIENT_BEVEL = 7;  // suppressed by GAFConverter

  static final Rectangle sHelperRectangle = new Rectangle<num>(0, 0, 0, 0);
  static final Matrix sHelperMatrix = new Matrix.fromIdentity();

  final String assetID;
  final bool ignoreSounds;
  final ByteBuffer byteBuffer;

  ByteData _data;
  int _dataPosition = 0;
  GAFAssetConfig _config;
  GAFTimelineConfig _currentTimeline;
  bool _isTimeline;

  GAFAssetConfigConverter(this.assetID, this.ignoreSounds, this.byteBuffer);

  //--------------------------------------------------------------------------

  GAFAssetConfig convert() {

    _data = new ByteData.view(this.byteBuffer);
    _dataPosition = 0;

    _config = new GAFAssetConfig(this.assetID);
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
      var version = "${_config.versionMajor}.${_config.versionMinor}";
      _currentTimeline = new GAFTimelineConfig(0, assetID, version);
      _currentTimeline.framesCount = _readShort();
      _currentTimeline.bounds = _readRectangle();
      _currentTimeline.pivot = _readPoint();
      _config.timelines.add(_currentTimeline);

    } else {

      for (int i = 0, l = _readUnsignedInt(); i < l; i++) {
        _config.displayScaleValues.add(_readFloat());
      }

      for (int i = 0, l = _readUnsignedInt(); i < l; i++) {
        _config.contentScaleValues.add(_readFloat());
      }
    }

    this.readNextTag();

    return _config;
  }

  void readNextTag() {

    int tagID = _readShort();
    int tagLength = _readUnsignedInt();

    switch (tagID) {

      case TAG_DEFINE_STAGE:
        _readStageConfig(_config);
        break;

      case TAG_DEFINE_ATLAS:
      case TAG_DEFINE_ATLAS2:
      case TAG_DEFINE_ATLAS3:
        _readTextureAtlasConfig(tagID);
        break;

      case TAG_DEFINE_ANIMATION_MASKS:
      case TAG_DEFINE_ANIMATION_MASKS2:
        _readAnimationMasks(tagID, _currentTimeline);
        break;

      case TAG_DEFINE_ANIMATION_OBJECTS:
      case TAG_DEFINE_ANIMATION_OBJECTS2:
        _readAnimationObjects(tagID, _currentTimeline);
        break;

      case TAG_DEFINE_ANIMATION_FRAMES:
      case TAG_DEFINE_ANIMATION_FRAMES2:
        readAnimationFrames(tagID);
        return;

      case TAG_DEFINE_NAMED_PARTS:
        _readNamedParts(_currentTimeline);
        break;

      case TAG_DEFINE_SEQUENCES:
        _readAnimationSequences(_currentTimeline);
        break;

      case TAG_DEFINE_TEXT_FIELDS:
        _readTextFields(_currentTimeline);
        break;

      case TAG_DEFINE_SOUNDS:
        if (ignoreSounds) {
          _dataPosition += tagLength;
        } else {
          _readSounds(_config);
        }
        break;

      case TAG_DEFINE_TIMELINE:
        _currentTimeline = readTimeline();
        break;

      case TAG_END:
        if (_isTimeline) {
          _isTimeline = false;
        } else {
          _dataPosition = _data.lengthInBytes;
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

    var id = _readUnsignedInt();
    var assetID = _config.id;
    var version = "${_config.versionMajor}.${_config.versionMinor}";
    var timelineConfig = new GAFTimelineConfig(id, assetID, version);

    timelineConfig.framesCount = _readUnsignedInt();
    timelineConfig.bounds = _readRectangle();
    timelineConfig.pivot = _readPoint();

    var hasLinkage = _readBool();
    if (hasLinkage) timelineConfig.linkage = _readUTF();

    _config.timelines.add(timelineConfig);
    _isTimeline = true;

    return timelineConfig;
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
    bool hasMask = false;
    bool hasEffect = false;
    bool hasActions = false;
    bool hasColorTransform = false;
    bool hasChangesInDisplayList = false;

    GAFTimelineConfig timelineConfig = _config.timelines.last;
    CAnimationFrame currentFrame = null;
    CFilter filter = null;

    for (int i = startIndex; i < framesCount; i++) {

      frameNumber = _readUnsignedInt();

      if (tagID == TAG_DEFINE_ANIMATION_FRAMES) {
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
              String warning = null;

              if (filterType == FILTER_DROP_SHADOW) {
                warning = _readDropShadowFilter(filter);
              } else if (filterType == FILTER_BLUR) {
                warning = _readBlurFilter(filter);
              } else if (filterType == FILTER_GLOW) {
                warning = _readGlowFilter(filter);
              } else if (filterType == FILTER_COLOR_MATRIX) {
                warning = _readColorMatrixFilter(filter);
              } else {
                print(WarningConstants.UNSUPPORTED_FILTERS);
              }
              timelineConfig.addWarning(warning);
            }
          }

          var maskID = hasMask ? _readUnsignedInt() : null;

          var instance = new CAnimationFrameInstance(
              stateID, zIndex, alpha, maskID, matrix, filter);

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

            if (ignoreSounds) continue; //do not add sound events if they're ignored
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

    readNextTag();
  }

  CTextureAtlas getTextureAtlas(num displayScale) {
    for (var textureAtlas in _config.textureAtlases) {
      if (textureAtlas.displayScale == displayScale) return textureAtlas;
    }
    var textureAtlas = new CTextureAtlas(displayScale);
    _config.textureAtlases.add(textureAtlas);
    return textureAtlas;
  }

  CTextureAtlasContent getTextureAtlasContent(num displayScale, num contentScale) {
    var textureAtlas = this.getTextureAtlas(displayScale);
    var textureAtlasScale = textureAtlas.getTextureAtlasContent(contentScale);
    if (textureAtlasScale == null) {
      textureAtlasScale = new CTextureAtlasContent(contentScale, displayScale);
      textureAtlas.contents.add(textureAtlasScale);
    }
    return textureAtlasScale;
  }

  void parseError(String message) {
    throw new StateError(message);
  }

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

  void _readTextureAtlasConfig(int tagID) {

    var displayScale = _readFloat();
    var textureAtlas = this.getTextureAtlas(displayScale);

    var dsValues = _config.displayScaleValues;
    if (dsValues.indexOf(displayScale) == -1) dsValues.add(displayScale);

    for (int i = 0, al = _readByte(); i < al; i++) {
      int atlasID = _readUnsignedInt();
      for (int j = 0, sl = _readByte(); j < sl; j++) {
        var source = _readUTF();
        var contentScale = _readFloat();
        var csValues = _config.contentScaleValues;
        if (csValues.indexOf(contentScale) == -1) csValues.add(contentScale);
        var taContent = this.getTextureAtlasContent(displayScale, contentScale);
        if (taContent.sources.every((s) => s.id != atlasID)) {
          taContent.sources.add(new CTextureAtlasSource(atlasID, source));
        }
      }
    }

    for (int i = 0, el = _readUnsignedInt(); i < el; i++) {

      Point pivot = _readPoint();
      Point topLeft = _readPoint();
      bool hasScale9Grid = false;
      Rectangle scale9Grid = null;
      num elementScaleX = 1.0;
      num elementScaleY = 1.0;
      bool rotation = false;
      String linkageName = "";

      if (tagID == TAG_DEFINE_ATLAS || tagID == TAG_DEFINE_ATLAS2) {
        elementScaleX = elementScaleY = _readFloat();
      }

      double elementWidth = _readFloat();
      double elementHeight = _readFloat();
      int atlasID = _readUnsignedInt();
      int elementAtlasID = _readUnsignedInt();

      if (tagID == TAG_DEFINE_ATLAS2 || tagID == TAG_DEFINE_ATLAS3) {
        hasScale9Grid = _readBool();
        scale9Grid = hasScale9Grid ? _readRectangle() : null;
      }

      if (tagID == TAG_DEFINE_ATLAS3) {
        elementScaleX = _readFloat();
        elementScaleY = _readFloat();
        rotation = _readBool();
        linkageName = _readUTF();
      }

      if (textureAtlas.elements.getElement(elementAtlasID) == null) {
        var element = new CTextureAtlasElement(elementAtlasID, atlasID);
        element.region.left = (topLeft.x).round();
        element.region.top =  (topLeft.y).round();
        element.region.right = (topLeft.x + elementWidth).round();
        element.region.bottom = (topLeft.y + elementHeight).round();
        element.pivotMatrix.translate(0.0 - pivot.x, 0.0 - pivot.y);
        element.pivotMatrix.scale(1.0 / elementScaleX, 1.0 / elementScaleY);
        element.scale9Grid = scale9Grid;
        element.linkage = linkageName;
        element.rotated = rotation;
        textureAtlas.elements.addElement(element);
      }
    }
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
      if (tagID == GAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS) {
        type = CAnimationObject.TYPE_TEXTURE;
      } else // BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS2
      {
        type = _getAnimationObjectTypeString(_readUnsignedShort());
      }
      timelineConfig.animationObjects.addAnimationObject(
          new CAnimationObject(objectID, regionID, type, true));
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
      if (tagID == GAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS) {
        type = CAnimationObject.TYPE_TEXTURE;
      } else {
        type = _getAnimationObjectTypeString(_readUnsignedShort());
      }
      timelineConfig.animationObjects.addAnimationObject(
          new CAnimationObject(objectID, regionID, type, false));
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
    for (int i = 0, length = _readUnsignedInt(); i < length; i++) {
      var partID = _readUnsignedInt();
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

      CTextFieldObject textFieldObject = new CTextFieldObject(textFieldID, text, textFormat, width, height);
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
    for (int i = 0, l = _readShort(); i < l; i++) {
      var sound = new CSound();
      sound.soundID = _readShort();
      sound.linkageName = _readUTF();
      sound.source = _readUTF();
      sound.format = _readByte();
      sound.rate = _readByte();
      sound.sampleSize = _readByte();
      sound.stereo = _readBool();
      sound.sampleCount = _readUnsignedInt();
      config.sounds.add(sound);
    }
  }

}
