part of stagexl_gaf;

class CStage {

  int fps;
  int color;
  int width;
  int height;

  //CStage clone(Map source) {
  CStage copyFrom(Map source) {
    this.fps = source["fps"];
    this.color = source["color"];
    this.width = source["width"];
    this.height = source["height"];
    return this;
  }
}
