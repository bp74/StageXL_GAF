part of stagexl_gaf;

class GAFTextureAtlas {

  final CTextureAtlas config;
  final CTextureAtlasContent configContent;
  final CTextureAtlasSource configSource;
  final Map<int, GAFBitmapData> gafBitmapDatas = new Map<int, GAFBitmapData>();

  GAFTextureAtlas(this.config, this.configContent, this.configSource);

  //---------------------------------------------------------------------------

  Future load(String path) async {

    var textureAtlasUrl = configSource.source;
    if (textureAtlasUrl == "no_atlas") return;

    var bitmapData = await BitmapData.load(path + textureAtlasUrl);
    var source = bitmapData.renderTextureQuad;
    var scale = configContent.contentScale;

    for (var element in config.elements.all) {
      if (element.atlasID != configSource.id) continue;
      var region = element.region;
      var scale9Grid = element.scale9Grid;
      var pivotMatrix = element.pivotMatrix;
      var rotation = element.rotated ? 1 : 0;
      var frameX = (region.left * scale).round();
      var frameY = (region.top * scale).round();
      var frameWidth = (region.width * scale).round();
      var frameHeight = (region.height * scale).round();
      var frame = new Rectangle<int>(frameX, frameY, frameWidth, frameHeight);
      var offset = new Rectangle<int>(0, 0, region.width, region.height);
      var quad = new RenderTextureQuad.slice(source, frame, offset, rotation);
      var quadScale = quad.withPixelRatio(scale);
      var gafBitmapData = new GAFBitmapData(scale9Grid, pivotMatrix, quadScale);
      gafBitmapDatas[element.id] = gafBitmapData;
    }
  }

  //---------------------------------------------------------------------------

  GAFBitmapData getGAFBitmapData(int id) {
    return this.gafBitmapDatas[id];
  }

}
