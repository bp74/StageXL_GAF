part of stagexl_gaf;

class CTextureAtlas {
  final num displayScale;
  final List<CTextureAtlasContent> contents = <CTextureAtlasContent>[];
  final List<CTextureAtlasElement> elements = <CTextureAtlasElement>[];

  CTextureAtlas(this.displayScale);

  //--------------------------------------------------------------------------

  CTextureAtlasContent getTextureAtlasContent(num contentScale) {
    for (var content in contents) {
      if (content.contentScale == contentScale) return content;
    }
    return null;
  }

  CTextureAtlasElement getTextureAtlasElementByID(int elementID) {
    for (var element in elements) {
      if (element.id == elementID) return element;
    }
    return null;
  }
}
