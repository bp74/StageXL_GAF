part of stagexl_gaf;

class CTextureAtlas {

  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  Map<String, TextureAtlas> _textureAtlasesMap;
  CTextureAtlasCSF _textureAtlasConfig;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  CTextureAtlas(Map<String, TextureAtlas> textureAtlasesMap, CTextureAtlasCSF textureAtlasConfig) {
    _textureAtlasesMap = textureAtlasesMap;
    _textureAtlasConfig = textureAtlasConfig;
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  static CTextureAtlas createFromTextures(Map<String, BitmapData> texturesMap, CTextureAtlasCSF textureAtlasConfig) {

    Map<String, TextureAtlas> atlasesMap = new Map<String, TextureAtlas>();

    for (CTextureAtlasElement element in textureAtlasConfig.elements.elementsList) {
      var bitmapData = texturesMap[element.atlasID];
      var textureAtlas = atlasesMap.putIfAbsent(element.atlasID, () => new TextureAtlas());
      var ofsRect = new Rectangle<int>(0, 0, element.region.width, element.region.height);
      var frmRect = element.region;
      var textureAtlasFrame = new TextureAtlasFrame(
          textureAtlas, bitmapData.renderTextureQuad, element.id, element.rotated ? 1 : 0,
          ofsRect.left, ofsRect.top, ofsRect.width, ofsRect.height,
          frmRect.left, frmRect.top, frmRect.width, frmRect.height,
          null, null);
      textureAtlas.frames.add(textureAtlasFrame);
    }

    return new CTextureAtlas(atlasesMap, textureAtlasConfig);
  }

  IGAFTexture getTexture(String id) {

    var textureAtlasElement = _textureAtlasConfig.elements.getElement(id);
    if (textureAtlasElement != null) {
      var texture =  _getTextureByIDAndAtlasID(id, textureAtlasElement.atlasID);
      var pivotMatrix = textureAtlasElement.pivotMatrix;
      if (textureAtlasElement.scale9Grid != null) {
        return new GAFScale9Texture(id, texture, pivotMatrix, textureAtlasElement.scale9Grid);
      } else {
        return new GAFTexture(id, texture, pivotMatrix);
      }
    }

    return null;
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  BitmapData _getTextureByIDAndAtlasID(String id, String atlasID) {
    var textureAtlas = _textureAtlasesMap[atlasID];
    var texture =  textureAtlas.getBitmapData(id);
    return texture;
  }


//--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------
}
