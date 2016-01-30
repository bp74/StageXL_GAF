part of stagexl_gaf;

class CAnimationObject {

  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  static const String TYPE_TEXTURE = "texture";
  static const String TYPE_TEXTFIELD = "textField";
  static const String TYPE_TIMELINE = "timeline";

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  String _instanceID;
  String _regionID;
  String _type;
  bool _mask;
  Point _maxSize;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------
  CAnimationObject(String instanceID, String regionID, String type, bool mask) {
    _instanceID = instanceID;
    _regionID = regionID;
    _type = type;
    _mask = mask;
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

  String get instanceID =>  _instanceID;

  String get regionID =>  _regionID;

  bool get mask => _mask;

  String get type => _type;

  Point get maxSize =>  _maxSize;

  void set maxSize(Point value) {
    _maxSize = value;
  }
}
