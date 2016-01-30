part of stagexl_gaf;

class CAnimationFrame {

  // --------------------------------------------------------------------------
  //
  // PUBLIC VARIABLES
  //
  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  //
  // PRIVATE VARIABLES
  //
  // --------------------------------------------------------------------------

  Map _instancesMap;
  List<CAnimationFrameInstance> _instances;
  List<CFrameAction> _actions;
  int _frameNumber;

  // --------------------------------------------------------------------------
  //
  // CONSTRUCTOR
  //
  // --------------------------------------------------------------------------

  CAnimationFrame(int frameNumber) {
    _frameNumber = frameNumber;
    _instancesMap = {};
    _instances = new List<CAnimationFrameInstance>();
  }

  // --------------------------------------------------------------------------
  //
  // PUBLIC METHODS
  //
  // --------------------------------------------------------------------------

  CAnimationFrame clone(int frameNumber) {

    CAnimationFrame result = new CAnimationFrame(frameNumber);

    for (CAnimationFrameInstance instance in _instances) {
      result.addInstance(instance);
    }

    return result;
  }

  void addInstance(CAnimationFrameInstance instance) {

    if (_instancesMap.containsKey(instance.id)) {

      if (instance.alpha > 0) {
        _instances[_instances.indexOf(_instancesMap[instance.id])] = instance;
        _instancesMap[instance.id] = instance;
      } else {
        // Poping the last element and set it as the removed element
        int index = _instances.indexOf(_instancesMap[instance.id]);
        // If index is last element, just pop
        if (index == (_instances.length - 1)) {
          _instances.removeLast();
        } else {
          _instances[index] = _instances.removeLast();
        }

        _instancesMap.remove(instance.id);
      }
    } else {
      _instances.add(instance);
      _instancesMap[instance.id] = instance;
    }
  }

  void addAction(CFrameAction action) {
    _actions = _actions ?? new List<CFrameAction>();
    _actions.add(action);
  }

  void sortInstances() {
    _instances.sort(_sortByZIndex);
  }

  CAnimationFrameInstance getInstanceByID(String id) {
    return _instancesMap[id];
  }

  // --------------------------------------------------------------------------
  //
  // PRIVATE METHODS
  //
  // --------------------------------------------------------------------------

  num _sortByZIndex(CAnimationFrameInstance instance1, CAnimationFrameInstance instance2) {
    if (instance1.zIndex < instance2.zIndex) {
      return -1;
    } else if (instance1.zIndex > instance2.zIndex) {
      return 1;
    } else {
      return 0;
    }
  }

  // --------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  //
  // EVENT HANDLERS
  //
  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  //
  // GETTERS AND SETTERS
  //
  // --------------------------------------------------------------------------

  List<CAnimationFrameInstance> get instances => _instances;
  List<CFrameAction> get actions  => _actions;
  int get frameNumber =>  _frameNumber;

}
