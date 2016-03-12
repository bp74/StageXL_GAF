import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_gaf/stagexl_gaf.dart';

Future main() async {

  // configure StageXL default options

  StageXL.stageOptions.renderEngine = RenderEngine.WebGL;
  StageXL.stageOptions.backgroundColor = Color.Black;
  StageXL.bitmapDataLoadOptions.webp = false;

  // init Stage and RenderLoop

  var canvas = html.querySelector('#stage');
  var stage = new Stage(canvas, width: 400, height: 600);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  var gafAsset = await GAFAsset.load('assets/ufo_monster/ufo_monster.gaf', 4, 1);
  var gafTimeline = gafAsset.getGAFTimelineByLinkage('rootTimeline');

  var ufoMonster = new GAFMovieClip(gafTimeline);
  ufoMonster.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
  ufoMonster.x = 190;
  ufoMonster.y = 350;
  ufoMonster.mouseCursor = MouseCursor.POINTER;
  stage.addChild(ufoMonster);
  stage.juggler.add(ufoMonster);
  ufoMonster.play(true);

}
