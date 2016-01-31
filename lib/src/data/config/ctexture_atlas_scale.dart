part of stagexl_gaf;

class CTextureAtlasScale {

  final num scale;
  final List<CTextureAtlasCSF> allContentScaleFactors;

  CTextureAtlasCSF contentScaleFactor = null;

  CTextureAtlasScale(this.scale)
      : allContentScaleFactors = new List<CTextureAtlasCSF>();

  //--------------------------------------------------------------------------

  CTextureAtlasCSF getTextureAtlasForCSF(num csf) {
    for (CTextureAtlasCSF textureAtlas in allContentScaleFactors) {
      if (MathUtility.equals(textureAtlas.csf, csf)) return textureAtlas;
    }
    return null;
  }

}
