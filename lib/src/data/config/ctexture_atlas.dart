part of stagexl_gaf;

class CTextureAtlas {

  final num displayScale;
  final List<CTextureAtlasContent> contents;

  CTextureAtlas(this.displayScale)
      : contents = new List<CTextureAtlasContent>();

  //--------------------------------------------------------------------------

  CTextureAtlasContent getTextureAtlasContent(num contentScale) {
    for (var content in this.contents) {
      if (content.contentScale == contentScale) return content;
    }
    return null;
  }

}
