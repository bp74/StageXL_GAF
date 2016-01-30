part of stagexl_gaf;

abstract class IGAFDisplayObject {

  void setFilterConfig(CFilter value, [num scale = 1]);
  void invalidateOrientation();
  void dispose();

  num get alpha;
  void set alpha(num value);

  DisplayObjectContainer get parent;

  bool get visible;
  void set visible(bool value);

  Matrix get transformationMatrix;
  void set transformationMatrix(Matrix matrix);

  Matrix get pivotMatrix;

  String get name;
  void set name(String value);
}
