part of stagexl_gaf;

class CTextureAtlasContent {
  final num displayScale;
  final num contentScale;
  final List<CTextureAtlasSource> sources = <CTextureAtlasSource>[];

  CTextureAtlasContent(this.contentScale, this.displayScale);
}
