part of stagexl_gaf;

class GAFTextureAtlas {

  final CTextureAtlas config;
  final CTextureAtlasContent configContent;
  final CTextureAtlasSource configSource;
  final Map<int, GAFBitmapData> gafBitmapDatas = new Map<int, GAFBitmapData>();
  final RenderTexture renderTexture;

  GAFTextureAtlas(
      this.renderTexture,
      this.config, this.configContent, this.configSource) {

    var pixelRatio = configContent.contentScale;
    var rtq = renderTexture.quad;

    for (var element in config.elements) {

      if (element.atlasID != this.configSource.id) continue;

      var region = element.region;
      var rotation = element.rotated ? 1 : 0;

      var srcLeft = (region.left * pixelRatio).round();
      var srcTop = (region.top * pixelRatio).round();
      var srcWidth = (region.width * pixelRatio).round();
      var srcHeight = (region.height * pixelRatio).round();
      var src = new Rectangle<int>(srcLeft, srcTop, srcWidth, srcHeight);

      var ofsLeft = 0;
      var ofsTop = 0;
      var ofsWidth =  element.rotated ? region.height : region.width;
      var ofsHeight =  element.rotated ? region.width : region.height;
      var ofs = new Rectangle<int>(ofsLeft, ofsTop, ofsWidth, ofsHeight);

      var quad = new RenderTextureQuad.slice(rtq, src, ofs, rotation);
      var quadPixelRatio = quad.withPixelRatio(pixelRatio);
      var gafBitmapData = new GAFBitmapData(element, quadPixelRatio);

      this.gafBitmapDatas[element.id] = gafBitmapData;
    }
  }

}
