part of stagexl_gaf;

abstract class CFilterData {
  CFilterData clone();
}

//-----------------------------------------------------------------------------

class CColorMatrixFilterData implements CFilterData {

  final Float32List colorMatrix = Float32List(16);
  final Float32List colorOffset = Float32List(4);

  CColorMatrixFilterData() {
    colorMatrix[00] = 1.0; // R scale
    colorMatrix[05] = 1.0; // G scale
    colorMatrix[10] = 1.0; // B scale
    colorMatrix[15] = 1.0; // A scale
  }

  CFilterData clone() {
    var filterData = CColorMatrixFilterData();
    filterData.colorMatrix.setAll(0, colorMatrix);
    filterData.colorOffset.setAll(0, colorOffset);
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
    CBlurFilterData filterData = CBlurFilterData();
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
