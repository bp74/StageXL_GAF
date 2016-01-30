part of stagexl_gaf;

class CFrameAction {

  int type;
  String scope;
  List<String> params = new List<String>();

  static const int STOP = 0;
  static const int PLAY = 1;
  static const int GOTO_AND_STOP = 2;
  static const int GOTO_AND_PLAY = 3;
  static const int DISPATCH_EVENT = 4;
}
