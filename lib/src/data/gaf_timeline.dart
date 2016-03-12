part of stagexl_gaf;

/// [GAFTimeline] represents converted GAF file. It is like a library symbol
/// in Flash IDE that contains all information about the GAF animation.
///
/// It is used to create [GAFMovieClip] that is ready animation
/// object to be used in starling display list.

class GAFTimeline {

  final GAFAsset gafAsset;
  final GAFTimelineConfig config;

  GAFTimeline(this.gafAsset, this.config);

  //---------------------------------------------------------------------------

  void startSound(int frame) {
    var frameSound = config.getSound(frame);
    if (frameSound == null) {
      // do nothing
    } else if (frameSound.action == CFrameSound.ACTION_STOP) {
      //GAFSoundManager.getInstance()._stop(frameSound.soundID, config.assetID);
    } else {
      //Sound sound = frameSound.linkage != null
      //    ? gafAsset.getSoundByLinkage(frameSound.linkage)
      //    : gafAsset.getSound(frameSound.soundID, config.assetID);
      //Map soundOptions = {};
      //soundOptions["continue"] = frameSound.action == CFrameSound.ACTION_CONTINUE;
      //soundOptions["repeatCount"] = frameSound.repeatCount;
      //GAFSoundManager.getInstance()._play(sound, frameSound.soundID, soundOptions, config.assetID);
    }
  }

  //--------------------------------------------------------------------------

  /// Timeline identifier (name given at animation's upload or assigned by developer)

  int get id => this.config.id;

  /// Timeline linkage in a *.fla file library

  String get linkage => this.config.linkage;

  /// Asset identifier (name given at animation's upload or assigned by developer)

  String get assetID => this.config.assetID;

}
