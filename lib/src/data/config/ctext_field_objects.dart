part of stagexl_gaf;

class CTextFieldObjects {

  final Map<String, CTextFieldObject> _textFieldObjectsMap;

  CTextFieldObjects()
      : _textFieldObjectsMap = new Map<String, CTextFieldObject>();

  //--------------------------------------------------------------------------

  Iterable<CTextFieldObject> get textFieldObjects => _textFieldObjectsMap.values;

  //--------------------------------------------------------------------------

  void addTextFieldObject(CTextFieldObject textFieldObject) {
    if (_textFieldObjectsMap.containsKey(textFieldObject.id) == false) {
      _textFieldObjectsMap[textFieldObject.id] = textFieldObject;
    }
  }

  CTextFieldObject getTextFieldObject(String id) {
    return _textFieldObjectsMap[id];
  }

  CAnimationObject getAnimationObject(String id) {
    // what is this? this will always return null!
    var value = _textFieldObjectsMap[id];
    return value is CAnimationObject ? value : null;
  }

}
