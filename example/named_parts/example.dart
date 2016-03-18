import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_gaf/stagexl_gaf.dart';

Future main() async {

  // configure StageXL default options

  StageXL.stageOptions.renderEngine = RenderEngine.WebGL;
  StageXL.stageOptions.backgroundColor = Color.White;
  StageXL.bitmapDataLoadOptions.webp = false;

  // init Stage and RenderLoop

  var canvas = html.querySelector('#stage');
  var stage = new Stage(canvas, width: 1024, height: 600);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  // load and show the plain robot asset

  var gafAsset1 = await GAFAsset.load('assets/robot_plain/robot.gaf');
  var gafTimeline1 = gafAsset1.getGAFTimelineByLinkage('rootTimeline');

  var gafMovieClip1 = new GAFMovieClip(gafTimeline1);
  gafMovieClip1.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
  gafMovieClip1.mouseChildren = false;
  gafMovieClip1.mouseCursor = MouseCursor.POINTER;
  gafMovieClip1.x = 256;
  gafMovieClip1.y = 300;
  gafMovieClip1.play(true);

  gafMovieClip1.onMouseClick.listen((me) {
    // toggle plain body-gun bitmap
    GAFBitmap bodyGun = gafMovieClip1.getChildByName("body_gun");
    bodyGun.visible = !bodyGun.visible;
  });

  stage.addChild(gafMovieClip1);
  stage.juggler.add(gafMovieClip1);

  // load and show the nesting robot asset

  var gafAsset2 = await GAFAsset.load('assets/robot_nesting/robot.gaf');
  var gafTimeline2 = gafAsset2.getGAFTimelineByLinkage('rootTimeline');

  var gafMovieClip2 = new GAFMovieClip(gafTimeline2);
  gafMovieClip2.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
  gafMovieClip2.mouseChildren = false;
  gafMovieClip2.mouseCursor = MouseCursor.POINTER;
  gafMovieClip2.x = 768;
  gafMovieClip2.y = 300;
  gafMovieClip2.play(true);

  gafMovieClip2.onMouseClick.listen((me) {
    // toggle nested body-gun bitmap
    GAFMovieClip body = gafMovieClip2.getChildByName("body");
    GAFBitmap gun = body.getChildByName("gun");
    gun.visible = !gun.visible;
  });

  stage.addChild(gafMovieClip2);
  stage.juggler.add(gafMovieClip2);

  // show some info texts

  var textFormat = new TextFormat("Arial", 24, Color.Black);

  var title = new TextField("Click the robots to show/hide guns", textFormat);
  title.autoSize = TextFieldAutoSize.CENTER;
  title.addTo(stage);
  title.x = 450;
  title.y = 20;

  var plain = new TextField("Conversion: Plain", textFormat);
  plain.autoSize = TextFieldAutoSize.CENTER;
  plain.addTo(stage);
  plain.x = 256 - 70;
  plain.y = 540;

  var nesting = new TextField("Conversion: Nesting", textFormat);
  nesting.autoSize = TextFieldAutoSize.CENTER;
  nesting.addTo(stage);
  nesting.x = 768 - 70;
  nesting.y = 540;

}
