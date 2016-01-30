part of stagexl_gaf;

class CTextureAtlasScale {

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

  num _scale;

  List<CTextureAtlasCSF> _allContentScaleFactors;
  CTextureAtlasCSF _contentScaleFactor;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  CTextureAtlasScale() {
    _allContentScaleFactors = new List<CTextureAtlasCSF>();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  void dispose() {
    for (CTextureAtlasCSF cTextureAtlasCSF in this._allContentScaleFactors) {
      cTextureAtlasCSF.dispose();
    }
  }

  CTextureAtlasCSF getTextureAtlasForCSF(num csf) {
    for (CTextureAtlasCSF textureAtlas in _allContentScaleFactors) {
      if (MathUtility.equals(textureAtlas.csf, csf)) {
        return textureAtlas;
      }
    }

    return null;
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

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

  num get scale => _scale;

  void set scale(num scale) {
    _scale = scale;
  }

  List<CTextureAtlasCSF> get allContentScaleFactors => _allContentScaleFactors;

  set allContentScaleFactors(List<CTextureAtlasCSF> value) {
    _allContentScaleFactors = value;
  }

  CTextureAtlasCSF get contentScaleFactor => _contentScaleFactor;

  void set contentScaleFactor(CTextureAtlasCSF value) {
    _contentScaleFactor = value;
  }
}
