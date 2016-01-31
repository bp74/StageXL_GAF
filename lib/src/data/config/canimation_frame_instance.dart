part of stagexl_gaf;

class CAnimationFrameInstance {

  static final Matrix _tmpMatrix = new Matrix.fromIdentity();

  final String id;

  Matrix _matrix = new Matrix.fromIdentity();
  String _maskID = null;
  CFilter _filter = null;
  int _zIndex = 0;
  num _alpha = 0.0;

  CAnimationFrameInstance(this.id);

  //---------------------------------------------------------------------------

  Matrix get matrix => _matrix;
  String get maskID => _maskID;
  CFilter get filter => _filter;
  int get zIndex  => _zIndex;
  num get alpha => _alpha;

  //---------------------------------------------------------------------------

  CAnimationFrameInstance clone() {
    var result = new CAnimationFrameInstance(this.id);
    result.update(_zIndex, _matrix, _alpha, _maskID, _filter?.clone());
    return result;
  }

  void update(int zIndex, Matrix matrix, num alpha, String maskID, CFilter filter) {
    _matrix.copyFrom(matrix);
    _zIndex = zIndex;
    _alpha = alpha;
    _maskID = maskID;
    _filter = filter;
  }

  Matrix getTransformMatrix(Matrix pivotMatrix, num scale) {
    _tmpMatrix.copyFrom(_matrix);
    _tmpMatrix.tx *= scale;
    _tmpMatrix.ty *= scale;
    Matrix result = pivotMatrix.clone();
    result.concat(_tmpMatrix);
    return result;
  }

  void applyTransformMatrix(Matrix transformationMatrix, Matrix pivotMatrix, num scale) {
    _tmpMatrix.copyFrom(_matrix);
    _tmpMatrix.tx *= scale;
    _tmpMatrix.ty *= scale;
    transformationMatrix.copyFromAndConcat(pivotMatrix, _tmpMatrix);
  }

  Matrix calculateTransformMatrix(Matrix transformationMatrix, Matrix pivotMatrix, num scale) {
    applyTransformMatrix(transformationMatrix, pivotMatrix, scale);
    return transformationMatrix;
  }

}
