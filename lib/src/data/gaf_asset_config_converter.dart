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

  String _path;
  ByteData _data;
  int _dataPosition = 0;
  GAFAssetConfig _config;
  GAFTimelineConfig _currentTimeline;
  bool _isTimeline;

  GAFAssetConfigConverter(this.assetID);

  //--------------------------------------------------------------------------

  GAFAssetConfig convert(ByteBuffer byteBuffer, String path) {

    _path = path;
    _data = new ByteData.view(byteBuffer);
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
      var displayScaleCount = _readUnsignedInt();
      var displayScaleValues = _readFloats(displayScaleCount);
      var contentScaleCount = _readUnsignedInt();
      var contentScaleValues = _readFloats(contentScaleCount);
      _config.displayScaleValues.addAll(displayScaleValues);
      _config.contentScaleValues.addAll(contentScaleValues);
    }

    _readNextTag();
    return _config;
  }

  //---------------------------------------------------------------------------

  CTextureAtlas _getTextureAtlas(num displayScale) {
    for (var textureAtlas in _config.textureAtlases) {
      if (textureAtlas.displayScale == displayScale) return textureAtlas;
    }
    var textureAtlas = new CTextureAtlas(displayScale);
    _config.textureAtlases.add(textureAtlas);
    return textureAtlas;
  }

  CTextureAtlasContent _getTextureAtlasContent(num displayScale, num contentScale) {
    var textureAtlas = _getTextureAtlas(displayScale);
    var textureAtlasContent = textureAtlas.getTextureAtlasContent(contentScale);
    if (textureAtlasContent != null) textureAtlasContent;
    textureAtlasContent = new CTextureAtlasContent(contentScale, displayScale);
    textureAtlas.contents.add(textureAtlasContent);
    return textureAtlasContent;
  }

  //---------------------------------------------------------------------------

  void _readNextTag() {

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
        _readAnimationFrames(tagID);
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
        _readSounds(_config);
        break;

      case TAG_DEFINE_TIMELINE:
        _currentTimeline = _readTimeline();
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

    _readNextTag();
  }

  //---------------------------------------------------------------------------

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
    var f = _readFloats(6);
    return new Matrix(f[0], f[1], f[2], f[3], f[4], f[5]);
  }

  Rectangle<num> _readRectangle() {
    var f = _readFloats(4);
    return new Rectangle<num>(f[0], f[1], f[2], f[3]);
  }

  Point<num> _readPoint() {
    var f = _readFloats(2);
    return new Point<num>(f[0], f[1]);
  }

  Float32List _readFloats(int count) {
    var values = new Float32List(count);
    for (int i = 0; i < count; i++) values[i] = _readFloat();
    return values;
  }

  //---------------------------------------------------------------------------

  void _readStageConfig(GAFAssetConfig config) {
    config.stageConfig.fps = _readByte();
    config.stageConfig.color = _readInt();
    config.stageConfig.width = _readUnsignedShort();
    config.stageConfig.height = _readUnsignedShort();
  }

  //---------------------------------------------------------------------------

  GAFTimelineConfig _readTimeline() {

    var id = _readUnsignedInt();
    var assetID = _config.id;
    var version = "${_config.versionMajor}.${_config.versionMinor}";
    var timelineConfig = new GAFTimelineConfig(id, assetID, version);

    timelineConfig.framesCount = _readUnsignedInt();
    timelineConfig.bounds = _readRectangle();
    timelineConfig.pivot = _readPoint();
    timelineConfig.linkage = _readBool() ? _readUTF() : "";

    _config.timelines.add(timelineConfig);
    _isTimeline = true;

    return timelineConfig;
  }

  //---------------------------------------------------------------------------

  void _readAnimationFrames(int tagID,
      [int startIndex = 0, num framesCount, CAnimationFrame prevFrame]) {

    if (framesCount is! num) framesCount = _readUnsignedInt();

    GAFTimelineConfig timelineConfig = _config.timelines.last;
    CAnimationFrame currentFrame = null;

    for (int i = startIndex; i < framesCount; i++) {

      var frameNumber = _readUnsignedInt();
      var hasActions = false;
      var hasChangesInDisplayList = false;

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
          timelineConfig.animationFrames.add(prevFrame.clone(n));
        }
      } else {
        currentFrame = new CAnimationFrame(frameNumber);
        if (currentFrame.frameNumber > 1) {
          for (int n = 1; n < currentFrame.frameNumber; n++) {
            timelineConfig.animationFrames.add(new CAnimationFrame(n));
          }
        }
      }

      if (hasChangesInDisplayList) {

        for (int j = 0, length = _readUnsignedInt(); j < length; j++) {

          var hasColorTransform = _readBool();
          var hasMask = _readBool();
          var hasEffect = _readBool();
          var stateID = _readUnsignedInt();
          var zIndex = _readInt();
          var alpha = _readFloat();
          var matrix = _readMatrix();

          CFilter filter = null;

          if (hasColorTransform) {
            var params = _readFloats(7);
            filter ??= new CFilter();
            filter.addColorTransform(params);
          }

          if (hasEffect) {
            filter ??= new CFilter();
            for (int k = 0, l = _readByte(); k < l; k++) {
              var filterType = _readUnsignedInt();
              if (filterType == FILTER_DROP_SHADOW) {
                _readDropShadowFilter(filter);
              } else if (filterType == FILTER_BLUR) {
                _readBlurFilter(filter);
              } else if (filterType == FILTER_GLOW) {
                _readGlowFilter(filter);
              } else if (filterType == FILTER_COLOR_MATRIX) {
                _readColorMatrixFilter(filter);
              } else {
                print(WarningConstants.UNSUPPORTED_FILTERS);
              }
            }
          }

          var maskID = hasMask ? _readUnsignedInt() : null;
          var instance = new CAnimationFrameInstance(
              stateID, zIndex, alpha, maskID, matrix, filter);

          currentFrame.updateInstance(instance);
        }
        currentFrame.sortInstances();
      }

      if (hasActions) {

        for (int j = 0, l = _readUnsignedInt(); j < l; j++) {

          var type = _readUnsignedInt();
          var scope = _readUTF();
          var paramsLength = _readUnsignedInt();
          var paramsOffset = _dataPosition;
          var action = new CFrameAction(type, scope);

          while (_dataPosition < paramsOffset + paramsLength) {
            action.params.add(_readUTF());
          }

          if (type == CFrameAction.DISPATCH_EVENT) {
            var param0 = action.params.length > 0 ? action.params[0] : null;
            var param3 = action.params.length > 3 ? action.params[3] : null;
            if (param0 == CSound.GAF_PLAY_SOUND && param3 != null) {
              Map data = JSON.decode(param3);
              timelineConfig.addSound(data, frameNumber);
            }
          }

          currentFrame.actions.add(action);
        }
      }

      timelineConfig.animationFrames.add(currentFrame);
      prevFrame = currentFrame;
    }

    for (int n = prevFrame.frameNumber + 1; n <= timelineConfig.framesCount; n++) {
      timelineConfig.animationFrames.add(prevFrame.clone(n));
    }

    _readNextTag();
  }

  void _readTextureAtlasConfig(int tagID) {

    var displayScale = _readFloat();
    var textureAtlas = _getTextureAtlas(displayScale);

    var dsValues = _config.displayScaleValues;
    if (dsValues.indexOf(displayScale) == -1) dsValues.add(displayScale);

    for (int i = 0, al = _readByte(); i < al; i++) {
      int atlasID = _readUnsignedInt();
      for (int j = 0, sl = _readByte(); j < sl; j++) {
        var source = _path + _readUTF();
        var contentScale = _readFloat();
        var csValues = _config.contentScaleValues;
        if (csValues.indexOf(contentScale) == -1) csValues.add(contentScale);
        var taContent = _getTextureAtlasContent(displayScale, contentScale);
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
      int elementID = _readUnsignedInt();

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

      if (textureAtlas.getTextureAtlasElementByID(elementID) == null) {
        var element = new CTextureAtlasElement(elementID, atlasID);
        element.region.left = (topLeft.x).round();
        element.region.top =  (topLeft.y).round();
        element.region.right = (topLeft.x + elementWidth).round();
        element.region.bottom = (topLeft.y + elementHeight).round();
        element.matrix.translate(0.0 - pivot.x, 0.0 - pivot.y);
        element.matrix.scale(1.0 / elementScaleX, 1.0 / elementScaleY);
        element.scale9Grid = scale9Grid;
        element.linkage = linkageName;
        element.rotated = rotation;
        textureAtlas.elements.add(element);
      }
    }
  }

  void _readDropShadowFilter(CFilter filter) {
    int color = _readUnsignedInt();
    num blurX = _readFloat();
    num blurY = _readFloat();
    num angle = _readFloat();
    num distance = _readFloat();
    num strength = _readFloat();
    bool inner = _readBool();
    bool knockout = _readBool();
    filter.addDropShadowFilter(blurX, blurY, color, angle, distance, strength, inner, knockout);
  }

  void _readBlurFilter(CFilter filter) {
    num blurX = _readFloat();
    num blurY = _readFloat();
    filter.addBlurFilter(blurX, blurY);
  }

  void _readGlowFilter(CFilter filter) {
    int color = _readUnsignedInt();
    num blurX = _readFloat();
    num blurY = _readFloat();
    num strength = _readFloat();
    bool inner = _readBool();
    bool knockout = _readBool();
    filter.addGlowFilter(blurX, blurY, color, strength, inner, knockout);
  }

  void _readColorMatrixFilter(CFilter filter) {
    var matrix = _readFloats(20);
    filter.addColorMatrixFilter(matrix);
  }

  String _getAnimationObjectTypeString(int type) {
    if (type == 0) return CAnimationObject.TYPE_TEXTURE;
    if (type == 1) return CAnimationObject.TYPE_TEXTFIELD;
    if (type == 2) return CAnimationObject.TYPE_TIMELINE;
    return CAnimationObject.TYPE_TEXTURE;
  }

  void _readAnimationMasks(int tagID, GAFTimelineConfig timelineConfig) {
    for (int i = 0, length = _readUnsignedInt(); i < length; i++) {
      var objectID = _readUnsignedInt();
      var regionID = _readUnsignedInt();
      var type = tagID == TAG_DEFINE_ANIMATION_MASKS ? 0 : _readUnsignedShort();
      var typeString = _getAnimationObjectTypeString(type);
      var value = new CAnimationObject(objectID, regionID, typeString, true);
      timelineConfig.animationObjects.add(value);
    }
  }

  void _readAnimationObjects(int tagID, GAFTimelineConfig timelineConfig) {
    for (int i = 0, length = _readUnsignedInt(); i < length; i++) {
      var objectID = _readUnsignedInt();
      var regionID = _readUnsignedInt();
      var type = tagID == TAG_DEFINE_ANIMATION_OBJECTS ? 0 : _readUnsignedShort();
      var typeString = _getAnimationObjectTypeString(type);
      var value = new CAnimationObject(objectID, regionID, typeString, false);
      timelineConfig.animationObjects.add(value);
    }
  }

  void _readAnimationSequences(GAFTimelineConfig timelineConfig) {
    for (int i = 0, length = _readUnsignedInt(); i < length; i++) {
      var sequenceID = _readUTF();
      var startFrameNo = _readShort();
      var endFrameNo = _readShort();
      var value = new CAnimationSequence(sequenceID, startFrameNo, endFrameNo);
      timelineConfig.animationSequences.add(value);
    }
  }

  void _readNamedParts(GAFTimelineConfig timelineConfig) {
    for (int i = 0, length = _readUnsignedInt(); i < length; i++) {
      var partID = _readUnsignedInt();
      var name = _readUTF();
      timelineConfig.namedParts[partID] = name;
    }
  }

  void _readSounds(GAFAssetConfig config) {
    for (int i = 0, length = _readShort(); i < length; i++) {
      var sound = new CSound();
      sound.id = _readShort();
      sound.linkage = _readUTF();
      sound.source = _path + _readUTF();
      sound.format = _readByte();
      sound.rate = _readByte();
      sound.sampleSize = _readByte();
      sound.stereo = _readBool();
      sound.sampleCount = _readUnsignedInt();
      config.sounds.add(sound);
    }
  }

  void _readTextFields(GAFTimelineConfig timelineConfig) {

    for (int i = 0, length = _readUnsignedInt(); i < length; i++) {

      var textFieldID = _readUnsignedInt();
      var pivotX = _readFloat();
      var pivotY = _readFloat();
      var width = _readFloat();
      var height = _readFloat();
      var text = _readUTF();
      var embedFonts = _readBool();
      var multiline = _readBool();
      var wordWrap = _readBool();
      var hasRestrict = _readBool();
      var restrict = hasRestrict ? _readUTF() : null;
      var editable = _readBool();
      var selectable = _readBool();
      var displayAsPassword = _readBool();
      var maxChars = _readUnsignedInt();

      var alignFlag = _readUnsignedInt();
      var blockIndent = _readUnsignedInt();
      var bold = _readBool();
      var bullet = _readBool();
      var color = _readUnsignedInt();
      var font = _readUTF();
      var indent = _readUnsignedInt();
      var italic = _readBool();
      var kerning = _readBool();
      var leading = _readUnsignedInt();
      var leftMargin = _readUnsignedInt();
      var letterSpacing = _readFloat();
      var rightMargin = _readUnsignedInt();
      var size = _readUnsignedInt();
      List<int> tabStops = new List<int>();

      for (int j = 0, l = _readUnsignedInt(); j < l; j++) {
        tabStops.add(_readUnsignedInt());
      }

      var target = _readUTF();
      var underline = _readBool();
      var url = _readUTF();
      var align = TextFormatAlign.CENTER;

      switch (alignFlag) {
        case 0: align = TextFormatAlign.LEFT; break;
        case 1: align = TextFormatAlign.RIGHT; break;
        case 2: align = TextFormatAlign.CENTER; break;
        case 3: align = TextFormatAlign.JUSTIFY; break;
        case 4: align = TextFormatAlign.START; break;
        case 5: align = TextFormatAlign.END; break;
      }

      var textFormat = new TextFormat(
          font, size, color,
          bold: bold,
          italic: italic,
          underline: underline,
          align: align,
          leftMargin: leftMargin,
          rightMargin: rightMargin,
          indent: indent,
          leading: leading);

      var textField = new CTextField(textFieldID, text, textFormat, width, height);
      textField.pivotPoint.x = pivotX;
      textField.pivotPoint.y = pivotY;
      textField.embedFonts = embedFonts;
      textField.multiline = multiline;
      textField.wordWrap = wordWrap;
      textField.restrict = restrict;
      textField.editable = editable;
      textField.selectable = selectable;
      textField.displayAsPassword = displayAsPassword;
      textField.maxChars = maxChars;
      timelineConfig.textFields.add(textField);

      // make analyzer happy
      "$blockIndent, $bullet, $kerning, $letterSpacing, $target, $url";
    }
  }

}
