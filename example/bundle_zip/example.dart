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
  var stage = Stage(canvas, width: 600, height: 400);
  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  // load a GAF bundle, containing two GAF assets.
  // the GAF assets share a common texture!

  var gafBundle = await GAFBundle.loadZipUrl('assets/bundle.zip');

  // get skeleton from bundle and start animation

  var skeletonAsset = await gafBundle.getAsset('skeleton', 1, 1);
  var skeletonTimeline = skeletonAsset.getGAFTimelineByLinkage('rootTimeline');
  var skeleton = GAFMovieClip(skeletonTimeline);

  skeleton.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
  skeleton.x = 200;
  skeleton.y = 220;
  stage.addChild(skeleton);
  stage.juggler.add(skeleton);
  skeleton.play(true);

  // get ufo-monster from bundle and start animation

  var monsterAsset = await gafBundle.getAsset('ufo-monster', 1, 1);
  var monsterTimeline = monsterAsset.getGAFTimelineByLinkage('rootTimeline');
  var monster = GAFMovieClip(monsterTimeline);

  monster.alignPivot(HorizontalAlign.Center, VerticalAlign.Center);
  monster.x = 450;
  monster.y = 250;
  stage.addChild(monster);
  stage.juggler.add(monster);
  monster.play(true);
}
