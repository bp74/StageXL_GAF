library slot_machine;

import 'dart:async';
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_gaf/stagexl_gaf.dart';

part 'source/sequence_playback_info.dart';
part 'source/slot_bar.dart';
part 'source/slot_machine.dart';
part 'source/slot_machine_game.dart';

// see design of the slot machine here:
// https://www.youtube.com/watch?v=6DWU0HhbNwM

Future main() async {

  // configure StageXL default options

  StageXL.stageOptions.renderEngine = RenderEngine.WebGL;
  StageXL.stageOptions.backgroundColor = Color.Black;
  StageXL.bitmapDataLoadOptions.webp = false;

  // init Stage and RenderLoop

  var canvas = html.querySelector('#stage');
  var stage = new Stage(canvas, width: 600, height: 1000);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  var gafAsset = await GAFAsset.load('assets/slot_machine/slot_machine.gaf', 1, 1);
  var gafTimeline = gafAsset.getGAFTimelineByLinkage('rootTimeline');

  var slotMachine = new SlotMachine(gafTimeline);
  var slotMachineGame = new SlotMachineGame(slotMachine);
  slotMachineGame.x = 40;
  slotMachineGame.y = 20;
  stage.addChild(slotMachineGame);
  stage.juggler.add(slotMachineGame);

//  stage.onEnterFrame.listen((e) => print(e.passedTime));

}
