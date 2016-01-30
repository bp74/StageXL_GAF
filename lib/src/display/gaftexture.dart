part of stagexl_gaf;

class GAFTexture implements IGAFTexture {

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

  String _id;
  BitmapData _texture;
  Matrix _pivotMatrix;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------
  GAFTexture(String id, BitmapData texture, Matrix pivotMatrix) {
    this._id = id;
    this._texture = texture;
    this._pivotMatrix = pivotMatrix;
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------
  void copyFrom(IGAFTexture newTexture) {
    if (newTexture is GAFTexture) {
      this._id = newTexture.id;
      this._texture = newTexture.texture;
      this._pivotMatrix.copyFrom(newTexture.pivotMatrix);
    } else {
      throw new TypeError();
    }
  }
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

  BitmapData get texture => _texture;

  Matrix get pivotMatrix => _pivotMatrix;

  String get id => _id;

  IGAFTexture clone() {
    return new GAFTexture(_id, _texture, _pivotMatrix.clone());
  }
}
