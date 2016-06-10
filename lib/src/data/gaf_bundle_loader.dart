part of stagexl_gaf;

abstract class GAFBundleLoader {

  final List<GAFBundleTextureLoader> textureLoaders = [];
  final List<GAFBundleSoundLoader> soundLoaders = [];

  Future<List<GAFAssetConfig>> loadAssetConfigs();
  Future<RenderTexture> loadTexture(CTextureAtlasSource config);
  Future<Sound> loadSound(CSound config);

  GAFBundleTextureLoader _getTextureLoader(CTextureAtlasSource config) {
    for (var textureAtlasLoader in this.textureLoaders) {
      if (textureAtlasLoader.config.id != config.id) continue;
      if (textureAtlasLoader.config.source != config.source) continue;
      return textureAtlasLoader;
    }
    return null;
  }

  GAFBundleSoundLoader _getSoundLoader(CSound config) {
    for (var soundLoader in this.soundLoaders) {
      if (soundLoader.config.id != config.id) continue;
      if (soundLoader.config.source != config.source) continue;
      return soundLoader;
    }
    return null;
  }

  GAFBundleTextureLoader _createTextureLoader(CTextureAtlasSource config) {
    var textureLoader = new GAFBundleTextureLoader(config);
    this.textureLoaders.add(textureLoader);
    return textureLoader;
  }

  GAFBundleSoundLoader _createSoundLoader(CSound config) {
    var soundLoader = new GAFBundleSoundLoader(config);
    this.soundLoaders.add(soundLoader);
    return soundLoader;
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

  Future<RenderTexture> loadTexture(CTextureAtlasSource config) {
    var loader = _getTextureLoader(config);
    if (loader == null) {
      loader = _createTextureLoader(config);
      BitmapData.load(config.source).then((bitmapData) {
        loader.completer.complete(bitmapData.renderTexture);
      }).catchError((e) {
        loader.completer.completeError(e);
      });
    }
    return loader.completer.future;
  }

  Future<Sound> loadSound(CSound config) {
    var loader = _getSoundLoader(config);
    if (loader == null) {
      loader = _createSoundLoader(config);
      Sound.load(config.source).then((sound) {
        loader.completer.complete(sound);
      }).catchError((e) {
        loader.completer.completeError(e);
      });
    }
    return loader.completer.future;
  }
}

//-----------------------------------------------------------------------------

class GAFBundleZipLoader extends GAFBundleLoader {

  final Archive archive;

  GAFBundleZipLoader(this.archive);

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

  Future<RenderTexture> loadTexture(CTextureAtlasSource config) {
    var loader = _getTextureLoader(config);
    if (loader == null) {
      loader = _createTextureLoader(config);
      var file = this.archive.files.firstWhere((f) => f.name == config.source);
      var fileBase64 = new Base64Encoder().convert(file.content);
      var imageDataUrl = "data:image/png;base64," + fileBase64;
      BitmapData.load(imageDataUrl).then((bitmapData) {
        loader.completer.complete(bitmapData.renderTexture);
      }).catchError((e) {
        loader.completer.completeError(e);
      });
    }
    return loader.completer.future;
  }

  Future<Sound> loadSound(CSound config) {
    var loader = _getSoundLoader(config);
    if (loader == null) {
      loader = _createSoundLoader(config);
      var completer = loader.completer;
      completer.completeError(new StateError("Sounds not jet supported"));
    }
    return loader.completer.future;
  }

}
