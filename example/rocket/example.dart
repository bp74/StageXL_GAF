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
  var stage = Stage(canvas, width: 768, height: 1024);
  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  // load and show the mini game GAF asset

  var gafAsset = await GAFAsset.load('assets/mini_game/mini_game.gaf', 1, 1);
  var gafTimeline = gafAsset.getGAFTimelineByLinkage('rootTimeline');

  var miniGame = GAFMovieClip(gafTimeline);
  miniGame.play(true);
  stage.addChild(miniGame);
  stage.juggler.add(miniGame);

  // initialize the rockets

  for (int i = 1; i <= 4; i++) {
    GAFMovieClip animation = miniGame.getChildByName("Rocket_with_guide$i");
    GAFMovieClip rocket = animation.getChildByName("Rocket$i");
    rocket.setSequence("idle");
    rocket.onMouseDown.listen((me) {
      rocket.setSequence("explode");
      //rocket.mouseEnabled = false;
      rocket.onSequenceEnd.first.then((se) {
        rocket.setSequence("idle");
        //rocket.mouseEnabled = true;
      });
    });
  }
}
