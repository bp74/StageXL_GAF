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
      if (_isEquivalent(textureAtlas.contentScaleFactor, csf)) return textureAtlas;
    }
    return null;
  }

  //--------------------------------------------------------------------------

  bool _isEquivalent(num a, num b, [num epsilon=0.0001]) {
    return (a - epsilon < b) && (a + epsilon > b);
  }
}
