part of stagexl_gaf;

/// Utility class that allows easily manage all <code>GAFTimeline's</code>

class GAFTimelinesManager {

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

  static Map _bundlesByName = {};
  static Map _bundlesBySwfName = {};

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  /// Add all <code>GAFTimeline's</code> from bundle into timelines collection
  /// @param bundle
  /// @param bundleName The name of the bundle. Used in <code>GAFTimelinesManager</code> to identify specific bundle.

  static void addGAFBundle(GAFBundle bundle, [String bundleName = null]) {

    if (bundle != null) {
      for (GAFAsset asset in bundle.gafAssets) {
        if (!_bundlesBySwfName.containsKey(asset.id)) {
          _bundlesBySwfName[asset.id] = bundle;
        } else {
          throw new StateError("Trying to add GAF asset that already exist in collection. \"swfName\": " + asset.id);
        }
      }
      bundle.name ??= bundleName;
      if (bundle.name != null) {
        if (!_bundlesByName.containsKey(bundle.name)) {
          _bundlesByName[bundle.name] = bundle;
        } else {
          throw new StateError("Trying to add GAF bundle that already exist in collection. \"bundle.name\": " + bundle.name);
        }
      }
    } else {
      throw new ArgumentError("Invalid argument value. Value must be not null.");
    }
  }

  /// Returns <code>GAFTimeline</code> from timelines collection by <code>swfName</code> and <code>linkage</code>.
	/// @param swfName is the name of SWF file where original timeline was located (or the name of the *.gaf config file where it is located).
  /// @param linkage is the linkage name of the timeline. If you need to get the Main Timeline from SWF use the "rootTimeline" linkage name.
  /// @return <code>GAFTimeline</code> from timelines collection

  static GAFTimeline getGAFTimeline(String swfName, [String linkage = "rootTimeline"]) {
    GAFTimeline gafTimeline;
    GAFBundle bundle = _bundlesBySwfName[swfName];
    if (bundle != null) {
      gafTimeline = bundle.getGAFTimeline(swfName, linkage);
    }
    return gafTimeline;
  }

  /// Returns instance of <code>GAFMovieClip</code>. In case when <code>GAFTimeline</code>
  /// with specified swfName and linkage is absent - returns <code>null</code>
  ///
  /// @param swfName is the name of SWF file where original timeline was located (or the name of the *.gaf config file where it is located).
  /// @param linkage is the linkage name of the timeline. If you need to get the Main Timeline from SWF use the "rootTimeline" linkage name.
  /// @return new instance of <code>GAFMovieClip</code>

  static GAFMovieClip getGAFMovieClip(String swfName, [String linkage = "rootTimeline"]) {
    GAFMovieClip gafMovieClip;
    GAFTimeline gafTimeline = getGAFTimeline(swfName, linkage);
    if (gafTimeline != null) {
      gafMovieClip = new GAFMovieClip(gafTimeline);
    }
    return gafMovieClip;
  }

  /// Returns <code>IGAFTexture</code> (custom image) from bundle by <code>swfName</code> and <code>linkage</code>.
  /// Then it can be used to replace animation parts or create new animation parts.
  /// @param swfName is the name of SWF file where original Bitmap/Sprite was located (or the name of the *.gaf config file where it is located)
  /// @param linkage is the linkage name of the Bitmap/Sprite
  /// @param scale Texture atlas Scale that will be used for <code>IGAFTexture</code> creation. Possible values are values from converted animation config.
  /// @param csf Texture atlas content scale factor (that as CSF) will be used for <code>IGAFTexture</code> creation. Possible values are values from converted animation config.
  /// @return <code>IGAFTexture</code> (custom image) from bundle.
  /// @see com.catalystapps.gaf.data.GAFBundle.getCustomRegion();

  IGAFTexture getCustomRegion(String swfName, String linkage, [num scale, num csf]) {
    GAFBundle gafBundle = _bundlesBySwfName[swfName];
    if (gafBundle != null) {
      return gafBundle.getCustomRegion(swfName, linkage, scale, csf);
    }
    return null;
  }

  /// Removes specified <code>GAFBundle</code> object from the <code>GAFTimelinesManager</code> and dispose it.
  /// Use this method to free memory when all content of the specified bundle doesn't need anymore.
  /// @param bundleName the name of the bundle that was given to it when bundle was added to the <code>GAFTimelinesManager</code>.

  static void removeAndDisposeBundle(String bundleName) {
    if (bundleName != null) {
      removeAndDispose(bundleName);
    }
  }

  /// Removes all GAFBundle objects from the GAFTimelinesManager and dispose them.
  /// Use this method to free memory when all bundles don't need anymore.

  static void removeAndDisposeAll() {
    removeAndDispose();
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  static void removeAndDispose([String name = null]) {

    GAFBundle bundle;

    for (String swfName in _bundlesBySwfName) {
      bundle = _bundlesBySwfName[swfName];
      if (name == null || bundle.name == name) {
        bundle.dispose();
        _bundlesBySwfName.remove(swfName);
      }
    }

    if (name != null) {
      _bundlesByName.remove(name);
    } else {
      _bundlesByName.clear();
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
}
