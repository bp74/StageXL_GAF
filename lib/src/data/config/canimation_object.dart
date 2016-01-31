part of stagexl_gaf;

class CAnimationObject {

  static const String TYPE_TEXTURE = "texture";
  static const String TYPE_TEXTFIELD = "textField";
  static const String TYPE_TIMELINE = "timeline";

  final String instanceID;
  final String regionID;
  final String type;
  final bool mask;

  Point _maxSize = null;

  CAnimationObject(this.instanceID, this.regionID, this.type, this.mask);

  //---------------------------------------------------------------------------

  Point get maxSize => _maxSize;

  void set maxSize(Point value) {
    _maxSize = value;
  }

}
