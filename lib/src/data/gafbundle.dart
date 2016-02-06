part of stagexl_gaf;

/// GAFBundle is utility class that used to save all converted GAFTimelines
/// from bundle in one place with easy access after conversion complete

class GAFBundle {

  String _name;
  GAFSoundData _soundData;

  final List<GAFAsset> _gafAssets;
  final Map<String, GAFAsset> _gafAssetsMap; // GAFAsset by SWF name

  GAFBundle()
      : _gafAssets = new List<GAFAsset>(),
        _gafAssetsMap = new Map<String, GAFAsset>();

  //--------------------------------------------------------------------------

  List<GAFAsset> get gafAssets => _gafAssets;

  GAFSoundData get soundData => _soundData;

  void set soundData(GAFSoundData soundData) {
    _soundData = soundData;
  }

  /// The name of the bundle. Used in GAFTimelinesManager to identify specific bundle.
  ///
  /// Should be specified by user using corresponding setter or by passing the
  /// name as second parameter in GAFTimelinesManager.addGAFBundle().
  /// The name can be auto-setted by ZipToGAFAssetConverter in two cases:
  /// dynamic 1) If ZipToGAFAssetConverter.id is not empty ZipToGAFAssetConverter
  /// sets the bundle name equal to it's id;
  /// 2) If ZipToGAFAssetConverter.id is empty, but gaf package (zip or folder)
  /// contain only one *.gaf config file, ZipToGAFAssetConverter sets the bundle
  /// name equal to the name of the *.gaf config file.

  String get name => _name;

  void set name(String name) {
    _name = name;
  }

  //--------------------------------------------------------------------------

  /// Returns [GAFTimeline] from bundle by [swfName] and [linkage].
  ///
  /// @param swfName is the name of SWF file where original timeline was
  /// located (or the name of the *.gaf config file where it is located).
  ///
  /// @param linkage is the linkage name of the timeline. If you need to get
  /// the Main Timeline from SWF use the "rootTimeline" linkage name.

  GAFTimeline getGAFTimeline(String swfName, [String linkage = "rootTimeline"]) {
    GAFTimeline gafTimeline;
    GAFAsset gafAsset = _gafAssetsMap[swfName];
    if (gafAsset != null) {
      gafTimeline = gafAsset.getGAFTimelineByLinkage(linkage);
    }

    return gafTimeline;
  }

  /// Returns [IGAFTexture] (custom image) from bundle by [swfName] and [linkage].
  ///
  /// Then it can be used to replace animation parts or create new animation parts.
  ///
  /// @param swfName is the name of SWF file where original Bitmap/Sprite was
  /// located (or the name of the *.gaf config file where it is located)
  /// @param linkage is the linkage name of the Bitmap/Sprite
  /// @param scale Texture atlas Scale that will be used for [IGAFTexture] creation.
  /// Possible values are values from converted animation config.
  /// @param csf Texture atlas content scale factor (that as CSF) will be used
  /// for [IGAFTexture] creation. Possible values are values from converted animation config.

  GAFTexture getCustomRegion(String swfName, String linkage, [num scale, num csf]) {
    GAFAsset gafAsset = _gafAssetsMap[swfName];
    return gafAsset?._getCustomRegion(linkage, scale, csf);
  }

  //--------------------------------------------------------------------------

  void _addGAFAsset(GAFAsset gafAsset) {
    if (!_gafAssetsMap.containsKey(gafAsset.id)) {
      _gafAssetsMap[gafAsset.id] = gafAsset;
      _gafAssets.add(gafAsset);
    } else {
      throw new StateError("Bundle error. More then one gaf asset use id: ${gafAsset.id}");
    }
  }

}
