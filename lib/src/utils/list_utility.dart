part of stagexl_gaf.utils;

/**
	 * @
	 */
class ListUtility {

  //[Inline]
  static void fillMatrix(
      List<num> v,
      num a00,
      num a01,
      num a02,
      num a03,
      num a04,
      num a10,
      num a11,
      num a12,
      num a13,
      num a14,
      a20,
      num a21,
      num a22,
      num a23,
      num a24,
      a30,
      num a31,
      num a32,
      num a33,
      num a34) {
    v[0] = a00;
    v[1] = a01;
    v[2] = a02;
    v[3] = a03;
    v[4] = a04;
    v[5] = a10;
    v[6] = a11;
    v[7] = a12;
    v[8] = a13;
    v[9] = a14;
    v[10] = a20;
    v[11] = a21;
    v[12] = a22;
    v[13] = a23;
    v[14] = a24;
    v[15] = a30;
    v[16] = a31;
    v[17] = a32;
    v[18] = a33;
    v[19] = a34;
  }

  //[Inline]
  static void copyMatrix(List<num> source, List<num> dest) {
    int l = dest.length;
    for (int i = 0; i < l; i++) {
      source[i] = dest[i];
    }
  }
}
