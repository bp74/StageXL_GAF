part of stagexl_gaf;

/**
	 * Graphical data storage that used by <code>GAFTimeline</code>. It contain all created textures and all
	 * saved images as <code>BitmapData</code> (in case when <code>Starling.handleLostContext = true</code> was set before asset conversion).
	 * Used as shared graphical data storage between several GAFTimelines if they are used the same texture atlas (bundle created using "Create bundle" option)
	 */
class GAFGFXData {
  // [Deprecated(since="5.0")]
  //static final String ATF = "ATF";
  // [Deprecated(replacement="Context3DTextureFormat.BGRA", since="5.0")]
  //static final String BGRA = Context3DTextureFormat.BGRA;
  // [Deprecated(replacement="Context3DTextureFormat.BGR_PACKED", since="5.0")]
  //static final String BGR_PACKED = Context3DTextureFormat.BGR_PACKED;
  // [Deprecated(replacement="Context3DTextureFormat.BGRA_PACKED", since="5.0")]
  //static final String BGRA_PACKED = Context3DTextureFormat.BGRA_PACKED;

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

  Map<num, Map<num, Map<String, BitmapData>>> _texturesMap = {};
  Map<num, Map<num, Map<String, TAGFX>>> _taGFXMap = {};

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  GAFGFXData() {}

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  void addTAGFX(num scale, num csf, String imageID, TAGFX taGFX) {
    _taGFXMap[scale] ??= {};
    _taGFXMap[scale][csf] ??= {};
    _taGFXMap[scale][csf][imageID] ??= taGFX;
  }

  Map<String, TAGFX> getTAGFXs(num scale, num csf) {
    if (_taGFXMap.containsKey(scale)) {
      return _taGFXMap[scale][csf];
    }
    return null;
  }

  TAGFX getTAGFX(num scale, num csf, String imageID) {
    if (_taGFXMap.containsKey(scale)) {
      if (_taGFXMap[scale].containsKey(csf)) {
        return _taGFXMap[scale][csf][imageID];
      }
    }
    return null;
  }

  /**
		 * Creates textures from all images for specified scale and csf.
		 * @param scale
		 * @param csf
		 * @return {bool}
		 * @see #createTexture()
		 */
  bool createTextures(num scale, num csf) {
    Map taGFXs = this.getTAGFXs(scale, csf);
    if (taGFXs != null) {
      _texturesMap[scale] ??= {};
      _texturesMap[scale][csf] ??= {};

      for (String imageAtlasID in taGFXs.keys) {
        _texturesMap[scale][csf][imageAtlasID] = taGFXs[imageAtlasID].texture;
      }
      return true;
    }

    return false;
  }

  /**
		 * Creates texture from specified image.
		 * @param scale
		 * @param csf
		 * @param imageID
		 * @return {bool}
		 * @see #createTextures()
		 */
  bool createTexture(num scale, num csf, String imageID) {
    var taGFX = this.getTAGFX(scale, csf, imageID);
    if (taGFX == null) return false;
    _texturesMap[scale] ??= {};
    _texturesMap[scale][csf] ??= {};
    _texturesMap[scale][csf][imageID] = taGFX.texture;
    return true;
  }

  /**
		 * Returns texture by unique key consist of scale + csf + imageID
		 */
  BitmapData getTexture(num scale, num csf, String imageID) {

    if (_texturesMap.containsKey(scale)) {
      if (_texturesMap[scale].containsKey(csf)) {
        if (_texturesMap[scale][csf].containsKey(imageID)) {
          return _texturesMap[scale][csf][imageID];
        }
      }
    }

    if (this.createTexture(scale, csf, imageID)) {
      return _texturesMap[scale][csf][imageID];
    }

    return null;
  }

  /// Returns textures for specified scale and csf in Map as combination
  /// key-value where key - is imageID and value - is Texture

  Map<String, BitmapData> getTextures(num scale, num csf) {
    if (_texturesMap.containsKey(scale)) {
      return _texturesMap[scale][csf];
    }
    return null;
  }

  /// Dispose specified texture or textures for specified combination scale
  /// and csf. If nothing was specified - dispose all texturea

  void disposeTextures([num scale, num csf, String imageID]) {
    if (scale == null) {
      for (String scaleToDispose in _texturesMap.keys) {
        this.disposeTextures(num.parse(scaleToDispose));
      }
    } else if (csf == null) {
      for (String csfToDispose in _texturesMap[scale]) {
        this.disposeTextures(scale, num.parse(csfToDispose));
      }
    } else if (_texturesMap[scale] == null) {
      // nothing to do
    } else if (_texturesMap[scale][csf] == null) {
      // nothing to do
    } else if (imageID == null) {
      for (String atlasIDToDispose in _texturesMap[scale][csf]) {
        this.disposeTextures(scale, csf, atlasIDToDispose);
      }
    } else {
      //_texturesMap[scale][csf][imageID].dispose();
      _texturesMap[scale][csf].remove(imageID);
    }
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

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
