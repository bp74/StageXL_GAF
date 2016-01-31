part of stagexl_gaf;

class CFrameSound {

  static final int ACTION_STOP = 1;
  static final int ACTION_START = 2;
  static final int ACTION_CONTINUE = 3;

  final int soundID;
  final int action;
  final int repeatCount;
  final String linkage;

  CFrameSound(this.soundID, this.action, this.repeatCount, this.linkage);

}
