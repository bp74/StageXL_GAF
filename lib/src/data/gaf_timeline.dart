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

  /// Timeline identifier (name given at animation's upload or assigned by developer)

  int get id => this.config.id;

  /// Timeline linkage in a *.fla file library

  String get linkage => this.config.linkage;

  /// Asset identifier (name given at animation's upload or assigned by developer)

  String get assetID => this.config.assetID;

}
