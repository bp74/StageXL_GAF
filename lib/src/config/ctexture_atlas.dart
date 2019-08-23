part of stagexl_gaf;

class CTextureAtlas {

  final num displayScale;
  final List<CTextureAtlasContent> contents = List<CTextureAtlasContent>();
  final List<CTextureAtlasElement> elements = List<CTextureAtlasElement>();

  CTextureAtlas(this.displayScale);

  //--------------------------------------------------------------------------

  CTextureAtlasContent getTextureAtlasContent(num contentScale) {
    for (var content in this.contents) {
      if (content.contentScale == contentScale) return content;
    }
    return null;
  }

  CTextureAtlasElement getTextureAtlasElementByID(int elementID) {
    for (var element in this.elements) {
      if (element.id == elementID) return element;
    }
    return null;
  }

}
