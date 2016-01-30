part of stagexl_gaf;

class CAnimationObjects {

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

  Map<String, CAnimationObject> _animationObjectsMap;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  CAnimationObjects() {
    _animationObjectsMap = new Map<String, CAnimationObject>();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  void addAnimationObject(CAnimationObject animationObject) {
    if (!_animationObjectsMap.containsKey(animationObject.instanceID)) {
      _animationObjectsMap[animationObject.instanceID] = animationObject;
    }
  }

  CAnimationObject getAnimationObject(String instanceID) {
    if (_animationObjectsMap.containsKey(instanceID)) {
      return _animationObjectsMap[instanceID];
    } else {
      return null;
    }
  }

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

  Map get animationObjectsMap => _animationObjectsMap;

}
