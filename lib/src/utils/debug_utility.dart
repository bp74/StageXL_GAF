part of stagexl_gaf.utils;
/*
class DebugUtility {

	static bool RENDERING_DEBUG = false;

	static final int RENDERING_NEUTRAL_COLOR = 0xCCCCCCCC;
	static final int RENDERING_FILTER_COLOR = 0xFF00FFFF;
	static final int RENDERING_MASK_COLOR = 0xFFFF0000;
	static final int RENDERING_ALPHA_COLOR = 0xFFFFFF00;

	static final List<int> cHR = <int>[255, 255, 0, 0, 0, 255, 255];
	static final List<int> cHG = <int>[0, 255, 255, 255, 0, 0, 0];
	static final List<int> cHB = <int>[0, 0, 0, 255, 255, 255, 0];
  static final List<List<int>> aryRGB = [cHR, cHG, cHB];

  static List<int> getRenderingDifficultyColor(CAnimationFrameInstance instance,[bool alphaLess1=false, bool masked=false, bool hasFilter=false])
		{
			List<int> colors = new <int>[];
			if (instance.maskID || masked)
			{
				colors.add(RENDERING_MASK_COLOR);
			}
			if (instance.filter || hasFilter)
			{
				colors.add(RENDERING_FILTER_COLOR);
			}
			if (instance.alpha < GAF.maxAlpha || alphaLess1)
			{
				colors.add(RENDERING_ALPHA_COLOR);
			}
			if (colors.length == 0)
			{
				colors.add(RENDERING_NEUTRAL_COLOR);
			}

			return colors;
		}

		/**
		 * Returns color that objects would be painted
		 * @param difficulty value from 0 to 255
		 * @return color in ARGB format (from green to red)
		 */
		 static  int getColor(int difficulty)
		{
			if (difficulty > 255)
			{
				difficulty = 255;
			}

			List<int> colorArr = getRGB(120 - 120 / (255 / difficulty));

			int color = (((difficulty >> 1) + 0x7F) << 24) | colorArr[0] << 16 | colorArr[1] << 8;

			return color;
		}

		// return RGB color from hue circle rotation
		// [0]=R, [1]=G, [2]=B
		 static  List<int> getRGB(int rot)
		{
			List<int> retVal = new <int>[];
			int aryNum;
			// 0 ~ 360
			while (rot < 0 || rot > 360)
			{
				rot += (rot < 0) ? 360 : -360;
			}
			aryNum = (rot / 60).floor();
			// get color
			retVal = getH(rot, aryNum);
			return retVal;
		}

		// rotation　=> hue
		 static  List<int> getH(int rot,int aryNum)
		{
			List<int> retVal = new <int>[0, 0, 0];
			int nextNum = aryNum + 1;
			for (int i = 0; i < 3; i++)
			{
				retVal[i] = getHP(aryRGB[i], rot, aryNum, nextNum);
			}
			return retVal;
		}

		 static  int getHP(List<int> _P,int rot,int aryNum,int nextNum)
		{
			int retVal;
			int aryC;
			int nextC;
			int rH;
			num rotR;
			aryC = _P[aryNum];
			nextC = _P[nextNum];
			rotR = (aryC + nextC) / 60 * (rot - 60 * aryNum);
			rH = (_P[nextNum] == 0) ? aryC - rotR : aryC + rotR;
			retVal = (/*Math.*/min(255, (rH))).round().abs();
			return retVal;
		}

		 static  String getObjectMemoryHash(dynamic obj)
		{
			String memoryHash;

			try
			{
				FakeType(obj);
			}
			catch (e)
			{
				memoryHash = String(e).replace(/.*([@|\$].*?) to .*$/gi, '$1');
			}

			return memoryHash;
		}
	}
}

*/
