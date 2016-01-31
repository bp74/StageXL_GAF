part of stagexl_gaf;

/// GAFBundle is utility class that used to save all converted GAFTimelines
/// from bundle in one place with easy access after conversion complete

class GAFBundle {

  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  String _name;
  GAFSoundData _soundData;
  List<GAFAsset> _gafAssets;
  Map<String, GAFAsset> _gafAssetsMap; // GAFAsset by SWF name

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  GAFBundle() {
    _gafAssets = new List<GAFAsset>();
    _gafAssetsMap = new Map<String, GAFAsset>();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  /**
		 * Disposes all assets in bundle
		 */
  void dispose() {
    if (_gafAssets != null) {
      GAFSoundManager.getInstance().stopAll();
      _soundData.dispose();
      _soundData = null;
      _gafAssets?.forEach((ga) => ga..dispose());
      _gafAssets = null;
      _gafAssetsMap = null;
    }
  }

  /**
		 * Returns <code>GAFTimeline</code> from bundle by timelineID
		 * @param swfName is the name of swf file, used to create gaf file
		 * @return <code>GAFTimeline</code> on the stage of swf file
		 */
  // [Deprecated(replacement="com.catalystapps.gaf.data.GAFBundle.getGAFTimeline()", since="5.0")]
  GAFTimeline getGAFTimelineByID(String swfName) {
    GAFTimeline gafTimeline;
    GAFAsset gafAsset = _gafAssetsMap[swfName] as GAFAsset;
    if (gafAsset == null && gafAsset.timelines.length > 0) {
      gafTimeline = gafAsset.timelines[0];
    }

    return gafTimeline;
  }

  /**
		 * Returns <code>GAFTimeline</code> from bundle by linkage
		 * @param linkage linkage in a *.fla file library
		 * @return <code>GAFTimeline</code> from bundle
		 */
  // [Deprecated(replacement="com.catalystapps.gaf.data.GAFBundle.getGAFTimeline()", since="5.0")]
  GAFTimeline getGAFTimelineByLinkage(String linkage) {
    int i;
    GAFAsset gafAsset;
    GAFTimeline gafTimeline;
    while (gafAsset == null && i < _gafAssets.length) {
      gafAsset = _gafAssets[i++];
      gafTimeline = gafAsset.getGAFTimelineByLinkage(linkage);
    }

    return gafTimeline;
  }

  /**
		 * Returns <code>GAFTimeline</code> from bundle by <code>swfName</code> and <code>linkage</code>.
		 * @param swfName is the name of SWF file where original timeline was located (or the name of the *.gaf config file where it is located).
		 * @param linkage is the linkage name of the timeline. If you need to get the Main Timeline from SWF use the "rootTimeline" linkage name.
		 * @return <code>GAFTimeline</code> from bundle
		 */
  GAFTimeline getGAFTimeline(String swfName, [String linkage = "rootTimeline"]) {
    GAFTimeline gafTimeline;
    GAFAsset gafAsset = _gafAssetsMap[swfName];
    if (gafAsset != null) {
      gafTimeline = gafAsset.getGAFTimelineByLinkage(linkage);
    }

    return gafTimeline;
  }

  /**
		 * Returns <code>IGAFTexture</code> (custom image) from bundle by <code>swfName</code> and <code>linkage</code>.
		 * Then it can be used to replace animation parts or create new animation parts.
		 * @param swfName is the name of SWF file where original Bitmap/Sprite was located (or the name of the *.gaf config file where it is located)
		 * @param linkage is the linkage name of the Bitmap/Sprite
		 * @param scale Texture atlas Scale that will be used for <code>IGAFTexture</code> creation. Possible values are values from converted animation config.
		 * @param csf Texture atlas content scale factor (that as CSF) will be used for <code>IGAFTexture</code> creation. Possible values are values from converted animation config.
		 * @return <code>IGAFTexture</code> (custom image) from bundle.
		 * @see com.catalystapps.gaf.display.GAFImage
		 * @see com.catalystapps.gaf.display.GAFImage#changeTexture()
		 */
  IGAFTexture getCustomRegion(String swfName, String linkage, [num scale, num csf]) {
    IGAFTexture gafTexture;
    GAFAsset gafAsset = _gafAssetsMap[swfName];
    if (gafAsset != null) {
      gafTexture = gafAsset._getCustomRegion(linkage, scale, csf);
    }

    return gafTexture;
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  GAFTimeline _getGAFTimelineBySWFNameAndID(String swfName, String id) {
    GAFTimeline gafTimeline;
    GAFAsset gafAsset = _gafAssetsMap[swfName];
    if (gafAsset != null) {
      gafTimeline = gafAsset._getGAFTimelineByID(id);
    }

    return gafTimeline;
  }

  void _addGAFAsset(GAFAsset gafAsset) {
    if (!this._gafAssetsMap.containsKey(gafAsset.id)) {
      _gafAssetsMap[gafAsset.id] = gafAsset;
      _gafAssets.add(gafAsset);
    } else {
      throw new StateError("Bundle error. More then one gaf asset use id: '" +
          gafAsset.id +
          "'");
    }
  }

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  /**
		 * Returns all <code>GAFTimeline's</code> from bundle as <code>List/code>
		 */
  // [Deprecated(replacement="com.catalystapps.gaf.data.GAFBundle.getGAFTimeline()", since="5.0")]
  List<GAFTimeline> get timelines {

    GAFAsset gafAsset;
    List<GAFTimeline> timelines = new List<GAFTimeline>();

    int al = _gafAssets.length;
    for (int i = 0; i < al; i++) {
      gafAsset = _gafAssets[i];
      int tl = gafAsset.timelines.length;
      for (int j = 0; j < tl; j++) {
        timelines.add(gafAsset.timelines[j]);
      }
    }

    return timelines;
  }

  GAFSoundData get soundData => _soundData;

  void set soundData(GAFSoundData soundData) {
    _soundData = soundData;
  }

  List<GAFAsset> get gafAssets => _gafAssets;

  /**
		 * The name of the bundle. Used in GAFTimelinesManager to identify specific bundle.
		 * Should be specified by user using corresponding setter or by passing the name as second parameter in GAFTimelinesManager.addGAFBundle().
		 * The name can be auto-setted by ZipToGAFAssetConverter in two cases: dynamic 1) If ZipToGAFAssetConverter.id is not empty ZipToGAFAssetConverter sets the bundle name equal to it's id;
		 * 2) If ZipToGAFAssetConverter.id is empty, but gaf package (zip or folder) contain only one *.gaf config file,
		 * ZipToGAFAssetConverter sets the bundle name equal to the name of the *.gaf config file.
		 */
  String get name => _name;

  void set name(String name) {
    _name = name;
  }
}
