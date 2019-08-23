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

  // load and show the gun swap GAF asset

  var gafAsset = await GAFAsset.load('assets/gun_swap/gun_swap.gaf', 1, 1);
  var gafTimeline = gafAsset.getGAFTimelineByLinkage('rootTimeline');

  var robot = GAFMovieClip(gafTimeline);
  robot.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
  robot.mouseChildren = false;
  robot.mouseCursor = MouseCursor.POINTER;
  robot.x = 250;
  robot.y = 280;
  stage.addChild(robot);
  stage.juggler.add(robot);
  robot.play(true);

  // prepare gun swap

  GAFBitmapData gun1 = gafAsset.getBitmapDataByLinkage("gun1");
  GAFBitmapData gun2 = gafAsset.getBitmapDataByLinkage("gun2");
  GAFBitmap gunSlot = robot.getChildByName("GUN");
  gunSlot.bitmapData = gun1;

  robot.onMouseClick.listen((MouseEvent e) {
    if (gunSlot.bitmapData == gun1) {
      gunSlot.bitmapData = gun2;
      gunSlot.pivotMatrix.translate(-24.2, -41.55);
    } else {
      gunSlot.bitmapData = gun1;
    }
  });

}
