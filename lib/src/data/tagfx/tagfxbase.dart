part of stagexl_gaf;

abstract class TAGFXBase implements TAGFX {

  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  static final String SOURCE_TYPE_BITMAP_DATA = "sourceTypeBitmapData";
  //static final String SOURCE_TYPE_BITMAP = "sourceTypeBitmap";
  //static final String SOURCE_TYPE_PNG_BA = "sourceTypePNGBA";
  //static final String SOURCE_TYPE_ATF_BA = "sourceTypeATFBA";
  //static final String SOURCE_TYPE_PNG_URL = "sourceTypePNGURL";
  //static final String SOURCE_TYPE_ATF_URL = "sourceTypeATFURL";

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  BitmapData _texture;
  Point _textureSize;
  num _textureScale = -1;
  String _textureFormat;
  dynamic _source;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  BitmapData get texture => _texture;

  Point get textureSize => _textureSize;

  set textureSize(Point value) {
    _textureSize = value;
  }

  num get textureScale => _textureScale;

  set textureScale(num value) {
    _textureScale = value;
  }

  String get textureFormat => _textureFormat;

  set textureFormat(String value) {
    _textureFormat = value;
  }

  String get sourceType;

  dynamic get source {
    return _source;
  }

  //--------------------------------------------------------------------------
  //
  //  STATIC METHODS
  //
  //--------------------------------------------------------------------------
}
