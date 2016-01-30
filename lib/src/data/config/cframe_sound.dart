part of stagexl_gaf;

class CFrameSound {

  static final int ACTION_STOP = 1;
  static final int ACTION_START = 2;
  static final int ACTION_CONTINUE = 3;

  int soundID;
  int action;
  int repeatCount; //0 and 1 means play sound once
  String linkage;

  CFrameSound(Map data) {

    this.soundID = data["id"];
    this.action = data["action"];

    if (data.containsKey("linkage")) {
      this.linkage = data["linkage"];
    }

    if (data.containsKey("repeat")) {
      this.repeatCount = data["repeat"];
    }
  }
}
