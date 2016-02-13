part of stagexl_gaf;

class GAFTextureAtlas {

  final CTextureAtlas config;
  final CTextureAtlasContent configContent;
  final CTextureAtlasSource configSource;
  final Map<int, GAFBitmapData> gafBitmapDatas = new Map<int, GAFBitmapData>();

  GAFTextureAtlas(this.config, this.configContent, this.configSource);

  //---------------------------------------------------------------------------

  Future load(String path) async {

    var bitmapDataFile = configSource.source;
    if (bitmapDataFile == "no_atlas") return;
    var bitmapData = await BitmapData.load(path + bitmapDataFile);

    for (var element in config.elements.all) {

      if (element.atlasID != configSource.id) continue;

      var region = element.region;
      var scale9Grid = element.scale9Grid;
      var matrix = element.matrix;
      var rotation = element.rotated ? 1 : 0;
      var scale = configContent.contentScale;
      var rtq = bitmapData.renderTextureQuad;

      var srcLeft = (region.left * scale).round();
      var srcTop = (region.top * scale).round();
      var srcWidth = (region.width * scale).round();
      var srcHeight = (region.height * scale).round();
      var src = new Rectangle<int>(srcLeft, srcTop, srcWidth, srcHeight);

      var ofsLeft = 0;
      var ofsTop = 0;
      var ofsWidth =  element.rotated ? region.height : region.width;
      var ofsHeight =  element.rotated ? region.width : region.height;
      var ofs = new Rectangle<int>(ofsLeft, ofsTop, ofsWidth, ofsHeight);

      var quad = new RenderTextureQuad.slice(rtq, src, ofs, rotation);
      var quadPR = quad.withPixelRatio(scale);
      var gafBitmapData = new GAFBitmapData(scale9Grid, matrix, quadPR);

      this.gafBitmapDatas[element.id] = gafBitmapData;
    }
  }

}
