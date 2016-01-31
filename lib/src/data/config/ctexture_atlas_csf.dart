part of stagexl_gaf;

class CTextureAtlasCSF {

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
  num _csf;

  List<CTextureAtlasSource> _sources;

  CTextureAtlasElements _elements;

  CTextureAtlas _atlas;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  CTextureAtlasCSF(num csf, num scale) {
    _csf = csf;
    _scale = scale;
    _sources = new List<CTextureAtlasSource>();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  void dispose() {
    //_atlas?.dispose();
    _atlas = null;
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

  num get csf => _csf;

  List<CTextureAtlasSource> get sources  => _sources;

  set sources(List<CTextureAtlasSource> sources) {
    _sources = sources;
  }

  CTextureAtlas get atlas => _atlas;

  set atlas(CTextureAtlas atlas) {
    _atlas = atlas;
  }

  CTextureAtlasElements get elements  => _elements;

  set elements(CTextureAtlasElements elements) {
    _elements = elements;
  }
}
