part of stagexl_gaf;

abstract class CFilterData {
  CFilterData clone();
}

//-----------------------------------------------------------------------------

class CColorMatrixFilterData implements CFilterData {

  final Float32List matrix = new Float32List(20);

  CColorMatrixFilterData() {
    matrix[00] = 1.0; // R scale
    matrix[06] = 1.0; // G scale
    matrix[12] = 1.0; // B scale
    matrix[18] = 1.0; // A scale
  }

  CFilterData clone() {
    var filterData = new CColorMatrixFilterData();
    filterData.matrix.setAll(0, matrix);
    return filterData;
  }
}

//-----------------------------------------------------------------------------

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
