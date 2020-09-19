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

  @override
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

  @override
  CFilterData clone() {
    var filterData = CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.angle = angle;
    filterData.distance = distance;
    filterData.strength = strength;
    filterData.resolution = resolution;
    filterData.color = color;
    filterData.inner = inner;
    filterData.knockout = knockout;
    return filterData;
  }
}
