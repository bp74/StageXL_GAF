part of stagexl_gaf;

class CTextureAtlas {

  final Map<String, TextureAtlas> textureAtlasMap = new Map<String, TextureAtlas>();
  final CTextureAtlasCSF textureAtlasConfig;

  CTextureAtlas(Map<String, BitmapData> texturesMap, this.textureAtlasConfig) {

    for (var element in textureAtlasConfig.elements.elements) {

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

  IGAFTexture getTexture(String id) {

    var textureAtlasElement = textureAtlasConfig.elements.getElement(id);
    if (textureAtlasElement != null) {
      var texture =  _getTextureByIDAndAtlasID(id, textureAtlasElement.atlasID);
      var pivotMatrix = textureAtlasElement.pivotMatrix;
      var scale9Grid = textureAtlasElement.scale9Grid;
      if (scale9Grid != null) {
        return new GAFScale9Texture(id, texture, pivotMatrix, scale9Grid);
      } else {
        return new GAFTexture(id, texture, pivotMatrix);
      }
    }

    return null;
  }

  //--------------------------------------------------------------------------

  BitmapData _getTextureByIDAndAtlasID(String id, String atlasID) {
    var textureAtlas = textureAtlasMap[atlasID];
    var texture =  textureAtlas.getBitmapData(id);
    return texture;
  }

}
