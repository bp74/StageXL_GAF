part of stagexl_gaf;

class CAnimationObjects {

  final Map<String, CAnimationObject> animationObjectsMap;

  CAnimationObjects()
      : animationObjectsMap = new Map<String, CAnimationObject>();

  //--------------------------------------------------------------------------

  void addAnimationObject(CAnimationObject animationObject) {
    if (animationObjectsMap.containsKey(animationObject.instanceID) == false) {
      animationObjectsMap[animationObject.instanceID] = animationObject;
    }
  }

  CAnimationObject getAnimationObject(String instanceID) {
    return animationObjectsMap[instanceID];
  }

}
