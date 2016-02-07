part of stagexl_gaf;

class CTextFieldObject {

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
  String restrict = null;
  Point pivotPoint = null;

  CTextFieldObject(this.id, this.text, this.textFormat, this.width, this.height);

}
