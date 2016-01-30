part of stagexl_gaf;

class CAnimationFrameInstance {

  // --------------------------------------------------------------------------
  //
  // PUBLIC VARIABLES
  //
  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  //
  // PRIVATE VARIABLES
  //
  // --------------------------------------------------------------------------

  String _id;
  int _zIndex;
  Matrix _matrix;
  num _alpha;
  String _maskID;
  CFilter _filter;

  static num tx, ty;

  // --------------------------------------------------------------------------
  //
  // CONSTRUCTOR
  //
  // --------------------------------------------------------------------------

  CAnimationFrameInstance(String id) {
    _id = id;
  }

  // --------------------------------------------------------------------------
  //
  // PUBLIC METHODS
  //
  // --------------------------------------------------------------------------

  CAnimationFrameInstance clone() {
    CAnimationFrameInstance result = new CAnimationFrameInstance(this._id);
    CFilter filterCopy = _filter != null ? _filter.clone() : null;
    result.update(_zIndex, _matrix.clone(), _alpha, _maskID, filterCopy);
    return result;
  }

  void update(int zIndex, Matrix matrix, num alpha, String maskID, CFilter filter) {
    _zIndex = zIndex;
    _matrix = matrix;
    _alpha = alpha;
    _maskID = maskID;
    _filter = filter;
  }

  Matrix getTransformMatrix(Matrix pivotMatrix, num scale) {
    Matrix result = pivotMatrix.clone();
    tx = _matrix.tx;
    ty = _matrix.ty;
    _matrix.tx *= scale;
    _matrix.ty *= scale;
    result.concat(this._matrix);
    _matrix.tx = tx;
    _matrix.ty = ty;
    return result;
  }

  void applyTransformMatrix(Matrix transformationMatrix, Matrix pivotMatrix, num scale) {
    transformationMatrix.copyFrom(pivotMatrix);
    tx = _matrix.tx;
    ty = _matrix.ty;
    _matrix.tx *= scale;
    _matrix.ty *= scale;
    transformationMatrix.concat(_matrix);
    _matrix.tx = tx;
    _matrix.ty = ty;
  }

  Matrix calculateTransformMatrix(Matrix transformationMatrix, Matrix pivotMatrix, num scale) {
    applyTransformMatrix(transformationMatrix, pivotMatrix, scale);
    return transformationMatrix;
  }

  // --------------------------------------------------------------------------
  //
  // PRIVATE METHODS
  //
  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  //
  // EVENT HANDLERS
  //
  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  //
  // GETTERS AND SETTERS
  //
  // --------------------------------------------------------------------------

  String get id  => _id;

  Matrix get matrix => _matrix;

  num get alpha => _alpha;

  String get maskID => _maskID;

  CFilter get filter => _filter;

  int get zIndex  => _zIndex;

}
