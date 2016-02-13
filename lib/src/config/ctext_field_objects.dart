part of stagexl_gaf;

class CTextFieldObjects {

  final Map<int, CTextFieldObject> _textFieldObjectsMap;

  CTextFieldObjects()
      : _textFieldObjectsMap = new Map<int, CTextFieldObject>();

  //--------------------------------------------------------------------------

  Iterable<CTextFieldObject> get all => _textFieldObjectsMap.values;

  //--------------------------------------------------------------------------

  void addTextFieldObject(CTextFieldObject textFieldObject) {
    if (_textFieldObjectsMap.containsKey(textFieldObject.id) == false) {
      _textFieldObjectsMap[textFieldObject.id] = textFieldObject;
    }
  }

  CTextFieldObject getTextFieldObject(int id) {
    return _textFieldObjectsMap[id];
  }

  CAnimationObject getAnimationObject(String id) {
    // what is this? this will always return null!
    var value = _textFieldObjectsMap[id];
    return value is CAnimationObject ? value : null;
  }

}
