part of stagexl_gaf;


class CColorMatrixFilterData implements CFilterData {

  List<num> matrix = new List<num>(20);

  CFilterData clone() {

    CColorMatrixFilterData copy = new CColorMatrixFilterData();
    VectorUtility.copyMatrix(copy.matrix, this.matrix);

    return copy;
  }
}
