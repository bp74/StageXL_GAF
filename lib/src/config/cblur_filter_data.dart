part of stagexl_gaf;

class CBlurFilterData implements CFilterData {

  num blurX = 0.0;
  num blurY = 0.0;
  num angle = 0.0;
  num distance = 0.0;
  num strength = 0.0;
  num resolution = 1.0;
  int color = 0;
  bool inner = false;
  bool knockout = false;

  //---------------------------------------------------------------------------

  CFilterData clone() {
    CBlurFilterData filterData = new CBlurFilterData();
    filterData.blurX = this.blurX;
    filterData.blurY = this.blurY;
    filterData.angle = this.angle;
    filterData.distance = this.distance;
    filterData.strength = this.strength;
    filterData.resolution = this.resolution;
    filterData.color = this.color;
    filterData.inner = this.inner;
    filterData.knockout = this.knockout;
    return filterData;
  }

}
