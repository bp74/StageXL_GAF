part of stagexl_gaf;

class GAFTextureAtlas {

  final CTextureAtlas config;
  final CTextureAtlasContent configScale;
  final CTextureAtlasSource configSource;
  final Map<int, RenderTextureQuad> renderTextureQuads;

  GAFTextureAtlas(this.config, this.configScale, this.configSource)
      : renderTextureQuads = new Map<int, RenderTextureQuad>();

  //---------------------------------------------------------------------------

  Future load(String path) async {

    var textureAtlasUrl = configSource.source;
    if (textureAtlasUrl == "no_atlas") return;

    var bitmapData = await BitmapData.load(path + textureAtlasUrl);
    var source = bitmapData.renderTextureQuad;

    for (var element in configScale.elements.all) {
      var region = element.region;
      var rotation = element.rotated ? 1 : 0;
      var offset = new Rectangle<int>(0, 0, region.width, region.height);
      var quad = new RenderTextureQuad.slice(source, region, offset, rotation);
      renderTextureQuads[element.id] = quad;
    }
  }

  //---------------------------------------------------------------------------

  GAFBitmapData getBitmapData(int id) {

    var element = configScale.elements.getElement(id);
    if (element?.atlasID != configSource.id) return null;

    var scale9Grid = element.scale9Grid;
    var pivotMatrix = element.pivotMatrix;
    var renderTextureQuad = this.renderTextureQuads[id];

    return new GAFBitmapData(scale9Grid, pivotMatrix, renderTextureQuad);
  }


}
