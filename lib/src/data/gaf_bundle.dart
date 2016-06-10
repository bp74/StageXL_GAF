part of stagexl_gaf;

class GAFBundle {

  final GAFBundleLoader bundleLoader;
  final List<GAFAssetConfig> assetConfigs;

  GAFBundle._(this.bundleLoader, this.assetConfigs);

  //---------------------------------------------------------------------------

  static Future<GAFBundle> load(List<String> gafUrls) async {
    var bundleLoader = new GAFBundleGafLoader(gafUrls);
    var assetConfigs = await bundleLoader.loadAssetConfigs();
    var bundle = new GAFBundle._(bundleLoader, assetConfigs);
    return bundle;
  }

  static Future<GAFBundle> loadZip(List<int> zip) async {
    var decoder = new ZipDecoder();
    var archive = decoder.decodeBytes(zip);
    var bundleLoader = new GAFBundleZipLoader(archive);
    var assetConfigs = await bundleLoader.loadAssetConfigs();
    var bundle = new GAFBundle._(bundleLoader, assetConfigs);
    return bundle;
  }

  static Future<GAFBundle> loadZipUrl(String zipUrl) async {
    var request = HttpRequest.request(zipUrl, responseType: 'arraybuffer');
    var response = (await request).response;
    var zip = response.asUint8List();
    return GAFBundle.loadZip(zip);
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
    for (CTextureAtlas config in assetConfig.textureAtlases) {
      for (CTextureAtlasContent content in config.contents) {
        if (content.displayScale != displayScale) continue;
        if (content.contentScale != contentScale) continue;
        for (CTextureAtlasSource source in content.sources) {
          if (source.source == "no_atlas") continue;
          var renderTexture = await bundleLoader.loadTexture(source);
          var ta = new GAFTextureAtlas(renderTexture, config, content, source);
          gafAsset.textureAtlases.add(ta);
        }
      }
    }

    // load gaf sounds
    for (CSound config in assetConfig.sounds) {
      var sound = await bundleLoader.loadSound(config);
      var gafSound = new GAFSound(config, sound);
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

