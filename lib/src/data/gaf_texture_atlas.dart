part of stagexl_gaf;

class GAFTextureAtlas {

  final CTextureAtlasScale scale;
  final CTextureAtlasCSF contentScaleFactor;
  final CTextureAtlasSource textureAtlasSource;
  final TextureAtlas textureAtlas;

  GAFTextureAtlas(
      this.scale,
      this.contentScaleFactor,
      this.textureAtlasSource,
      this.textureAtlas);

  //---------------------------------------------------------------------------

  GAFBitmapData getBitmapData(int id) {

    var element = contentScaleFactor.elements.getElement(id);
    if (element?.atlasID != textureAtlasSource.id) return null;

    var scale9Grid = element.scale9Grid;
    var pivotMatrix = element.pivotMatrix;
    var bitmapData = textureAtlas.getBitmapData(id.toString());
    var renderTextureQuad = bitmapData.renderTextureQuad;

    return new GAFBitmapData(scale9Grid, pivotMatrix, renderTextureQuad);
  }


}
