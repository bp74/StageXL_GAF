part of stagexl_gaf;

class GAFBundle {

  final String path;
  final List<GAFAssetConfig> assetConfigs;
  final List<GAFTextureAtlasSource> textureAtlasSources;

  GAFBundle._(this.path, this.assetConfigs, this.textureAtlasSources);

  //---------------------------------------------------------------------------

  static Future<GAFBundle> load(List<String> gafUrls) async {

    var path = null;
    var assetConfigs = new List<GAFAssetConfig>();
    var textureAtlasSources = new List<GAFTextureAtlasSource>();

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

    return new GAFBundle._(path, assetConfigs, textureAtlasSources);
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

    //for (CSound csound in gafAssetConfig.sounds) {
    //var sound = await Sound.load(folderURL + csound.source);
    //var gafSound = new GAFSound(csound, sound);
    //gafAsset.sounds.add(gafSound);
    //}

    return gafAsset;
  }

  //---------------------------------------------------------------------------

  GAFAssetConfig _getAssetConfig(String assetID) {
    for (var assetConfig in this.assetConfigs) {
      if (assetConfig.id == assetID) return assetConfig;
    }
    return null;
  }

  Future<RenderTexture> _getRenderTexture(CTextureAtlasSource config) async {

    for(var textureAtlasSource in this.textureAtlasSources) {
      if (textureAtlasSource.config.id != config.id) continue;
      if (textureAtlasSource.config.source != config.source) continue;
      return textureAtlasSource.renderTexture;
    }

    var textureAtlasSource = new GAFTextureAtlasSource(config);
    this.textureAtlasSources.add(textureAtlasSource);

    var bitmapDataUrl = this.path + config.source;
    var bitmapData = await BitmapData.load(bitmapDataUrl);
    textureAtlasSource.completer.complete(bitmapData.renderTexture);

    return textureAtlasSource.renderTexture;;
  }

}