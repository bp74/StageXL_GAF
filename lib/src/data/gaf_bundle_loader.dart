part of stagexl_gaf;

abstract class GAFBundleLoader {

  final List<GAFBundleTextureLoader> textureLoaders = [];
  final List<GAFBundleSoundLoader> soundLoaders = [];

  Future<List<GAFAssetConfig>> loadAssetConfigs();
  Future<RenderTexture> loadTexture(CTextureAtlasSource config);
  Future<Sound> loadSound(CSound config);

  Future<RenderTexture> getTexture(CTextureAtlasSource config) {
    for (var textureLoader in this.textureLoaders) {
      if (textureLoader.config.id != config.id) continue;
      if (textureLoader.config.source != config.source) continue;
      return textureLoader.future;
    }
    var textureFuture = this.loadTexture(config);
    var textureLoader = new GAFBundleTextureLoader(config, textureFuture);
    this.textureLoaders.add(textureLoader);
    return textureLoader.future;
  }

  Future<Sound> getSound(CSound config) {
    for (var soundLoader in this.soundLoaders) {
      if (soundLoader.config.id != config.id) continue;
      if (soundLoader.config.source != config.source) continue;
      return soundLoader.future;
    }
    var soundFuture = this.loadSound(config);
    var soundLoader = new GAFBundleSoundLoader(config, soundFuture);
    this.soundLoaders.add(soundLoader);
    return soundLoader.future;
  }
}

class GAFBundleTextureLoader {
  final CTextureAtlasSource config;
  final Future<RenderTexture> future;
  GAFBundleTextureLoader(this.config, this.future);
}

class GAFBundleSoundLoader {
  final CSound config;
  final Future<Sound> future;
  GAFBundleSoundLoader(this.config, this.future);
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class GAFBundleGafLoader extends GAFBundleLoader {

  final List<String> gafUrls;
  GAFBundleGafLoader(this.gafUrls);

  @override
  Future<List<GAFAssetConfig>> loadAssetConfigs() async {
    var assetConfigs = new List<GAFAssetConfig>();
    for (var gafUrl in gafUrls) {
      var i1 = gafUrl.lastIndexOf("/") + 1;
      var i2 = gafUrl.indexOf(".", i1);
      var assetPath = gafUrl.substring(0, i1);
      var assetID = gafUrl.substring(i1, i2);
      var request = HttpRequest.request(gafUrl, responseType: "arraybuffer");
      var binary = (await request).response as ByteBuffer;
      var converter = new GAFAssetConfigConverter(assetID, assetPath);
      var assetConfig = converter.convert(binary);
      assetConfigs.add(assetConfig);
    }
    return assetConfigs;
  }

  @override
  Future<RenderTexture> loadTexture(CTextureAtlasSource config) {
    return BitmapData.load(config.source).then((bd) => bd.renderTexture);
  }

  @override
  Future<Sound> loadSound(CSound config) {
    return Sound.load(config.source);
  }
}

//-----------------------------------------------------------------------------

class GAFBundleZipLoader extends GAFBundleLoader {

  final Archive archive;
  GAFBundleZipLoader(this.archive);

  @override
  Future<List<GAFAssetConfig>> loadAssetConfigs() async {
    var assetConfigs = new List<GAFAssetConfig>();
    var files = archive.files.where((f) => f.name.endsWith(".gaf"));
    for (ArchiveFile file in files) {
      var fileName = file.name;
      var fileContent = file.content;
      var i1 = fileName.lastIndexOf("/") + 1;
      var i2 = fileName.indexOf(".", i1);
      var assetPath = fileName.substring(0, i1);
      var assetID = fileName.substring(i1, i2);
      var converter = new GAFAssetConfigConverter(assetID, assetPath);
      var assetConfig = converter.convert(new Uint8List.fromList(fileContent).buffer);
      assetConfigs.add(assetConfig);
    }
    return assetConfigs;
  }

  @override
  Future<RenderTexture> loadTexture(CTextureAtlasSource config) {
    var file = archive.files.firstWhere((f) => f.name == config.source);
    var fileBase64 = BASE64.encoder.convert(file.content);
    var imageDataUrl = "data:image/png;base64," + fileBase64;
    return BitmapData.load(imageDataUrl).then((bd) => bd.renderTexture);
  }

  @override
  Future<Sound> loadSound(CSound config) {
    var file = archive.files.firstWhere((f) => f.name == config.source);
    var fileBase64 = BASE64.encoder.convert(file.content);
    var soundDataUrl = "data:audio/mp3;base64," + fileBase64;
    return Sound.loadDataUrl(soundDataUrl);
  }
}
