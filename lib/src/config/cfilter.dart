part of stagexl_gaf;

class CFilter {

  final List<CFilterData> filterDatas = new List<CFilterData>();

  //---------------------------------------------------------------------------

  void addBlurFilter(num blurX, num blurY) {
    var filterData = new CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.color = -1;
    filterDatas.add(filterData);
  }

  void addGlowFilter(
      num blurX, num blurY, int color,
      [num strength = 1, bool inner = false, bool knockout = false]) {

    var filterData = new CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.color = color;
    filterData.strength = strength;
    filterData.inner = inner;
    filterData.knockout = knockout;
    filterDatas.add(filterData);
  }

  void addDropShadowFilter(
      num blurX, num blurY, int color, num angle, num distance,
      [num strength = 1, bool inner = false, bool knockout = false]) {

    var filterData = new CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.color = color;
    filterData.angle = angle;
    filterData.distance = distance;
    filterData.strength = strength;
    filterData.inner = inner;
    filterData.knockout = knockout;
    filterDatas.add(filterData);
  }

  void addColorTransform(List<num> params) {
    var filterData = new CColorMatrixFilterData();

    filterData.colorMatrix[00] = params[1];       // R scale
    filterData.colorMatrix[05] = params[3];       // G scale
    filterData.colorMatrix[10] = params[5];       // B scale
    filterData.colorMatrix[15] = 1.0;             // A scale

    filterData.colorOffset[00] = params[2] * 256; // R offset
    filterData.colorOffset[01] = params[4] * 256; // G offset
    filterData.colorOffset[02] = params[6] * 256; // B offset
    filterData.colorOffset[03] = 0.0;             // A offset

    filterDatas.add(filterData);
  }

  void addColorMatrixFilter(List<num> params) {
    var filterData = new CColorMatrixFilterData();

    filterData.colorMatrix[00] = params[00];
    filterData.colorMatrix[01] = params[01];
    filterData.colorMatrix[02] = params[02];
    filterData.colorMatrix[03] = params[03];
    filterData.colorMatrix[04] = params[05];
    filterData.colorMatrix[05] = params[06];
    filterData.colorMatrix[06] = params[07];
    filterData.colorMatrix[07] = params[08];
    filterData.colorMatrix[08] = params[10];
    filterData.colorMatrix[09] = params[11];
    filterData.colorMatrix[10] = params[12];
    filterData.colorMatrix[11] = params[13];
    filterData.colorMatrix[12] = params[15];
    filterData.colorMatrix[13] = params[16];
    filterData.colorMatrix[14] = params[17];
    filterData.colorMatrix[15] = params[18];

    filterData.colorOffset[00] = params[04];
    filterData.colorOffset[01] = params[09];
    filterData.colorOffset[02] = params[14];
    filterData.colorOffset[03] = params[19];

    filterDatas.add(filterData);
  }

}
