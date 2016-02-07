part of stagexl_gaf;

class CAnimationObjects {

  final Map<int, CAnimationObject> _animationObjectsMap;

  CAnimationObjects()
      : _animationObjectsMap = new Map<int, CAnimationObject>();

  //--------------------------------------------------------------------------

  Iterable<CAnimationObject> get all => _animationObjectsMap.values;

  //--------------------------------------------------------------------------

  void addAnimationObject(CAnimationObject animationObject) {
    if (_animationObjectsMap.containsKey(animationObject.instanceID) == false) {
      _animationObjectsMap[animationObject.instanceID] = animationObject;
    }
  }

  CAnimationObject getAnimationObject(int instanceID) {
    return _animationObjectsMap[instanceID];
  }

}
