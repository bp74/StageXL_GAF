import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_gaf/stagexl_gaf.dart';

Future main() async {
  // configure StageXL default options

  StageXL.stageOptions.renderEngine = RenderEngine.WebGL;
  StageXL.stageOptions.backgroundColor = Color.LightGray;
  StageXL.bitmapDataLoadOptions.webp = false;

  // init Stage and RenderLoop

  var canvas = html.querySelector('#stage');
  var stage = Stage(canvas, width: 550, height: 550);
  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  // load and show the red robot GAF asset

  var gafAsset = await GAFAsset.load('assets/RedRobot/RedRobot.gaf');
  var gafTimeline = gafAsset.getGAFTimelineByLinkage('rootTimeline');

  var robot = GAFMovieClip(gafTimeline);
  robot.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
  robot.mouseChildren = false;
  robot.mouseCursor = MouseCursor.POINTER;
  robot.x = 250;
  robot.y = 280;
  robot.play(true);

  stage.addChild(robot);
  stage.juggler.add(robot);

  // change sequence on click

  var currentSequence = 'none';

  void setSequence(String sequenceName) {
    robot.setSequence(sequenceName, true);
    (robot.getChildByName('sequence') as GAFTextField).text = sequenceName;
    currentSequence = sequenceName;
  }

  setSequence('stand');

  robot.onMouseClick.listen((me) {
    if (currentSequence == 'stand') {
      setSequence('walk');
    } else {
      setSequence('stand');
    }
  });
}
