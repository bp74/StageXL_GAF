part of stagexl_gaf;

class GAFTextField extends TextField implements GAFDisplayObject {

  final Matrix pivotMatrix = new Matrix.fromIdentity();

  GAFTextField(CTextField config,
      [num displayScale = 1, num contentScale = 1]) : super() {

    var pivotPoint = config.pivotPoint;

    this.text = config.text;
    this.width = config.width;
    this.height = config.height;
    this.multiline = config.multiline;
    this.wordWrap = config.wordWrap;
    this.maxChars = config.maxChars;
    this.type = config.editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
    this.displayAsPassword = config.displayAsPassword;

    this.defaultTextFormat = config.textFormat;
    this.pivotMatrix.translate(0 - pivotPoint.x, 0 - pivotPoint.y);
    this.pivotMatrix.scale(displayScale, displayScale);
  }
}
