part of stagexl_gaf;

class CAnimationFrame {

  final List<CAnimationFrameInstance> instances;
  final List<CFrameAction> actions;
  final int frameNumber;

  CAnimationFrame(this.frameNumber)
      : instances = List<CAnimationFrameInstance>(),
        actions = List<CFrameAction>();

  //---------------------------------------------------------------------------

  CAnimationFrame clone(int frameNumber) {
    CAnimationFrame result = CAnimationFrame(frameNumber);
    result.instances.addAll(instances);
    return result;
  }

  void updateInstance(CAnimationFrameInstance instance) {
    int index = -1;
    for (int i = 0; i < instances.length; i++) {
      if (instances[i].id == instance.id) {
        index = i;
        break;
      }
    }
    if (index == -1) {
      instances.add(instance);
    } else if (instance.alpha > 0) {
      instances[index] = instance;
    } else {
      instances.removeAt(index);
    }
  }

  void sortInstances() {
    instances.sort((i1, i2) => i1.zIndex - i2.zIndex);
  }

}
