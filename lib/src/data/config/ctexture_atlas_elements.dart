part of stagexl_gaf;

class CTextureAtlasElements {

  List<CTextureAtlasElement> _elements;
  Map<int, CTextureAtlasElement> _elementsMap;
  Map<String, CTextureAtlasElement> _elementsByLinkage;

  CTextureAtlasElements()
      : _elements = new List<CTextureAtlasElement>(),
        _elementsMap = new Map<int, CTextureAtlasElement>(),
        _elementsByLinkage = new Map<String, CTextureAtlasElement>();

  //--------------------------------------------------------------------------

  Iterable<CTextureAtlasElement> get all => _elements;

  //--------------------------------------------------------------------------

  void addElement(CTextureAtlasElement element) {
    if (!_elementsMap.containsKey(element.id)) {
      _elementsMap[element.id] = element;
      _elements.add(element);
      if (element.linkage != null) {
        _elementsByLinkage[element.linkage] = element;
      }
    }
  }

  CTextureAtlasElement getElement(int id) {
    return _elementsMap[id];
  }

  CTextureAtlasElement getElementByLinkage(String linkage) {
    return _elementsByLinkage[linkage];
  }

}
