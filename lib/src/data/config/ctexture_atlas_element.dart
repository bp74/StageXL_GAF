part of stagexl_gaf;

class CTextureAtlasElement {

  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  String _id = "";
  String _linkage = "";
  String _atlasID = "";
  Rectangle _region = null;
  Matrix _pivotMatrix = null;
  Rectangle _scale9Grid = null;
  bool _rotated = false;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  CTextureAtlasElement(String id, String atlasID) {
    _id = id;
    _atlasID = atlasID;
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  String get id => _id;

  Rectangle get region => _region;

  set region(Rectangle region) {
    _region = region;
  }

  Matrix get pivotMatrix => _pivotMatrix;

  set pivotMatrix(Matrix pivotMatrix) {
    _pivotMatrix = pivotMatrix;
  }

  String get atlasID => _atlasID;

  Rectangle get scale9Grid => _scale9Grid;

  set scale9Grid(Rectangle value) {
    _scale9Grid = value;
  }

  String get linkage => _linkage;

  set linkage(String value) {
    _linkage = value;
  }

  bool get rotated => _rotated;

  set rotated(bool value) {
    _rotated = value;
  }
}
