part of stagexl_gaf;

class CTextField {

  int id;
  String text;
  TextFormat textFormat;
  num width;
  num height;

  bool embedFonts = false;
  bool multiline = false;
  bool wordWrap = false;
  bool editable = false;
  bool selectable = false;
  bool displayAsPassword = false;

  int maxChars = 0;
  String restrict;
  Point<num> pivotPoint = Point<num>(0, 0);

  CTextField(this.id, this.text, this.textFormat, this.width, this.height);

}
