part of stagexl_gaf;

class CSound {

  static final String GAF_PLAY_SOUND = "gafPlaySound";
  static final int WAV = 0;
  static final int MP3 = 1;

  int soundID = 0;
  String linkageName = null;
  String source = null;
  int format = 0;
  int rate = 0;
  int sampleSize = 0;
  int sampleCount = 0;
  bool stereo = false;
  Sound sound = null;

}
