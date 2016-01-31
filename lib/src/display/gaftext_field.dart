part of stagexl_gaf;

class GAFTextField extends Sprite {
	// TODO: Implement or replace GAFTextField

  GAFTextField(CTextFieldObject config,[num scale=1, num csf=1]): super() {

  }
}

/*
	/**
	 * @
	 */
	 class GAFTextField extends TextInput implements IGAFDebug, IMaxSize, IGAFDisplayObject
	{
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

		 static final Matrix HELPER_MATRIX = new Matrix();

		 Matrix _pivotMatrix;

		 CFilter _filterConfig;
		 num _filterScale;

		 Point _maxSize;

		 bool _pivotChanged;
		 num _scale;
		 num _csf;

		num __debugOriginalAlpha = NaN;

		 bool _orientationChanged;

		 CTextFieldObject _config;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------

		/**
		 * GAFTextField represents text field that is part of the <code>GAFMovieClip</code>
		 * @param config
		 */
	 GAFTextField(CTextFieldObject config,[num scale=1, num csf=1]): super() 
		{

			if (isNaN(scale as scale)) = 1;
			if (isNaN(csf as csf)) = 1;

			this._scale = scale;
			this._csf = csf;

			this._pivotMatrix = new Matrix();
			this._pivotMatrix.tx = config.pivotPoint.x;
			this._pivotMatrix.ty = config.pivotPoint.y;
			this._pivotMatrix.scale(scale, scale);

			if (!isNaN(config.width))
			{
				this.width = config.width;
			}

			if (!isNaN(config.height))
			{
				this.height = config.height;
			}

			this.text = config.text;
			this.restrict = config.restrict;
			this.isEditable = config.editable;
			this.isEnabled = this.isEditable || config.selectable; // editable text must be selectable anyway
			this.displayAsPassword = config.displayAsPassword;
			this.maxChars = config.maxChars;
			this.verticalAlign = TextInput.VERTICAL_ALIGN_TOP;

			this.textEditorProperties.textFormat = config.textFormat;
			this.textEditorProperties.embedFonts = GAF.useDeviceFonts ? false : config.embedFonts;
			this.textEditorProperties.multiline = config.multiline;
			this.textEditorProperties.wordWrap = config.wordWrap;
			this.textEditorFactory =  ITextEditor ()
			{
				return new GAFTextFieldTextEditor(_scale, _csf);
			};

			this.invalidateSize();

			this._config = config;
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		/**
		 * Creates a new instance of GAFTextField.
		 */
		  GAFTextField copy()
		{
			GAFTextField clone = new GAFTextField(this._config, this._scale, this._csf);
			clone.alpha = this.alpha;
			clone.visible = this.visible;
			clone.transformationMatrix = this.transformationMatrix;
			clone.textEditorFactory = this.textEditorFactory;
			clone.setFilterConfig(_filterConfig, _filterScale);

			return clone;
		}

		/**
		 * @
		 * We need to update the textField size after the textInput was transformed
		 */
		  void invalidateSize()
		{
			if (this.textEditor && this.textEditor is TextFieldTextEditor)
			{
				(this.textEditor as TextFieldTextEditor).invalidate(INVALIDATION_FLAG_SIZE);
			}
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}

		/** @ */
		  void invalidateOrientation()
		{
			this._orientationChanged = true;
		}

		/** @ */
		  void set debugColors(List<int> value)
		{
			Texture t = Texture.fromColor(1, 1, DebugUtility.RENDERING_NEUTRAL_COLOR, true);
			Image bgImage = new Image(t);
			num alpha0;
			num alpha1;

			switch (value.length)
			{
				case 1:
					bgImage.color = value[0];
					bgImage.alpha = (value[0] >>/*>*/ 24) / 255;
					break;
				case 2:
					bgImage.setVertexColor(0, value[0]);
					bgImage.setVertexColor(1, value[0]);
					bgImage.setVertexColor(2, value[1]);
					bgImage.setVertexColor(3, value[1]);

					alpha0 = (value[0] >>/*>*/ 24) / 255;
					alpha1 = (value[1] >>/*>*/ 24) / 255;
					bgImage.setVertexAlpha(0, alpha0);
					bgImage.setVertexAlpha(1, alpha0);
					bgImage.setVertexAlpha(2, alpha1);
					bgImage.setVertexAlpha(3, alpha1);
					break;
				case 3:
					bgImage.setVertexColor(0, value[0]);
					bgImage.setVertexColor(1, value[0]);
					bgImage.setVertexColor(2, value[1]);
					bgImage.setVertexColor(3, value[2]);

					alpha0 = (value[0] >>/*>*/ 24) / 255;
					bgImage.setVertexAlpha(0, alpha0);
					bgImage.setVertexAlpha(1, alpha0);
					bgImage.setVertexAlpha(2, (value[1] >>/*>*/ 24) / 255);
					bgImage.setVertexAlpha(3, (value[2] >>/*>*/ 24) / 255);
					break;
				case 4:
					bgImage.setVertexColor(0, value[0]);
					bgImage.setVertexColor(1, value[1]);
					bgImage.setVertexColor(2, value[2]);
					bgImage.setVertexColor(3, value[3]);

					bgImage.setVertexAlpha(0, (value[0] >>/*>*/ 24) / 255);
					bgImage.setVertexAlpha(1, (value[1] >>/*>*/ 24) / 255);
					bgImage.setVertexAlpha(2, (value[2] >>/*>*/ 24) / 255);
					bgImage.setVertexAlpha(3, (value[3] >>/*>*/ 24) / 255);
					break;
			}

			this.backgroundSkin = bgImage;
		}

		/** @ */
		  void setFilterConfig(CFilter value,[num scale=1])
		{
			if (this._filterConfig != value || this._filterScale != scale)
			{
				if( value != null || value == true)
				{
					this._filterConfig = value;
					this._filterScale = scale;
				}
				else
				{
					this._filterConfig = null;
					this._filterScale = NaN;
				}

				this.applyFilter();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		  void applyFilter()
		{
			if (this.textEditor)
			{
				if (this.textEditor is GAFTextFieldTextEditor)
				{
					(this.textEditor as GAFTextFieldTextEditor).setFilterConfig(this._filterConfig, this._filterScale);
				}
				else if (this._filterConfig && !isNaN(this._filterScale))
				{
					GAFFilter gafFilter;
					if (this.filter)
					{
						if (this.filter is GAFFilter)
						{
							gafFilter = this.filter as GAFFilter;
						}
						else
						{
							this.filter.dispose();
							gafFilter = new GAFFilter();
						}
					}
					else
					{
						gafFilter = new GAFFilter();
					}

					gafFilter.setConfig(this._filterConfig, this._filterScale);
					this.filter = gafFilter;
				}
				else if (this.filter)
				{
					this.filter.dispose();
					this.filter = null;
				}
			}
		}

		 void __debugHighlight()
		{
			// use namespace gaf_internal;
			if (isNaN(this.__debugOriginalAlpha))
			{
				this.__debugOriginalAlpha = this.alpha;
			}
			this.alpha = 1;
		}

		 void __debugLowlight()
		{
			// use namespace gaf_internal;
			if (isNaN(this.__debugOriginalAlpha))
			{
				this.__debugOriginalAlpha = this.alpha;
			}
			this.alpha = .05;
		}

		 void __debugResetLight()
		{
			// use namespace gaf_internal;
			if (!isNaN(this.__debugOriginalAlpha))
			{
				this.alpha = this.__debugOriginalAlpha;
				this.__debugOriginalAlpha = NaN;
			}
		}

		[Inline]
		 final  void updateTransformMatrix()
		{
			if (this._orientationChanged)
			{
				this.transformationMatrix = this.transformationMatrix;
				this._orientationChanged = false;
			}
		}

		//--------------------------------------------------------------------------
		//
		// OVERRIDDEN METHODS
		//
		//--------------------------------------------------------------------------

		@override 
		  void createTextEditor()
		{
			super.createTextEditor();

			this.applyFilter();
		}

		@override 
		  void dispose()
		{
			super.dispose();
			this._config = null;
		}

		@override 
		  void set transformationMatrix(Matrix matrix)
		{
			super.transformationMatrix = matrix;

			this.invalidateSize();
		}

		@override 
		  void set pivotX(num value)
		{
			this._pivotChanged = true;
			super.pivotX = value;
		}

		@override 
		  void set pivotY(num value)
		{
			this._pivotChanged = true;
			super.pivotY = value;
		}

		@override 
		  num get x
		{
			updateTransformMatrix();
			return super.x;
		}

		@override 
		  num get y
		{
			updateTransformMatrix();
			return super.y;
		}

		@override 
		  num get rotation
		{
			updateTransformMatrix();
			return super.rotation;
		}

		@override 
		  num get scaleX
		{
			updateTransformMatrix();
			return super.scaleX;
		}

		@override 
		  num get scaleY
		{
			updateTransformMatrix();
			return super.scaleY;
		}

		@override 
		  num get skewX
		{
			updateTransformMatrix();
			return super.skewX;
		}

		@override 
		  num get skewY
		{
			updateTransformMatrix();
			return super.skewY;
		}

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

		/** @ */
		  Matrix get pivotMatrix
		{
			HELPER_MATRIX.copyFrom(this._pivotMatrix);

			if (this._pivotChanged)
			{
				HELPER_MATRIX.tx = this.pivotX;
				HELPER_MATRIX.ty = this.pivotY;
			}

			return HELPER_MATRIX;
		}

		/** @ */
		  Point get maxSize
		{
			return this._maxSize;
		}

		/** @ */
		  void set maxSize(Point value)
		{
			this._maxSize = value;
		}

		//--------------------------------------------------------------------------
		//
		//  STATIC METHODS
		//
		//--------------------------------------------------------------------------
	}
*/
