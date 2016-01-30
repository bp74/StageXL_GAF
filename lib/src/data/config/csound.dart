part of stagexl_gaf;

class CSound {

  static final String GAF_PLAY_SOUND = "gafPlaySound";
  static final int WAV = 0;
  static final int MP3 = 1;

  int soundID;
  String linkageName;
  String source;
  int format;
  int rate;
  int sampleSize;
  int sampleCount;
  bool stereo;
  Sound sound;
}
