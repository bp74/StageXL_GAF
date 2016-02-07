part of stagexl_gaf;

class CTextureAtlas {

  final Map<int, TextureAtlas> textureAtlasMap = new Map<int, TextureAtlas>();
  final CTextureAtlasCSF textureAtlasConfig;

  CTextureAtlas(Map<int, BitmapData> texturesMap, this.textureAtlasConfig) {

    for (var element in textureAtlasConfig.elements.all) {

      var name = element.id.toString();
      var renderTextureQuad = texturesMap[element.atlasID].renderTextureQuad;
      var textureAtlas = textureAtlasMap.putIfAbsent(element.atlasID, () => new TextureAtlas());
      var ofsRect = new Rectangle<int>(0, 0, element.region.width, element.region.height);
      var frmRect = element.region;

      var textureAtlasFrame = new TextureAtlasFrame(
          textureAtlas, renderTextureQuad, name, element.rotated ? 1 : 0,
          ofsRect.left, ofsRect.top, ofsRect.width, ofsRect.height,
          frmRect.left, frmRect.top, frmRect.width, frmRect.height,
          null, null);

      textureAtlas.frames.add(textureAtlasFrame);
    }
  }

  //--------------------------------------------------------------------------

  GAFBitmapData getBitmapData(int id) {

    var element = textureAtlasConfig.elements.getElement(id);
    if (element == null) return null;

    var atlasID = element.atlasID;
    var scale9Grid = element.scale9Grid;
    var pivotMatrix = element.pivotMatrix;
    var renderTextureQuad = getRenderTextureQuadByIDAndAtlasID(id, atlasID);
    return new GAFBitmapData(scale9Grid, pivotMatrix, renderTextureQuad);
  }

  RenderTextureQuad getRenderTextureQuadByIDAndAtlasID(int id, int atlasID) {
    var textureAtlas = textureAtlasMap[atlasID];
    var bitmapData = textureAtlas.getBitmapData(id.toString());
    return bitmapData.renderTextureQuad;
  }

}
