part of slot_machine;

class SlotMachineGame extends Sprite implements Animatable {
  final SlotMachine machine;

  SlotMachineGame(this.machine) {
    addChild(machine);
    machine.play();

    var arm = machine.arm;
    arm.mouseCursor = MouseCursor.POINTER;
    arm.onMouseClick.listen((e) => machine.pullArm());

    var switchMachineBtn = machine.switchMachineBtn;
    switchMachineBtn.mouseCursor = MouseCursor.POINTER;
    switchMachineBtn.onMouseOver
        .listen((e) => switchMachineBtn.setSequence('Over'));
    switchMachineBtn.onMouseDown
        .listen((e) => switchMachineBtn.setSequence('Down'));
    switchMachineBtn.onMouseUp
        .listen((e) => switchMachineBtn.setSequence('Up'));
    switchMachineBtn.onMouseClick.listen((e) => machine.switchType());
  }

  @override
  bool advanceTime(num time) {
    machine.advanceTime(time);
    return true;
  }
}
