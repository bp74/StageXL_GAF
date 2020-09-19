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
      // stop sound (not supported yet)
    } else if (frameSound.action == CFrameSound.ACTION_CONTINUE) {
      // continue sound (not supported yet)
    } else if (frameSound.linkage != null) {
      gafAsset.getGAFSoundByLinkage(frameSound.linkage).play();
    } else {
      gafAsset.getGAFSoundByID(frameSound.soundID).play();
    }
  }

  //--------------------------------------------------------------------------

  /// Timeline identifier (name given at animation's upload or assigned by developer)

  int get id => config.id;

  /// Timeline linkage in a *.fla file library

  String get linkage => config.linkage;

  /// Asset identifier (name given at animation's upload or assigned by developer)

  String get assetID => config.assetID;
}
