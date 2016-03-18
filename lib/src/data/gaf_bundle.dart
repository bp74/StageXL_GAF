part of stagexl_gaf;

class GAFBundle {

  final String path;
  final List<GAFAssetConfig> assetConfigs;
  final List<GAFTextureAtlasLoader> textureAtlasLoaders;
  final List<GAFSoundLoader> soundLoaders;

  GAFBundle._(this.path, this.assetConfigs)
      : this.textureAtlasLoaders = new List<GAFTextureAtlasLoader>(),
        this.soundLoaders = new List<GAFSoundLoader>();

  //---------------------------------------------------------------------------

  static Future<GAFBundle> load(List<String> gafUrls) async {

    var path = null;
    var assetConfigs = new List<GAFAssetConfig>();

    for (var gafUrl in gafUrls) {
      var i1 = gafUrl.lastIndexOf("/") + 1;
      var i2 = gafUrl.indexOf(".", i1);
      var assetPath = gafUrl.substring(0, i1);
      var assetID = gafUrl.substring(i1, i2);
      var request = HttpRequest.request(gafUrl, responseType: "arraybuffer");
      var binary = (await request).response as ByteBuffer;
      var converter = new GAFAssetConfigConverter(assetID);
      var assetConfig = converter.convert(binary);
      assetConfigs.add(assetConfig);
      path ??= assetPath;
    }

    return new GAFBundle._(path, assetConfigs);
  }

  //---------------------------------------------------------------------------

  Future<GAFAsset> getAsset(String assetID,
      [num displayScale, num contentScale]) async {

    var assetConfig = _getAssetConfig(assetID);
    if (assetConfig == null) throw new ArgumentError("assetID");

    displayScale = displayScale ?? assetConfig.defaultDisplayScale;
    var displayScaleValues = assetConfig.displayScaleValues;
    var displayScaleValid = displayScaleValues.contains(displayScale);
    if (displayScaleValid == false) throw new ArgumentError("displayScale");

    contentScale = contentScale ?? assetConfig.defaultContentScale;
    var contentScaleValues = assetConfig.contentScaleValues;
    var contentScaleValid = contentScaleValues.contains(contentScale);
    if (contentScaleValid == false) throw new ArgumentError("contentScale");

    var gafAsset = new GAFAsset._(assetConfig, displayScale, contentScale);

    // load gaf timelines
    for (GAFTimelineConfig timelineConfig in assetConfig.timelines) {
      var gafTimeline = new GAFTimeline(gafAsset, timelineConfig);
      gafAsset.timelines.add(gafTimeline);
    }

    // load gaf texture atlases
    for (CTextureAtlas ta in assetConfig.textureAtlases) {
      for (CTextureAtlasContent taContent in ta.contents) {
        if (taContent.displayScale != displayScale) continue;
        if (taContent.contentScale != contentScale) continue;
        for (CTextureAtlasSource taSource in taContent.sources) {
          if (taSource.source == "no_atlas") continue;
          var renderTexture = await _getRenderTexture(taSource);
          var textureAtlas = new GAFTextureAtlas(renderTexture, ta, taContent);
          gafAsset.textureAtlases.add(textureAtlas);
        }
      }
    }

    // load gaf sounds
    for (CSound cs in assetConfig.sounds) {
      var sound = await _getSound(cs);
      var gafSound = new GAFSound(cs, sound);
      gafAsset.sounds.add(gafSound);
    }

    return gafAsset;
  }

  //---------------------------------------------------------------------------

  GAFAssetConfig _getAssetConfig(String assetID) {
    for (var assetConfig in this.assetConfigs) {
      if (assetConfig.id == assetID) return assetConfig;
    }
    return null;
  }

  Future<RenderTexture> _getRenderTexture(CTextureAtlasSource config) {

    for (var textureAtlasLoader in this.textureAtlasLoaders) {
      if (textureAtlasLoader.config.id != config.id) continue;
      if (textureAtlasLoader.config.source != config.source) continue;
      return textureAtlasLoader.completer.future;
    }

    var textureAtlasLoader = new GAFTextureAtlasLoader(config);
    this.textureAtlasLoaders.add(textureAtlasLoader);

    var completer = textureAtlasLoader.completer;
    var loader = BitmapData.load(this.path + config.source);
    loader.then((bd) => completer.complete(bd.renderTexture));
    return completer.future;
  }

  Future<Sound> _getSound(CSound config) {

    for (var soundLoader in this.soundLoaders) {
      if (soundLoader.config.id != config.id) continue;
      if (soundLoader.config.source != config.source) continue;
      return soundLoader.completer.future;
    }

    var soundLoader = new GAFSoundLoader(config);
    this.soundLoaders.add(soundLoader);

    var completer = soundLoader.completer;
    var loader = Sound.load(this.path + config.source);
    loader.then((s) => completer.complete(s));
    return completer.future;
  }

}