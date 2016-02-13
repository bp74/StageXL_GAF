part of stagexl_gaf;

class CTextureAtlasContent {

  final num displayScale;
  final num contentScale;

  final List<CTextureAtlasSource> sources = new List<CTextureAtlasSource>();

  CTextureAtlasElements elements = null;

  CTextureAtlasContent(this.contentScale, this.displayScale);
}
