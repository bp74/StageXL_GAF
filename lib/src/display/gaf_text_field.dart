part of stagexl_gaf;

class GAFTextField extends TextField implements GAFDisplayObject {
  final CTextField config;
  @override
  final Matrix pivotMatrix = Matrix.fromIdentity();

  GAFTextField(this.config, [num displayScale = 1, num contentScale = 1])
      : super() {
    var pivotPoint = config.pivotPoint;

    text = config.text;
    width = config.width;
    height = config.height;
    multiline = config.multiline;
    wordWrap = config.wordWrap;
    maxChars = config.maxChars;
    type = config.editable ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
    displayAsPassword = config.displayAsPassword;

    defaultTextFormat = config.textFormat;
    pivotMatrix.translate(0 - pivotPoint.x, 0 - pivotPoint.y);
    pivotMatrix.scale(displayScale, displayScale);
  }
}
