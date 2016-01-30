part of stagexl_gaf;

class GAFFilter extends BitmapFilter {

  // looks like a combined color matrix filter and blur filter.
  // TODO: Implement the GAFFilter or replace it with native filters.

  @override
  GAFFilter clone() => new GAFFilter();
}


/*
class GAFFilter extends FragmentFilter {

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

		 static final String NORMAL_PROGRAM_NAME = "BF_n";
		 static final String TINTED_PROGRAM_NAME = "BF_t";
		 static final String COLOR_TRANSFORM_PROGRAM_NAME = "CMF";
		 const num MAX_SIGMA = 2.0;
		 static final List<num> IDENTITY = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
		 static final List<num> MIN_COLOR = [0, 0, 0, 0.0001];

		 Program3D mNormalProgram;
		 Program3D mTintedProgram;
		 List<num> cUserMatrix = new List<num>(20, true);
		 List<num> cShaderMatrix = new List<num>(20, true);
		 Program3D cShaderProgram;

		 List<num> mOffsets = [0, 0, 0, 0];
		 List<num> mWeights = [0, 0, 0, 0];
		 List<num> mColor = [1, 1, 1, 1];

		 num mBlurX = 0;
		 num mBlurY = 0;
		 bool mUniformColor;

		 bool changeColor;

		/** helper object */
		 static List<num> sTmpWeights = new List<num>(5, true);

		 num _currentScale = 1;
		 num mResolution = 1;
	 GAFFilter([num resolution=1]): super(1, resolution) 
		{

			this.mode = "test";
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		  void setConfig(CFilter cFilter,num scale)
		{
			_currentScale = scale;
			updateFilters(cFilter);
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		  void updateFilters(CFilter cFilter)
		{
			int i;
			int l = cFilter.filterConfigs.length;
			ICFilterData filterConfig;

			bool blurUpdated;
			bool ctmUpdated;

			mUniformColor = false;

			for (i = 0; i < l; i++)
			{
				filterConfig = cFilter.filterConfigs[i];

				if (filterConfig is CBlurFilterData)
				{
					updateBlurFilter(filterConfig as CBlurFilterData);
					blurUpdated = true;
				}
				else if (filterConfig is CColorMatrixFilterData)
				{
					updateColorMatrixFilter(filterConfig as CColorMatrixFilterData);
					ctmUpdated = true;
				}
			}

			if( blurUpdated == null)
			{
				resetBlurFilter();
			}

			if( ctmUpdated == null)
			{
				resetColorMatrixFilter();
			}

			updateMarginsAndPasses();
		}

		  void resetBlurFilter()
		{
			mOffsets[0] = mOffsets[1] = mOffsets[2] = mOffsets[3] = 0;
			mWeights[0] = mWeights[1] = mWeights[2] = mWeights[3] = 0;
			mColor[0] = mColor[1] = mColor[2] = mColor[3] = 1;
			mBlurX = 0;
			mBlurY = 0;
			mResolution = 1;
		}

		  void resetColorMatrixFilter()
		{
			Listtility.copyMatrix(cUserMatrix, IDENTITY);
			Listtility.copyMatrix(cShaderMatrix, IDENTITY);
			changeColor = false;
		}

		  void updateMarginsAndPasses()
		{
			if (mBlurX == 0 && mBlurY == 0)
			{
				mBlurX = 0.001;
			}

			numPasses = (mBlurX) + ceil(mBlurY).ceil();
			marginX = (3 + (mBlurX)) / resolution + (offsetX).ceil().abs();
			marginY = (3 + (mBlurY)) / resolution + (offsetY).ceil().abs();

			if ((mBlurX > 0 || mBlurY > 0) && changeColor)
			{
				numPasses++;
			}
		}

		  void updateBlurFilter(CBlurFilterData cBlurFilterData)
		{
			mBlurX = cBlurFilterData.blurX * _currentScale;
			mBlurY = cBlurFilterData.blurY * _currentScale;

			num maxBlur = /*Math.*/max(mBlurX, mBlurY);
			//resolution = 1 / Math.sqrt(maxBlur * 0.1);
			if (maxBlur <= 10)
			{
				resolution = 1 + (10 - maxBlur) * 0.1;
			}
			else
			{
				resolution = 1 - maxBlur * 0.01;
			}

			num angleInRadians =  cBlurFilterData.angle * PI / 180;
			offsetX = /*Math.*/cos(angleInRadians) * cBlurFilterData.distance * _currentScale;
			offsetY = /*Math.*/sin(angleInRadians) * cBlurFilterData.distance * _currentScale;

			setUniformColor((cBlurFilterData.color > -1), cBlurFilterData.color, cBlurFilterData.alpha * cBlurFilterData.strength);
		}

		/** A uniform color will replace the RGB values of the input color, while the alpha
		 *  value will be multiplied with the given factor. Pass <code>false</code> as the
		 *  first parameter to deactivate the uniform color. */
		  void setUniformColor(bool enable,[int color=0x0, num alpha=1.0])
		{
			mColor[0] = Color.getRed(color) / 255.0;
			mColor[1] = Color.getGreen(color) / 255.0;
			mColor[2] = Color.getBlue(color) / 255.0;
			mColor[3] = alpha;
			mUniformColor = enable;
		}

		  void updateColorMatrixFilter(CColorMatrixFilterData cColorMatrixFilterData)
		{
			List<num> value = cColorMatrixFilterData.matrix;

			changeColor = false;

			if (value != null && value.length != 20)
			{
				throw new ArgumentError("Invalid matrix length: must be 20");
			}

			if (value == null)
			{
				Listtility.copyMatrix(cUserMatrix, IDENTITY);
			}
			else
			{
				changeColor = true;
				Listtility.copyMatrix(cUserMatrix, value);
			}

			updateShaderMatrix();
		}

		  void updateShaderMatrix()
		{
			// the shader needs the matrix components in a different order,
			// and it needs the offsets in the range 0-1.

			Listtility.fillMatrix(cShaderMatrix, cUserMatrix[0], cUserMatrix[1], cUserMatrix[2], cUserMatrix[3],
					cUserMatrix[5], cUserMatrix[6], cUserMatrix[7], cUserMatrix[8],
					cUserMatrix[10], cUserMatrix[11], cUserMatrix[12], cUserMatrix[13],
					cUserMatrix[15], cUserMatrix[16], cUserMatrix[17], cUserMatrix[18],
					cUserMatrix[4], cUserMatrix[9], cUserMatrix[14],
					cUserMatrix[19]);
		}

		/** @ */
		 @override 
		 void activate(int pass,Context3D context,Texture texture)
		{
			if (pass == numPasses - 1 && changeColor) //color transform filter
			{
				if (mode != FragmentFilterMode.REPLACE)
				{
					mode = FragmentFilterMode.REPLACE;
				}
				context.setProgramConstantsFromListContext3DProgramType.FRAGMENT, 0, cShaderMatrix);
				context.setProgramConstantsFromListContext3DProgramType.FRAGMENT, 5, MIN_COLOR);
				context.setProgram(cShaderProgram);
			}
			else //blur, drop shadow or glow
			{
				if( mUniformColor != null)
				{
					mode = FragmentFilterMode.BELOW;
				}
				else
				{
					mode = FragmentFilterMode.REPLACE;
				}
				updateParameters(pass, texture.nativeWidth, texture.nativeHeight);

				context.setProgramConstantsFromListContext3DProgramType.VERTEX, 4, mOffsets);
				context.setProgramConstantsFromListContext3DProgramType.FRAGMENT, 0, mWeights);

				if( changeColor != null)
				{
					if (pass == numPasses - 2 && mUniformColor)
					{
						context.setProgramConstantsFromListContext3DProgramType.FRAGMENT, 1, mColor);
						context.setProgram(mTintedProgram);
					}
					else
					{
						context.setProgram(mNormalProgram);
					}
				}
				if (pass == numPasses - 1 && mUniformColor)
				{
					context.setProgramConstantsFromListContext3DProgramType.FRAGMENT, 1, mColor);
					context.setProgram(mTintedProgram);
				}
				else
				{
					context.setProgram(mNormalProgram);
				}
			}
		}

		@override 
		  void render(DisplayObject object,RenderSupport support,num parentAlpha)
		{
			super.render(object, support, parentAlpha);
		}

		/** @ */
		 @override 
		 void createPrograms()
		{
			mNormalProgram = createProgram(false);
			mTintedProgram = createProgram(true);
			cShaderProgram = createCProgram();
		}

		  Program3D createProgram(bool tinted)
		{
			String programName = tinted ? TINTED_PROGRAM_NAME : NORMAL_PROGRAM_NAME;
			Starling target = Starling.current;

			if (target.hasProgram(programName))
			{
				return target.getProgram(programName);
			}

			// vc0-3 - mvp matrix
			// vc4   - kernel offset
			// va0   - position
			// va1   - texture coords

			String vertexProgramCode =
					"m44 op, va0, vc0       \n" + // 4x4 matrix transform to output space
					"mov v0, va1            \n" + // pos:  0 |
					"sub v1, va1, vc4.zwxx  \n" + // pos: -2 |
					"sub v2, va1, vc4.xyxx  \n" + // pos: -1 | --> kernel positions
					"add v3, va1, vc4.xyxx  \n" + // pos: +1 |     (only 1st two parts are relevant)
					"add v4, va1, vc4.zwxx  \n";  // pos: +2 |

			// v0-v4 - kernel position
			// fs0   - input texture
			// fc0   - weight data
			// fc1   - color (optional)
			// ft0-4 - pixel color from texture
			// ft5   - output color

			String fragmentProgramCode =
					"tex ft0,  v0, fs0 <2d, clamp, linear, mipnone> \n" +  // read center pixel
					"mul ft5, ft0, fc0.xxxx                         \n" +  // multiply with center weight

					"tex ft1,  v1, fs0 <2d, clamp, linear, mipnone> \n" +  // read pixel -2
					"mul ft1, ft1, fc0.zzzz                         \n" +  // multiply with weight
					"add ft5, ft5, ft1                              \n" +  // add to output color

					"tex ft2,  v2, fs0 <2d, clamp, linear, mipnone> \n" +  // read pixel -1
					"mul ft2, ft2, fc0.yyyy                         \n" +  // multiply with weight
					"add ft5, ft5, ft2                              \n" +  // add to output color

					"tex ft3,  v3, fs0 <2d, clamp, linear, mipnone> \n" +  // read pixel +1
					"mul ft3, ft3, fc0.yyyy                         \n" +  // multiply with weight
					"add ft5, ft5, ft3                              \n" +  // add to output color

					"tex ft4,  v4, fs0 <2d, clamp, linear, mipnone> \n" +  // read pixel +2
					"mul ft4, ft4, fc0.zzzz                         \n";   // multiply with weight

			if( tinted != null)
			{
				fragmentProgramCode +=
						"add ft5, ft5, ft4                          \n" + // add to output color
						"mul ft5.xyz, fc1.xyz, ft5.www              \n" + // set rgb with correct alpha
						"mul oc, ft5, fc1.wwww                      \n";  // multiply alpha
			}

			else
			{
				fragmentProgramCode +=
						"add  oc, ft5, ft4                          \n";  // add to output color
			}

			return target.registerProgramFromSource(programName, vertexProgramCode, fragmentProgramCode);
		}

		  Program3D createCProgram()
		{
			String programName = COLOR_TRANSFORM_PROGRAM_NAME;
			Starling target = Starling.current;

			if (target.hasProgram(programName))
			{
				return target.getProgram(programName);
			}

			// fc0-3: matrix
			// fc4:   offset
			// fc5:   minimal allowed color value

			String fragmentProgramCode =
					"tex ft0, v0,  fs0 <2d, clamp, linear, mipnone>  \n" + // read texture color
					"max ft0, ft0, fc5              \n" + // avoid division through zero in next step
					"div ft0.xyz, ft0.xyz, ft0.www  \n" + // restore original (non-PMA) RGB values
					"m44 ft0, ft0, fc0              \n" + // multiply color with 4x4 matrix
					"add ft0, ft0, fc4              \n" + // add offset
					"mul ft0.xyz, ft0.xyz, ft0.www  \n" + // multiply with alpha again (PMA)
					"mov oc, ft0                    \n";  // copy to output

			return target.registerProgramFromSource(programName, STD_VERTEX_SHADER, fragmentProgramCode);
		}

		  void updateParameters(int pass,int textureWidth,int textureHeight)
		{
			// algorithm described here:
			// http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
			//
			// To run in constrained mode, we can only make 5 texture lookups in the fragment
			// shader. By making use of linear texture sampling, we can produce similar output
			// to what would be 9 lookups.

			num sigma;
			bool horizontal = pass < mBlurX;
			num pixelSize;

			if( horizontal != null)
			{
				sigma = /*Math.*/min(1.0, mBlurX - pass) * MAX_SIGMA;
				pixelSize = 1.0 / textureWidth;
			}
			else
			{
				sigma = /*Math.*/min(1.0, mBlurY - (pass - (mBlurX))).ceil() * MAX_SIGMA;
				pixelSize = 1.0 / textureHeight;
			}

			final num twoSigmaSq = 2 * sigma * sigma;
			final num multiplier = 1.0 / sqrt(twoSigmaSq * PI);

			// get weights on the exact pixels (and as sTmpWeights) calculate sums (mWeights)
			for (int i = 0; i < 5; ++i)
			{
				sTmpWeights[i] = multiplier * exp(-i * i / twoSigmaSq);
			}

			mWeights[0] = sTmpWeights[0];
			mWeights[1] = sTmpWeights[1] + sTmpWeights[2];
			mWeights[2] = sTmpWeights[3] + sTmpWeights[4];

			// normalize weights so that sum equals "1.0"

			num weightSum = mWeights[0] + 2 * mWeights[1] + 2 * mWeights[2];
			num invWeightSum = 1.0 / weightSum;

			mWeights[0] *= invWeightSum;
			mWeights[1] *= invWeightSum;
			mWeights[2] *= invWeightSum;

			// calculate intermediate offsets

			num offset1 = (  pixelSize * sTmpWeights[1] + 2 * pixelSize * sTmpWeights[2]) / mWeights[1];
			num offset2 = (3 * pixelSize * sTmpWeights[3] + 4 * pixelSize * sTmpWeights[4]) / mWeights[2];

			// depending on pass, we move in x- or y-direction

			if( horizontal != null)
			{
				mOffsets[0] = offset1;
				mOffsets[1] = 0;
				mOffsets[2] = offset2;
				mOffsets[3] = 0;
			}
			else
			{
				mOffsets[0] = 0;
				mOffsets[1] = offset1;
				mOffsets[2] = 0;
				mOffsets[3] = offset2;
			}
		}

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

 }
*/
