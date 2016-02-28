part of stagexl_gaf;

class GAFBitmapData extends BitmapData {

  CTextureAtlasElement element;

  GAFBitmapData(this.element, RenderTextureQuad renderTextureQuad)
      : super.fromRenderTextureQuad(renderTextureQuad);

}
