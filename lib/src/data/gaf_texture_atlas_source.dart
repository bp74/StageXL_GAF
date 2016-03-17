part of stagexl_gaf;

class GAFTextureAtlasSource {

  final CTextureAtlasSource config;
  final Completer<RenderTexture> completer = new Completer<RenderTexture>();

  GAFTextureAtlasSource(this.config);

  //---------------------------------------------------------------------------

  Future<RenderTexture> get renderTexture => completer.future;

}
