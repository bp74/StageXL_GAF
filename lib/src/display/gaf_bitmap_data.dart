part of stagexl_gaf;

class GAFBitmapData extends BitmapData {

  CTextureAtlasElement config;

  GAFBitmapData(this.config, RenderTextureQuad renderTextureQuad)
      : super.fromRenderTextureQuad(renderTextureQuad);

}
