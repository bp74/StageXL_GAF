part of stagexl_gaf;

class CTextureAtlasCSF {

  final num scale;
  final num csf;
  final List<CTextureAtlasSource> sources = new List<CTextureAtlasSource>();

  CTextureAtlasElements elements = null;
  CTextureAtlas atlas = null;

  CTextureAtlasCSF(this.csf, this.scale);

}
