part of stagexl_gaf.utils;

/*
/**
	 * @
	 */
class FiltersUtility {
  static dynamic getNativeFilter(ICFilterData data, [num scale = 1]) {
    dynamic nativeFilter;
    if (data is CBlurFilterData) {
      CBlurFilterData blurFilterData = data as CBlurFilterData;
      if (blurFilterData.angle) // DropShadowFilter
          {
        nativeFilter = new DropShadowFilter(
            blurFilterData.distance * scale,
            blurFilterData.angle,
            blurFilterData.color,
            blurFilterData.alpha,
            blurFilterData.blurX * scale,
            blurFilterData.blurY * scale,
            blurFilterData.strength,
            BitmapFilterQuality.HIGH,
            blurFilterData.inner,
            blurFilterData.knockout);
      } else if (blurFilterData.color >= 0) // GlowFilter
          {
        nativeFilter = new GlowFilter(
            blurFilterData.color,
            blurFilterData.alpha,
            blurFilterData.blurX * scale,
            blurFilterData.blurY * scale,
            blurFilterData.strength,
            BitmapFilterQuality.HIGH,
            blurFilterData.inner,
            blurFilterData.knockout);
      } else // BlurFilter
      {
        nativeFilter = new BlurFilter(blurFilterData.blurX * scale,
            blurFilterData.blurY * scale, BitmapFilterQuality.HIGH);
      }
    } else //if (data is CColorMatrixFilterData)
    {
      CColorMatrixFilterData cmFilterData = data as CColorMatrixFilterData;
      nativeFilter = new ColorMatrixFilter([].concat(cmFilterData.matrix));
    }

    return nativeFilter;
  }
}
*/
