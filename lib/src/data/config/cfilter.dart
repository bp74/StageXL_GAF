part of stagexl_gaf;

class CFilter {

  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  List<ICFilterData> _filterConfigs = new List<ICFilterData>();

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  CFilter clone() {

    CFilter result = new CFilter();

    for (ICFilterData filterData in _filterConfigs) {
      result.filterConfigs.add(filterData.clone());
    }

    return result;
  }

  String addBlurFilter(num blurX, num blurY) {
    CBlurFilterData filterData = new CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.color = -1;
    _filterConfigs.add(filterData);
    return "";
  }

  String addGlowFilter(num blurX, num blurY, int color, num alpha,
      [num strength = 1, bool inner = false, bool knockout = false]) {
    CBlurFilterData filterData = new CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.color = color;
    filterData.alpha = alpha;
    filterData.strength = strength;
    filterData.inner = inner;
    filterData.knockout = knockout;

    _filterConfigs.add(filterData);

    return "";
  }

  String addDropShadowFilter(
      num blurX, num blurY, int color, num alpha, num angle, num distance,
      [num strength = 1, bool inner = false, bool knockout = false]) {
    CBlurFilterData filterData = new CBlurFilterData();
    filterData.blurX = blurX;
    filterData.blurY = blurY;
    filterData.color = color;
    filterData.alpha = alpha;
    filterData.angle = angle;
    filterData.distance = distance;
    filterData.strength = strength;
    filterData.inner = inner;
    filterData.knockout = knockout;

    _filterConfigs.add(filterData);

    return "";
  }

  void addColorTransform(List<num> params) {

    if (_getColorMatrixFilter() != null) return;

    CColorMatrixFilterData filterData = new CColorMatrixFilterData();

    VectorUtility.fillMatrix(
        filterData.matrix,
        params[1], 0, 0, 0, params[2],
        0, params[3], 0, 0, params[4],
        0, 0, params[5], 0, params[6],
        0, 0, 0, 1, 0);

    _filterConfigs.add(filterData);
  }

  String addColorMatrixFilter(List<num> params) {
    int i;

    for (i = 0; i < params.length; i++) {
      if (i % 5 == 4) {
        params[i] = params[i] / 255;
      }
    }

    CColorMatrixFilterData colorMatrixFilterConfig = new CColorMatrixFilterData();
    ListUtility.copyMatrix(colorMatrixFilterConfig.matrix, params);
    _filterConfigs.add(colorMatrixFilterConfig);

    return "";
  }

  CBlurFilterData getBlurFilter() {
    for (ICFilterData filterConfig in _filterConfigs) {
      if (filterConfig is CBlurFilterData) {
        return filterConfig as CBlurFilterData;
      }
    }

    return null;
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  CColorMatrixFilterData _getColorMatrixFilter() {
    for (ICFilterData filterConfig in _filterConfigs) {
      if (filterConfig is CColorMatrixFilterData) {
        return filterConfig as CColorMatrixFilterData;
      }
    }

    return null;
  }

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  List<ICFilterData> get filterConfigs => _filterConfigs;

}
