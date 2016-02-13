part of stagexl_gaf;

/// <p>GAFTimeline represents converted GAF file. It is like a library symbol
/// in Flash IDE that contains all information about GAF animation.
/// It is used to create <code>GAFMovieClip</code> that is ready animation
/// object to be used in starling display list</p>

class GAFTimeline {

  final GAFAsset gafAsset;
  final GAFTimelineConfig config;

  num displayScale = 1.0;
  num contentScale = 1.0;

  GAFTimeline(this.gafAsset, this.config);

  //---------------------------------------------------------------------------

  /// Returns GAF Texture by name of an instance inside a timeline.

  GAFBitmapData getBitmapDataByID(int regionID) {
    return gafAsset.getGAFBitmapData(displayScale, contentScale, regionID);
  }

  void startSound(int frame) {
    /*
    CFrameSound frameSoundConfig = config.getSound(frame);
    if (frameSoundConfig != null) {
      // use namespace gaf_internal;

      if (frameSoundConfig.action == CFrameSound.ACTION_STOP) {
        GAFSoundManager
            .getInstance()
            ._stop(frameSoundConfig.soundID, config.assetID);
      } else {
        Sound sound;
        if (frameSoundConfig.linkage != null) {
          sound = this.gafSoundData.getSoundByLinkage(frameSoundConfig.linkage);
        } else {
          sound = this.gafSoundData.getSound(frameSoundConfig.soundID, config.assetID);
        }
        Map soundOptions = {};
        soundOptions["continue"] =
            frameSoundConfig.action == CFrameSound.ACTION_CONTINUE;
        soundOptions["repeatCount"] = frameSoundConfig.repeatCount;
        GAFSoundManager.getInstance()._play(sound, frameSoundConfig.soundID,
            soundOptions, config.assetID);
      }
    }
    */
  }

  //--------------------------------------------------------------------------
/*
  CTextureAtlasCSF getCSFConfig(num scale, num csf) {
    CTextureAtlasScale scaleConfig = config.getTextureAtlasForScale(scale);
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
*/

  //--------------------------------------------------------------------------

  /// Timeline identifier (name given at animation's upload or assigned by developer)

  int get id => this.config.id;

  /// Timeline linkage in a *.fla file library

  String get linkage => this.config.linkage;

  /// Asset identifier (name given at animation's upload or assigned by developer)

  String get assetID => this.config.assetID;

  /*
  CTextureAtlas get textureAtlas {

    CTextureAtlasScale scaleConfig = config.getTextureAtlasForScale(scale);
    if (scaleConfig != null) {
      CTextureAtlasCSF csfConfig = scaleConfig.getTextureAtlasForCSF(csf);

        if (config.textureAtlas == null) return null;
    if (config.textureAtlas.contentScaleFactor.atlas == null) {
      this.loadInVideoMemory(CONTENT_DEFAULT);
    }

    return config.textureAtlas.contentScaleFactor.atlas;
  }
*/
  ////////////////////////////////////////////////////////////////////////////

  /// Texture atlas scale that will be used for [GAFMovieClip] creation.
  /// To create <code>GAFMovieClip's</code> with different scale assign appropriate
  /// scale to <code>GAFTimeline</code> and only after that instantiate <code>GAFMovieClip</code>.
  /// Possible values are values from converted animation config. They are depends
  /// from project settings on site converter
/*
  num get scale => gafAsset.scale;

  set scale(num value) {

    if (gafAsset.config.scaleValues.contains(value) == false) {
      throw new StateError(ErrorConstants.SCALE_NOT_FOUND);
    } else {
      gafAsset.scale = scale;
    }

    if (config.textureAtlas == null) return;

    num csf = this.contentScaleFactor;
    CTextureAtlasScale taScale = config.getTextureAtlasForScale(scale);

    if (taScale != null) {
      config.textureAtlas = taScale;
      CTextureAtlasCSF taCSF = config.textureAtlas.getTextureAtlasForCSF(csf);

      if (taCSF != null) {
        config.textureAtlas.contentScaleFactor = taCSF;
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

  num get contentScaleFactor => gafAsset.csf;

  set contentScaleFactor(num csf) {

    if (gafAsset.config.csfValues.contains(csf)) {
      gafAsset.csf = csf;
    }

    if (config.textureAtlas == null) return;

    CTextureAtlasCSF taCSF = config.textureAtlas.getTextureAtlasForCSF(csf);

    if (taCSF != null) {
      config.textureAtlas.contentScaleFactor = taCSF;
    } else {
      throw new StateError("There is no csf $csf in timeline config");
    }
  }
*/
}
