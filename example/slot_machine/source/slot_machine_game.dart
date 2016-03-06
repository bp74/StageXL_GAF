part of slot_machine;

class SlotMachineGame extends Sprite implements Animatable {

  final SlotMachine machine;

  SlotMachineGame(this.machine) {

    this.addChild(this.machine);
    this.machine.play();

    var arm = this.machine.arm;
    arm.mouseCursor = MouseCursor.POINTER;
    arm.onMouseClick.listen((e) => this.machine.pullArm());

    var switchMachineBtn = this.machine.switchMachineBtn;
    switchMachineBtn.mouseCursor = MouseCursor.POINTER;
    switchMachineBtn.onMouseOver.listen((e) => switchMachineBtn.setSequence("Over"));
    switchMachineBtn.onMouseDown.listen((e) => switchMachineBtn.setSequence("Down"));
    switchMachineBtn.onMouseUp.listen((e) => switchMachineBtn.setSequence("Up"));
    switchMachineBtn.onMouseClick.listen((e) => this.machine.switchType());
  }

  bool advanceTime(num time) {
    machine.advanceTime(time);
    return true;
  }

}
