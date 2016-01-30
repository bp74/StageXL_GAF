part of stagexl_gaf;

class CTextureAtlasElements {

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

  List<CTextureAtlasElement> _elementsList;
  Map<String, CTextureAtlasElement> _elementsMap;
  Map<String, CTextureAtlasElement> _elementsByLinkage;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  CTextureAtlasElements() {
    _elementsList = new List<CTextureAtlasElement>();
    _elementsMap = new Map<String, CTextureAtlasElement>();
    _elementsByLinkage = new Map<String, CTextureAtlasElement>();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  void addElement(CTextureAtlasElement element) {
    if (!_elementsMap.containsKey(element.id)) {
      _elementsMap[element.id] = element;
      _elementsList.add(element);

      if (element.linkage != null) {
        _elementsByLinkage[element.linkage] = element;
      }
    }
  }

  CTextureAtlasElement getElement(String id) {
    if (_elementsMap.containsKey(id)) {
      return _elementsMap[id];
    } else {
      return null;
    }
  }

  CTextureAtlasElement getElementByLinkage(String linkage) {
    if (_elementsByLinkage.containsKey(linkage)) {
      return _elementsByLinkage[linkage];
    } else {
      return null;
    }
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

  List<CTextureAtlasElement> get elementsList => _elementsList;

}
