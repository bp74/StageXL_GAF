part of stagexl_gaf;

/// <p>GAFTimeline represents converted GAF file. It is like a library symbol
/// in Flash IDE that contains all information about GAF animation.
/// It is used to create <code>GAFMovieClip</code> that is ready animation
/// object to be used in starling display list</p>

class GAFTimeline {

  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  static const String CONTENT_ALL = "contentAll";
  static const String CONTENT_DEFAULT = "contentDefault";
  static const String CONTENT_SPECIFY = "contentSpecify";

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  GAFTimelineConfig _config;

  GAFSoundData _gafSoundData;
  GAFGFXData _gafgfxData;
  GAFAsset _gafAsset;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  GAFTimeline(GAFTimelineConfig timelineConfig) {
    _config = timelineConfig;
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  // --------------------------------------------------------------------------

  /// Returns GAF Texture by name of an instance inside a timeline.

  GAFBitmapData getTextureByName(String animationObjectName) {
    int instanceID = _config.getNamedPartID(animationObjectName);
    if (instanceID != null) {
      CAnimationObject part = _config.animationObjects.getAnimationObject(instanceID);
      if (part != null) {
        return this.textureAtlas.getBitmapData(part.regionID);
      }
    }
    return null;
  }

  /// Load all graphical data connected with this asset in device GPU memory.
  /// Used in case of manual control of GPU memory usage.
  /// Works only in case when all graphical data stored in RAM
  /// (<code>Starling.handleLostContext</code> should be set to <code>true</code>
  /// before asset conversion)
  ///
  /// @param content content type that should be loaded. Available types: <code>CONTENT_ALL, CONTENT_DEFAULT, CONTENT_SPECIFY</code>
  /// @param scale in case when specified content is <code>CONTENT_SPECIFY</code> scale and csf should be set in required values
  /// @param csf in case when specified content is <code>CONTENT_SPECIFY</code> scale and csf should be set in required values

  void loadInVideoMemory([String content = "contentDefault", num scale, num csf]) {

    if (_config.textureAtlas?.contentScaleFactor?.elements == null) return;

    Map textures;
    CTextureAtlasCSF csfConfig;

    switch (content) {

      case CONTENT_ALL:
        for (CTextureAtlasScale scaleConfig in _config.allTextureAtlases) {
          for (csfConfig in scaleConfig.allContentScaleFactors) {
            _gafgfxData.createTextures(scaleConfig.scale, csfConfig.csf);
            textures = _gafgfxData.getTextures(scaleConfig.scale, csfConfig.csf);
            if (csfConfig.atlas == null && textures != null) {
              csfConfig.atlas = new CTextureAtlas(textures, csfConfig);
            }
          }
        }
        return;

      case CONTENT_DEFAULT:
        csfConfig = this._config.textureAtlas.contentScaleFactor;
        if (csfConfig == null)  return;

        if (csfConfig.atlas == null && _gafgfxData.createTextures(this.scale, this.contentScaleFactor)) {
          csfConfig.atlas = new CTextureAtlas(
              _gafgfxData.getTextures(this.scale, this.contentScaleFactor),
              csfConfig);
        }

        return;

      case CONTENT_SPECIFY:
        csfConfig = this.getCSFConfig(scale, csf);
        if (csfConfig == null) return;
        if (csfConfig.atlas == null && _gafgfxData.createTextures(scale, csf)) {
          csfConfig.atlas = new CTextureAtlas(_gafgfxData.getTextures(scale, csf), csfConfig);
        }
        return;
    }
  }

  /// Unload all all graphical data connected with this asset from device
  /// GPU memory. Used in case of manual control of video memory usage
  ///
  /// @param content content type that should be loaded (CONTENT_ALL, CONTENT_DEFAULT, CONTENT_SPECIFY)
  /// @param scale in case when specified content is CONTENT_SPECIFY scale and csf should be set in required values
  /// @param csf in case when specified content is CONTENT_SPECIFY scale and csf should be set in required values

  void unloadFromVideoMemory([String content = "contentDefault", num scale, num csf]) {

    if (_config.textureAtlas == null ||
        _config.textureAtlas.contentScaleFactor.elements == null) {
      return;
    }

    CTextureAtlasCSF csfConfig;

    switch (content) {
      case CONTENT_ALL:
        _gafgfxData.disposeTextures();
        //_config.dispose();
        return;
      case CONTENT_DEFAULT:
        _gafgfxData.disposeTextures(this.scale, this.contentScaleFactor);
        //_config.textureAtlas.contentScaleFactor.dispose();
        return;
      case CONTENT_SPECIFY:
        csfConfig = this.getCSFConfig(scale, csf);
        if (csfConfig != null) {
          _gafgfxData.disposeTextures(scale, csf);
          //csfConfig.dispose();
        }
        return;
    }
  }

  void startSound(int frame) {

    CFrameSound frameSoundConfig = this._config.getSound(frame);
    if (frameSoundConfig != null) {
      // use namespace gaf_internal;

      if (frameSoundConfig.action == CFrameSound.ACTION_STOP) {
        GAFSoundManager
            .getInstance()
            ._stop(frameSoundConfig.soundID, _config.assetID);
      } else {
        Sound sound;
        if (frameSoundConfig.linkage != null) {
          sound = this.gafSoundData.getSoundByLinkage(frameSoundConfig.linkage);
        } else {
          sound = this
              .gafSoundData
              .getSound(frameSoundConfig.soundID, _config.assetID);
        }
        Map soundOptions = {};
        soundOptions["continue"] =
            frameSoundConfig.action == CFrameSound.ACTION_CONTINUE;
        soundOptions["repeatCount"] = frameSoundConfig.repeatCount;
        GAFSoundManager.getInstance()._play(sound, frameSoundConfig.soundID,
            soundOptions, _config.assetID);
      }
    }
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  CTextureAtlasCSF getCSFConfig(num scale, num csf) {
    CTextureAtlasScale scaleConfig = _config.getTextureAtlasForScale(scale);
    if (scaleConfig != null) {
      CTextureAtlasCSF csfConfig = scaleConfig.getTextureAtlasForCSF(csf);
      if (csfConfig != null) {
        return csfConfig;
      } else {
        return null;
      }
    } else {
      return null;
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
		 * Timeline identifier (name given at animation's upload or assigned by developer)
		 */
  int get id => this.config.id;

  /**
		 * Timeline linkage in a *.fla file library
		 */
  String get linkage => this.config.linkage;

  /** @
		 * Asset identifier (name given at animation's upload or assigned by developer)
		 */
  String get assetID => this.config.assetID;

  /** @ */
  CTextureAtlas get textureAtlas {
    if (_config.textureAtlas == null) return null;

    if (_config.textureAtlas.contentScaleFactor.atlas == null) {
      this.loadInVideoMemory(CONTENT_DEFAULT);
    }

    return _config.textureAtlas.contentScaleFactor.atlas;
  }

  /** @ */
  GAFTimelineConfig get config => _config;

  ////////////////////////////////////////////////////////////////////////////

  /// Texture atlas scale that will be used for <code>GAFMovieClip</code> creation.
  /// To create <code>GAFMovieClip's</code> with different scale assign appropriate
  /// scale to <code>GAFTimeline</code> and only after that instantiate <code>GAFMovieClip</code>.
  /// Possible values are values from converted animation config. They are depends
  /// from project settings on site converter

  num get scale => _gafAsset.scale;

  set scale(num value) {

    if (_gafAsset.config.scaleValues.contains(value) == false) {
      throw new StateError(ErrorConstants.SCALE_NOT_FOUND);
    } else {
      _gafAsset.scale = scale;
    }

    if (_config.textureAtlas == null) return;

    num csf = this.contentScaleFactor;
    CTextureAtlasScale taScale = this._config.getTextureAtlasForScale(scale);
    if (taScale != null) {
      this._config.textureAtlas = taScale;

      CTextureAtlasCSF taCSF = _config.textureAtlas.getTextureAtlasForCSF(csf);

      if (taCSF != null) {
        _config.textureAtlas.contentScaleFactor = taCSF;
      } else {
        throw new StateError("There is no csf $csf in timeline config for scalse $scale");
      }
    } else {
      throw new StateError("There is no scale $scale in timeline config");
    }
  }


  /// Texture atlas content scale factor (that as csf) will be used for
  /// <code>GAFMovieClip</code> creation. To create <code>GAFMovieClip's</code>
  /// with different csf assign appropriate csf to <code>GAFTimeline</code> and
  /// only after that instantiate <code>GAFMovieClip</code>.
  /// Possible values are values from converted animation config.
  /// They are depends from project settings on site converter

  num get contentScaleFactor => _gafAsset.csf;

  set contentScaleFactor(num csf) {

    if (_gafAsset.config.csfValues.contains(csf)) {
      _gafAsset.csf = csf;
    }

    if (_config.textureAtlas == null) return;

    CTextureAtlasCSF taCSF = _config.textureAtlas.getTextureAtlasForCSF(csf);

    if (taCSF != null) {
      _config.textureAtlas.contentScaleFactor = taCSF;
    } else {
      throw new StateError("There is no csf $csf in timeline config");
    }
  }


  /// Graphical data storage that used by <code>GAFTimeline</code>.

  GAFGFXData get gafgfxData => _gafgfxData;

  set gafgfxData(GAFGFXData gafgfxData) {
    _gafgfxData = gafgfxData;
  }

  GAFAsset get gafAsset => _gafAsset;

  set gafAsset(GAFAsset asset) {
    _gafAsset = asset;
  }

  GAFSoundData get gafSoundData => _gafSoundData;

  set gafSoundData(GAFSoundData gafSoundData) {
    _gafSoundData = gafSoundData;
  }

  //--------------------------------------------------------------------------
  //
  //  STATIC METHODS
  //
  //--------------------------------------------------------------------------
}
