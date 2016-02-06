part of stagexl_gaf;

class CAnimationFrameInstance {

  final String id;
  final Matrix matrix;
  final String maskID;
  final CFilter filter;
  final int zIndex;
  final num alpha;

  CAnimationFrameInstance(
      this.id, this.zIndex, this.alpha, this.maskID, this.matrix, this.filter);

  //---------------------------------------------------------------------------

  CAnimationFrameInstance clone() => new CAnimationFrameInstance(
      this.id, this.zIndex, this.alpha, this.maskID,
      this.matrix?.clone(), this.filter?.clone());

  Matrix getTransformMatrix(Matrix pivotMatrix, num scale) {
    var matrix = this.matrix.clone();
    matrix.scale(scale, scale);
    matrix.prepend(pivotMatrix);
    return matrix;
  }
}
