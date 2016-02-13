part of stagexl_gaf;

class GAFTextureAtlasLoader extends TextureAtlasLoader {

  final String path;

  GAFTextureAtlasLoader(this.path);

  //---------------------------------------------------------------------------

  @override
  Future<String> getSource() {
    return null;
  }

  @override
  Future<RenderTextureQuad> getRenderTextureQuad(String filename) async {
    var bitmapData = await BitmapData.load(this.path + filename);
    return bitmapData.renderTextureQuad;
  }

}