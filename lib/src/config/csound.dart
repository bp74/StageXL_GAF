part of stagexl_gaf;

class CSound {

  static const String GAF_PLAY_SOUND = "gafPlaySound";
  static const int WAV = 0;
  static const int MP3 = 1;

  int id = 0;
  String linkage;
  String source;
  int format = 0;
  int rate = 0;
  int sampleSize = 0;
  int sampleCount = 0;
  bool stereo = false;
  Sound sound;

}
