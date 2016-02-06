part of stagexl_gaf;

abstract class GAFDisplayObject extends DisplayObject {

  String get name;
  void set name(String value);

  num get alpha;
  void set alpha(num value);

  DisplayObjectContainer get parent;

  bool get visible;
  void set visible(bool value);

  Matrix get transformationMatrix;
  void set transformationMatrix(Matrix matrix);

  Matrix get pivotMatrix;

}
