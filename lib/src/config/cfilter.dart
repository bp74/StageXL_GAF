part of stagexl_gaf;

class CFilter {

  final List<CFilterData> _filterDatas = new List<CFilterData>();

  //---------------------------------------------------------------------------

  CFilter clone() {
    CFilter result = new CFilter();
    filterDatas.forEach((f) => result.addFilter(f.clone()));
    return result;
  }

  //---------------------------------------------------------------------------

  Iterable<CFilterData> get filterDatas => _filterDatas;

  void addFilter(CFilterData filterData) {
    _filterDatas.add(filterData);
  }

  //---------------------------------------------------------------------------

  void addBlurFilter(num blurX, num blurY) {
    CBlurFilterData filterData = new CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.color = -1;
    addFilter(filterData);
  }

  void addGlowFilter(
      num blurX, num blurY, int color,
      [num strength = 1, bool inner = false, bool knockout = false]) {

    CBlurFilterData filterData = new CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.color = color;
    filterData.strength = strength;
    filterData.inner = inner;
    filterData.knockout = knockout;
    addFilter(filterData);
  }

  void addDropShadowFilter(
      num blurX, num blurY, int color, num angle, num distance,
      [num strength = 1, bool inner = false, bool knockout = false]) {

    CBlurFilterData filterData = new CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.color = color;
    filterData.angle = angle;
    filterData.distance = distance;
    filterData.strength = strength;
    filterData.inner = inner;
    filterData.knockout = knockout;
    addFilter(filterData);
  }

  void addColorTransform(List<num> params) {
    if (_filterDatas.any((f) => f is CColorMatrixFilterData)) return;
    var filterData = new CColorMatrixFilterData();
    filterData.matrix[00] = params[1]; // R scale
    filterData.matrix[04] = params[2]; // R offset
    filterData.matrix[06] = params[3]; // G scale
    filterData.matrix[09] = params[4]; // G offset
    filterData.matrix[12] = params[5]; // B scale
    filterData.matrix[14] = params[6]; // B offset
    addFilter(filterData);
  }

  void addColorMatrixFilter(List<num> params) {
    CColorMatrixFilterData filterData = new CColorMatrixFilterData();
    filterData.matrix[00] = params[00];
    filterData.matrix[01] = params[01];
    filterData.matrix[02] = params[02];
    filterData.matrix[03] = params[03];
    filterData.matrix[04] = params[04] / 255;
    filterData.matrix[05] = params[05];
    filterData.matrix[06] = params[06];
    filterData.matrix[07] = params[07];
    filterData.matrix[08] = params[08];
    filterData.matrix[09] = params[09] / 255;
    filterData.matrix[10] = params[10];
    filterData.matrix[11] = params[11];
    filterData.matrix[12] = params[12];
    filterData.matrix[13] = params[13];
    filterData.matrix[14] = params[14] / 255;
    filterData.matrix[15] = params[15];
    filterData.matrix[16] = params[16];
    filterData.matrix[17] = params[17];
    filterData.matrix[18] = params[18];
    filterData.matrix[19] = params[19] / 255;
    addFilter(filterData);
  }

  //---------------------------------------------------------------------------

  CBlurFilterData getBlurFilter() {
    for (var filterData in _filterDatas) {
      if (filterData is CBlurFilterData) return filterData;
    }
    return null;
  }

  CColorMatrixFilterData getColorMatrixFilter() {
    for (var filterData in _filterDatas) {
      if (filterData is CColorMatrixFilterData) return filterData;
    }
    return null;
  }

}
