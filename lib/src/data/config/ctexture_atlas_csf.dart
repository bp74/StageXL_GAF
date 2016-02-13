part of stagexl_gaf;

class CTextureAtlasCSF {

  final num scale;
  final num contentScaleFactor;
  final List<CTextureAtlasSource> sources = new List<CTextureAtlasSource>();

  CTextureAtlasElements elements = null;

  CTextureAtlasCSF(this.contentScaleFactor, this.scale);
}
