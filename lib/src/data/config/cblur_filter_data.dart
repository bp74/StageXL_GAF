part of stagexl_gaf;

class CBlurFilterData implements CFilterData {

  num blurX;
  num blurY;
  int color;
  num angle = 0;
  num distance = 0;
  num strength = 0;
  num alpha = 1;
  bool inner;
  bool knockout;
  num resolution = 1;

  CFilterData clone() {

    CBlurFilterData copy = new CBlurFilterData();
    copy.blurX = this.blurX;
    copy.blurY = this.blurY;
    copy.color = this.color;
    copy.angle = this.angle;
    copy.distance = this.distance;
    copy.strength = this.strength;
    copy.alpha = this.alpha;
    copy.inner = this.inner;
    copy.knockout = this.knockout;
    copy.resolution = this.resolution;

    return copy;
  }
}
