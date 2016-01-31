part of stagexl_gaf;

class CAnimationFrame {

  final Map<String, CAnimationFrameInstance> _instancesMap;
  final List<CAnimationFrameInstance> _instances;
  final List<CFrameAction> _actions;
  final int frameNumber;

  CAnimationFrame(this.frameNumber)
      : _instancesMap = new Map<String, CAnimationFrameInstance>(),
        _instances = new List<CAnimationFrameInstance>(),
        _actions = new List<CFrameAction>();

  //---------------------------------------------------------------------------

  Iterable<CAnimationFrameInstance> get instances => _instances;
  Iterable<CFrameAction> get actions  => _actions;

  //---------------------------------------------------------------------------

  CAnimationFrame clone(int frameNumber) {
    CAnimationFrame result = new CAnimationFrame(frameNumber);
    _instances.forEach((instance) =>  result.addInstance(instance));
    return result;
  }

  void addInstance(CAnimationFrameInstance instance) {
    if (_instancesMap.containsKey(instance.id) == false) {
      _instances.add(instance);
      _instancesMap[instance.id] = instance;
    } else if (instance.alpha > 0) {
      int index = _instances.indexOf(_instancesMap[instance.id]);
      _instances[index] = instance;
      _instancesMap[instance.id] = instance;
    } else {
      int index = _instances.indexOf(_instancesMap[instance.id]);
      _instances.removeAt(index);
      _instancesMap.remove(instance.id);
    }
  }

  void addAction(CFrameAction action) {
    _actions.add(action);
  }

  void sortInstances() {
    _instances.sort((instance1, instance2) {
      if (instance1.zIndex < instance2.zIndex) return -1;
      if (instance1.zIndex > instance2.zIndex) return 1;
      return 0;
    });
  }

  CAnimationFrameInstance getInstanceByID(String id) {
    return _instancesMap[id];
  }

}
