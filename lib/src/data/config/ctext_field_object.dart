part of stagexl_gaf;

class CTextFieldObject {

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

  String _id;
  num _width;
  num _height;
  String _text;
  bool _embedFonts;
  bool _multiline;
  bool _wordWrap;
  String _restrict;
  bool _editable;
  bool _selectable;
  bool _displayAsPassword;
  int _maxChars;
  TextFormat _textFormat;
  Point _pivotPoint;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  CTextFieldObject( String id, String text, TextFormat textFormat, num width, num height) {
    _id = id;
    _text = text;
    _textFormat = textFormat;
    _width = width;
    _height = height;
    _pivotPoint = new Point(0, 0);
  }

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

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get text => _text;

  set text(String value) {
    _text = value;
  }

  TextFormat get textFormat => _textFormat;

  set textFormat(TextFormat value) {
    _textFormat = value;
  }

  num get width => _width;

  set width(num value) {
    width = value;
  }

  num get height => _height;

  set height(num value) {
    _height = value;
  }

  //--------------------------------------------------------------------------
  //
  //  STATIC METHODS
  //
  //--------------------------------------------------------------------------

  bool get embedFonts => _embedFonts;

  set embedFonts(bool value) {
    _embedFonts = value;
  }

  bool get multiline  => _multiline;

  set multiline(bool value) {
    _multiline = value;
  }

  bool get wordWrap  => _wordWrap;

  set wordWrap(bool value) {
    _wordWrap = value;
  }

  String get restrict  => _restrict;

  set restrict(String value) {
    _restrict = value;
  }

  bool get editable  => _editable;

  set editable(bool value) {
    _editable = value;
  }

  bool get selectable  => _selectable;

  set selectable(bool value) {
    _selectable = value;
  }

  bool get displayAsPassword  => _displayAsPassword;

  set displayAsPassword(bool value) {
    _displayAsPassword = value;
  }

  int get maxChars => _maxChars;

  set maxChars(int value) => _maxChars = value;

  Point get pivotPoint  => _pivotPoint;

  set pivotPoint(Point value) {
    _pivotPoint = value;
  }
}
