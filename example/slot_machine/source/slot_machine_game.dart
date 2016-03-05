part of slot_machine;

/// Created by Nazar on 27.11.2014.

class SlotMachineGame extends Sprite implements Animatable {

  final SlotMachine machine;
  final Juggler juggler = new Juggler();

  SlotMachineGame(this.machine) {

    this.addChild(this.machine);
    this.machine.play();

    var arm = this.machine.arm;
    arm.onMouseClick.listen((e) => this.machine.start());

    var switchMachineBtn = this.machine.switchMachineBtn;
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
