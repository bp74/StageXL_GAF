part of stagexl_gaf;

class CTextureAtlas {

  final num displayScale;
  final List<CTextureAtlasContent> contents = new List<CTextureAtlasContent>();
  final CTextureAtlasElements elements = new CTextureAtlasElements();

  CTextureAtlas(this.displayScale);

  //--------------------------------------------------------------------------

  CTextureAtlasContent getTextureAtlasContent(num contentScale) {
    for (var content in this.contents) {
      if (content.contentScale == contentScale) return content;
    }
    return null;
  }

}
