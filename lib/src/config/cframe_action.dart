part of stagexl_gaf;

class CFrameAction {
  static const int STOP = 0;
  static const int PLAY = 1;
  static const int GOTO_AND_STOP = 2;
  static const int GOTO_AND_PLAY = 3;
  static const int DISPATCH_EVENT = 4;

  final int type;
  final String scope;
  final List<String> params = <String>[];

  CFrameAction(this.type, this.scope);
}
