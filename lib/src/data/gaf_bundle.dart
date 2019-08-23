part of stagexl_gaf;

class GAFBundle {

  final GAFBundleLoader bundleLoader;
  final List<GAFAssetConfig> assetConfigs;

  GAFBundle._(this.bundleLoader, this.assetConfigs);

  //---------------------------------------------------------------------------

  static Future<GAFBundle> load(List<String> gafUrls) {
    var bundleLoader = GAFBundleGafLoader(gafUrls);
    return GAFBundle.withLoader(bundleLoader);
  }

  static Future<GAFBundle> loadZip(List<int> zip) {
    var decoder = ZipDecoder();
    var archive = decoder.decodeBytes(zip);
    var bundleLoader = GAFBundleZipLoader(archive);
    return GAFBundle.withLoader(bundleLoader);
  }

  static Future<GAFBundle> loadZipUrl(String zipUrl) async {
    var request = HttpRequest.request(zipUrl, responseType: 'arraybuffer');
    var response = (await request).response as ByteBuffer;
    var zip = response.asUint8List();
    return GAFBundle.loadZip(zip);
  }

  static Future<GAFBundle> withLoader(GAFBundleLoader bundleLoader) async {
    var assetConfigs = await bundleLoader.loadAssetConfigs();
    return GAFBundle._(bundleLoader, assetConfigs);
  }

  //---------------------------------------------------------------------------

  Future<GAFAsset> getAsset(String assetID,
      [num displayScale, num contentScale]) async {

    var assetConfig = _getAssetConfig(assetID);
    if (assetConfig == null) throw ArgumentError("assetID");

    displayScale = displayScale ?? assetConfig.defaultDisplayScale;
    var displayScaleValues = assetConfig.displayScaleValues;
    var displayScaleValid = displayScaleValues.contains(displayScale);
    if (displayScaleValid == false) throw ArgumentError("displayScale");

    contentScale = contentScale ?? assetConfig.defaultContentScale;
    var contentScaleValues = assetConfig.contentScaleValues;
    var contentScaleValid = contentScaleValues.contains(contentScale);
    if (contentScaleValid == false) throw ArgumentError("contentScale");

    var gafAsset = GAFAsset._(assetConfig, displayScale, contentScale);

    // load gaf timelines
    for (GAFTimelineConfig timelineConfig in assetConfig.timelines) {
      var gafTimeline = GAFTimeline(gafAsset, timelineConfig);
      gafAsset.timelines.add(gafTimeline);
    }

    // load gaf texture atlases
    for (CTextureAtlas config in assetConfig.textureAtlases) {
      for (CTextureAtlasContent content in config.contents) {
        if (content.displayScale != displayScale) continue;
        if (content.contentScale != contentScale) continue;
        for (CTextureAtlasSource source in content.sources) {
          if (source.source == "no_atlas") continue;
          var renderTexture = await bundleLoader.getTexture(source);
          var ta = GAFTextureAtlas(renderTexture, config, content, source);
          gafAsset.textureAtlases.add(ta);
        }
      }
    }

    // load gaf sounds
    for (CSound config in assetConfig.sounds) {
      var sound = await bundleLoader.getSound(config);
      var gafSound = GAFSound(config, sound);
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

}

