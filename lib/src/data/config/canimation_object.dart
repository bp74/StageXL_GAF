part of stagexl_gaf;

class CAnimationObject {

  static const String TYPE_TEXTURE = "texture";
  static const String TYPE_TEXTFIELD = "textField";
  static const String TYPE_TIMELINE = "timeline";

  final String instanceID;
  final String regionID;
  final String type;
  final bool mask;

  CAnimationObject(this.instanceID, this.regionID, this.type, this.mask);

}
