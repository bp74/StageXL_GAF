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
  var stage = new Stage(canvas, width: 400, height: 400);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  // load and show tank GAF asset

  var gafAsset = await GAFAsset.load('assets/tank/tank.gaf',1, 1);
  var gafTimeline = gafAsset.getGAFTimelineByLinkage('rootTimeline');

  var tank = new GAFMovieClip(gafTimeline);
  tank.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
  tank.x = 200;
  tank.y = 200;
  tank.play(true);

  stage.addChild(tank);
  stage.juggler.add(tank);

}
