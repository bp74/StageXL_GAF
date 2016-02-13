import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:stagexl_gaf/stagexl_gaf.dart';

Future main() async {

  // configure StageXL default options

  StageXL.stageOptions.renderEngine = RenderEngine.WebGL;
  StageXL.stageOptions.backgroundColor = Color.DarkSlateGray;
  StageXL.bitmapDataLoadOptions.webp = false;

  // init Stage and RenderLoop

  var canvas = html.querySelector('#stage');
  var stage = new Stage(canvas, width: 800, height: 500);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  var gafAsset = await GAFAsset.load('assets/fireman/fireman.gaf', 1, 1);
  var gafTimeline = gafAsset.getGAFTimelineByLinkage('rootTimeline');

  var fireman = new GAFMovieClip(gafTimeline);
  stage.addChild(fireman);
  stage.juggler.add(fireman);
  fireman.play(true);

}
