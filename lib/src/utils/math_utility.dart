part of stagexl_gaf.utils;

class MathUtility {

	static final num epsilon = 0.00001;
  static final num PI_Q = math.PI / 4.0;

	static bool equals(num a, num b) {
    if (a is! num || b is! num) return false;
  	return (a - b).abs() < epsilon;
	}

	static int getItemIndex(List<num> source, num target) {
    for (int i = 0; i < source.length; i++) {
      if (equals(source[i], target)) return i;
  	}
		return -1;
	}

}
