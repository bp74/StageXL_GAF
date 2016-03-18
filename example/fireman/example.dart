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

  // load and show the fireman GAF asset

  var gafAsset = await GAFAsset.load('assets/fireman/fireman.gaf', 1, 1);
  var gafTimeline = gafAsset.getGAFTimelineByLinkage('rootTimeline');

  var fireman = new GAFMovieClip(gafTimeline);
  stage.addChild(fireman);
  stage.juggler.add(fireman);
  fireman.play(true);

  // listen to custom events on the fireman MovieClip

  var subtitles_txt = fireman.getChildByName("subtitles_txt");
  var subtitles = [
    "Our game is on fire!",
    "GAF Team, there is a job for us!",
    "Go and do your best!"];

  fireman.on("showSubtitles").listen((ActionEvent e) {
    var subtitlesIndex = int.parse(e.data) - 1;
    subtitles_txt.text = subtitles[subtitlesIndex];
  });

  fireman.on("hideSubtitles").listen((ActionEvent e) {
    subtitles_txt.text = "";
  });
}
