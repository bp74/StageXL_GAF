part of stagexl_gaf;

abstract class GAFBundleLoader {

  final List<GAFBundleTextureLoader> textureLoaders = [];
  final List<GAFBundleSoundLoader> soundLoaders = [];

  Future<List<GAFAssetConfig>> loadAssetConfigs();
  Future<RenderTexture> loadTexture(CTextureAtlasSource config);
  Future<Sound> loadSound(CSound config);

  Future<RenderTexture> _getTexture(
      CTextureAtlasSource config, Future<RenderTexture> load()) {

    for (var textureLoader in this.textureLoaders) {
      if (textureLoader.config.id != config.id) continue;
      if (textureLoader.config.source != config.source) continue;
      return textureLoader.completer.future;
    }

    var textureLoader = new GAFBundleTextureLoader(config);
    this.textureLoaders.add(textureLoader);

    load().then((renderTexture) {
      textureLoader.completer.complete(renderTexture);
    }).catchError((error) {
      textureLoader.completer.completeError(error);
    });

    return textureLoader.completer.future;
  }

  Future<Sound> _getSound(CSound config, Future<Sound> load()) {

    for (var soundLoader in this.soundLoaders) {
      if (soundLoader.config.id != config.id) continue;
      if (soundLoader.config.source != config.source) continue;
      return soundLoader.completer.future;
    }

    var soundLoader = new GAFBundleSoundLoader(config);
    this.soundLoaders.add(soundLoader);

    load().then((sound) {
      soundLoader.completer.complete(sound);
    }).catchError((error) {
      soundLoader.completer.completeError(error);
    });

    return soundLoader.completer.future;
  }
}

class GAFBundleTextureLoader {
  final CTextureAtlasSource config;
  final Completer<RenderTexture> completer = new Completer<RenderTexture>();
  GAFBundleTextureLoader(this.config);
}

class GAFBundleSoundLoader {
  final CSound config;
  final Completer<Sound> completer = new Completer<Sound>();
  GAFBundleSoundLoader(this.config);
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
      var converter = new GAFAssetConfigConverter(assetID);
      var assetConfig = converter.convert(binary, assetPath);
      assetConfigs.add(assetConfig);
    }
    return assetConfigs;
  }

  @override
  Future<RenderTexture> loadTexture(CTextureAtlasSource config) {
    return _getTexture(config, () async {
      var bitmapData = await BitmapData.load(config.source);
      return bitmapData.renderTexture;
    });
  }

  @override
  Future<Sound> loadSound(CSound config) {
    return _getSound(config, () => Sound.load(config.source));
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
      var converter = new GAFAssetConfigConverter(assetID);
      var assetConfig = converter.convert(fileContent.buffer, assetPath);
      assetConfigs.add(assetConfig);
    }
    return assetConfigs;
  }

  @override
  Future<RenderTexture> loadTexture(CTextureAtlasSource config) {
    return _getTexture(config, () async {
      var file = archive.files.firstWhere((f) => f.name == config.source);
      var fileBase64 = new Base64Encoder().convert(file.content);
      var imageDataUrl = "data:image/png;base64," + fileBase64;
      var bitmapData = await BitmapData.load(imageDataUrl);
      return bitmapData.renderTexture;
    });
  }

  @override
  Future<Sound> loadSound(CSound config) {
    return _getSound(config, () async {
      var file = archive.files.firstWhere((f) => f.name == config.source);
      var fileBase64 = new Base64Encoder().convert(file.content);
      var soundDataUrl = "data:audio/mp3;base64," + fileBase64;
      return Sound.loadDataUrl(soundDataUrl);
    });
  }
}
