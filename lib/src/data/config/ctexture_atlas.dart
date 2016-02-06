part of stagexl_gaf;

class CTextureAtlas {

  final Map<String, TextureAtlas> textureAtlasMap = new Map<String, TextureAtlas>();
  final CTextureAtlasCSF textureAtlasConfig;

  CTextureAtlas(Map<String, BitmapData> texturesMap, this.textureAtlasConfig) {

    for (var element in textureAtlasConfig.elements.all) {

      var renderTextureQuad = texturesMap[element.atlasID].renderTextureQuad;
      var textureAtlas = textureAtlasMap.putIfAbsent(element.atlasID, () => new TextureAtlas());
      var ofsRect = new Rectangle<int>(0, 0, element.region.width, element.region.height);
      var frmRect = element.region;

      var textureAtlasFrame = new TextureAtlasFrame(
          textureAtlas, renderTextureQuad, element.id, element.rotated ? 1 : 0,
          ofsRect.left, ofsRect.top, ofsRect.width, ofsRect.height,
          frmRect.left, frmRect.top, frmRect.width, frmRect.height,
          null, null);

      textureAtlas.frames.add(textureAtlasFrame);
    }
  }

  //--------------------------------------------------------------------------

  GAFBitmapData getTexture(String id) {

    var element = textureAtlasConfig.elements.getElement(id);
    if (element == null) return null;

    var atlasID = element.atlasID;
    var scale9Grid = element.scale9Grid;
    var pivotMatrix = element.pivotMatrix;
    var renderTextureQuad = getRenderTextureQuadByIDAndAtlasID(id, atlasID);
    return new GAFBitmapData(scale9Grid, pivotMatrix, renderTextureQuad);
  }

  //--------------------------------------------------------------------------

  RenderTextureQuad getRenderTextureQuadByIDAndAtlasID(String id, String atlasID) {
    var textureAtlas = textureAtlasMap[atlasID];
    var bitmapData = textureAtlas.getBitmapData(id);
    return bitmapData.renderTextureQuad;
  }

}
