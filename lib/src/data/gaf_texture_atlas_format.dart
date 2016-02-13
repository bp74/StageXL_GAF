part of stagexl_gaf;

class GAFTextureAtlasFormat extends TextureAtlasFormat {

  final CTextureAtlasCSF contentScaleFactor;
  final CTextureAtlasSource source;

  GAFTextureAtlasFormat(this.contentScaleFactor, this.source);

  //---------------------------------------------------------------------------

  Future<TextureAtlas> load(TextureAtlasLoader loader) async {

    var textureAtlas = new TextureAtlas();
    var textureAtlasUrl = source.source;
    if (textureAtlasUrl == "no_atlas") return textureAtlas;

    var renderTextureQuad = await loader.getRenderTextureQuad(textureAtlasUrl);
  //  renderTextureQuad = renderTextureQuad.withPixelRatio(contentScaleFactor.csf);

    for (var element in contentScaleFactor.elements.all) {

      var name = element.id.toString();
      var frmRect = element.region;
      var ofsRect = new Rectangle<int>(0, 0, frmRect.width, frmRect.height);

      var textureAtlasFrame = new TextureAtlasFrame(
          textureAtlas, renderTextureQuad, name, element.rotated ? 1 : 0,
          ofsRect.left, ofsRect.top, ofsRect.width, ofsRect.height,
          frmRect.left, frmRect.top, frmRect.width, frmRect.height,
          null, null);

      textureAtlas.frames.add(textureAtlasFrame);
    }

    return textureAtlas;
  }

}

