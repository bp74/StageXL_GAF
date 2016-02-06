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

  GAFTexture getTexture(String id) {

    var textureAtlasElement = textureAtlasConfig.elements.getElement(id);
    if (textureAtlasElement == null) return null;

    var atlasID = textureAtlasElement.atlasID;
    var scale9Grid = textureAtlasElement.scale9Grid;
    var pivotMatrix = textureAtlasElement.pivotMatrix;
    var texture =  getTextureByIDAndAtlasID(id, atlasID);
    return new GAFTexture(id, texture, pivotMatrix, scale9Grid);
  }

  //--------------------------------------------------------------------------

  BitmapData getTextureByIDAndAtlasID(String id, String atlasID) {
    var textureAtlas = textureAtlasMap[atlasID];
    var texture =  textureAtlas.getBitmapData(id);
    return texture;
  }

}
