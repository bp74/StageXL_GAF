part of stagexl_gaf;

class CAnimationFrameInstance {

  final int id;
  final Matrix matrix;
  final int maskID;
  final CFilter filter;
  final int zIndex;
  final num alpha;

  CAnimationFrameInstance(
      this.id, this.zIndex, this.alpha, this.maskID, this.matrix, this.filter);

  //---------------------------------------------------------------------------

  Matrix getTransformMatrix(Matrix pivotMatrix, num scale) {
    var matrix = this.matrix.clone();
    matrix.scale(scale, scale);
    matrix.prepend(pivotMatrix);
    return matrix;
  }
}
