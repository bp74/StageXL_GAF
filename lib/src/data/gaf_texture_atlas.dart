part of stagexl_gaf;

class GAFTextureAtlas {

  final CTextureAtlas config;
  final CTextureAtlasContent configScale;
  final CTextureAtlasSource configSource;
  final Map<int, GAFBitmapData> gafBitmapDatas;

  GAFTextureAtlas(this.config, this.configScale, this.configSource)
      : gafBitmapDatas = new Map<int, GAFBitmapData>();

  //---------------------------------------------------------------------------

  Future load(String path) async {

    var textureAtlasUrl = configSource.source;
    if (textureAtlasUrl == "no_atlas") return;

    var bitmapData = await BitmapData.load(path + textureAtlasUrl);
    var source = bitmapData.renderTextureQuad;

    for (var element in config.elements.all) {
      if (element.atlasID != configSource.id) continue;
      var region = element.region;
      var scale9Grid = element.scale9Grid;
      var pivotMatrix = element.pivotMatrix;
      var rotation = element.rotated ? 1 : 0;
      var offset = new Rectangle<int>(0, 0, region.width, region.height);
      var quad = new RenderTextureQuad.slice(source, region, offset, rotation);
      var gafBitmapData = new GAFBitmapData(scale9Grid, pivotMatrix, quad);
      gafBitmapDatas[element.id] = gafBitmapData;
    }
  }

  //---------------------------------------------------------------------------

  GAFBitmapData getGAFBitmapData(int id) {
    return this.gafBitmapDatas[id];
  }

}
