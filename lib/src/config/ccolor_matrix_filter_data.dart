part of stagexl_gaf;

class CColorMatrixFilterData implements CFilterData {

  final List<num> matrix = new List<num>.filled(20, 0.0, growable: false);

  CColorMatrixFilterData() {
    matrix[00] = 1.0; // R scale
    matrix[06] = 1.0; // G scale
    matrix[12] = 1.0; // B scale
    matrix[18] = 1.0; // A scale
  }

  //---------------------------------------------------------------------------

  CFilterData clone() {
    var filterData = new CColorMatrixFilterData();
    filterData.matrix.setAll(0, matrix);
    return filterData;
  }

}
