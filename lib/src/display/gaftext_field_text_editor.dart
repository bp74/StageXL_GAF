/**
 * Created by Nazar on 11.03.2015.
 */
 part of stagexl_gaf;

class GAFTextFieldTextEditor extends Sprite {
	// TODO: Implement or replace GAFTextFieldTextEditor
}

/*
	/** @ */
	 class GAFTextFieldTextEditor extends TextFieldTextEditor
	{
		/**
		 * @
		 */
		 static final Matrix HELPER_MATRIX = new Matrix();

		 List _filters;
		 num _scale;
		 num _csf;

		 Rectangle _snapshotClipRect;
	 GAFTextFieldTextEditor([num scale=1, num csf=1])
		{
			this._scale = scale;
			this._csf = csf;
			super();

			try // Feathers revision before bca9b93
			{
				this._snapshotClipRect = this["_textFieldClipRect"];
			}
			catch (error: Error)
			{
				this._snapshotClipRect = this["_textFieldSnapshotClipRect"];
			}
		}

		/** @ */
		  void setFilterConfig(CFilter value,[num scale=1])
		{
			List filters = [];
			if( value != null || value == true)
			{
				for (ICFilterData filter in value.filterConfigs)
				{
					filters.add(FiltersUtility.getNativeFilter(filter, scale * this._csf));
				}
			}

			if (this.textField)
			{
				this.textField.filters = filters;
			}
			else
			{
				this._filters = filters;
			}
		}

		/** @ */
		@override 
		  void initialize()
		{
			super.initialize();

			if (this._filters)
			{
				this.textField.filters = this._filters;
				this._filters = null;
			}
		}

		/**
		 * @
		 */
		@override 
		  void refreshSnapshotParameters()
		{
			this._textFieldOffsetX = 0;
			this._textFieldOffsetY = 0;
			this._snapshotClipRect.x = 0;
			this._snapshotClipRect.y = 0;

			num clipWidth = this.actualWidth * this._scale * this._csf;
			if (clipWidth < 0)
			{
				clipWidth = 0;
			}
			num clipHeight = this.actualHeight * this._scale * this._csf;
			if (clipHeight < 0)
			{
				clipHeight = 0;
			}
			this._snapshotClipRect.width = clipWidth;
			this._snapshotClipRect.height = clipHeight;

			this._snapshotClipRect.copyFrom(DisplayUtility.getBoundsWithFilters(this._snapshotClipRect, this.textField.filters));
			this._textFieldOffsetX = this._snapshotClipRect.x;
			this._textFieldOffsetY = this._snapshotClipRect.y;
			this._snapshotClipRect.x = 0;
			this._snapshotClipRect.y = 0;
		}

		/**
		 * @
		 */
		@override 
		  void positionSnapshot()
		{
			if (!this.textSnapshot)
			{
				return;
			}

			this.textSnapshot.x = this._textFieldOffsetX / this._scale / this._csf;
			this.textSnapshot.y = this._textFieldOffsetY / this._scale / this._csf;
		}

		/**
		 * @
		 */
		@override 
		  void checkIfNewSnapshotIsNeeded()
		{
			bool canUseRectangleTexture = Starling.current.profile != Context3DProfile.BASELINE_CONSTRAINED;
			if( canUseRectangleTexture != null || canUseRectangleTexture == true)
			{
				this._snapshotWidth = this._snapshotClipRect.width;
				this._snapshotHeight = this._snapshotClipRect.height;
			}
			else
			{
				this._snapshotWidth = getNextPowerOfTwo(this._snapshotClipRect.width);
				this._snapshotHeight = getNextPowerOfTwo(this._snapshotClipRect.height);
			}
			ConcreteTexture textureRoot = this.textSnapshot ? this.textSnapshot.texture.root : null;
			this._needsNewTexture = this._needsNewTexture || !this.textSnapshot ||
					textureRoot.scale != this._scale * this._csf ||
					this._snapshotWidth != textureRoot.width || this._snapshotHeight != textureRoot.height;
		}

		/**
		 * @
		 */
		@override 
		  void texture_onRestore()
		{
			if (this.textSnapshot && this.textSnapshot.texture &&
					this.textSnapshot.texture.scale != this._scale * this._csf)
			{
				//if we've changed between scale factors, we need to recreate
				//the texture to match the new scale factor.
				this.invalidate(INVALIDATION_FLAG_SIZE);
			}
			else
			{
				this.refreshSnapshot();
			}
		}

		/**
		 * @
		 */
		@override 
		  void refreshSnapshot()
		{
			if (this._snapshotWidth <= 0 || this._snapshotHeight <= 0)
			{
				return;
			}

			num gutterPositionOffset = 2;
			if (this._useGutter)
			{
				gutterPositionOffset = 0;
			}

			num textureScaleFactor = this._scale * this._csf;

			HELPER_MATRIX.identity();
			HELPER_MATRIX.scale(textureScaleFactor, textureScaleFactor);

			HELPER_MATRIX.translate(-this._textFieldOffsetX - gutterPositionOffset, -this._textFieldOffsetY - gutterPositionOffset);

			BitmapData bitmapData = new BitmapData(this._snapshotWidth, this._snapshotHeight, true, 0x00ff00ff);
			bitmapData.draw(this.textField, HELPER_MATRIX, null, null, this._snapshotClipRect);
			Texture newTexture;
			if (!this.textSnapshot || this._needsNewTexture)
			{
				//skip Texture.fromBitmapData() because we don't want
				//it to create an onRestore function that will be
				//immediately discarded for garbage collection.
				newTexture = Texture.empty(bitmapData.width / textureScaleFactor, bitmapData.height / textureScaleFactor,
						true, false, false, textureScaleFactor);
				newTexture.root.uploadBitmapData(bitmapData);
				newTexture.root.onRestore = texture_onRestore;
			}

			if (!this.textSnapshot)
			{
				this.textSnapshot = new Image(newTexture);
				this.addChild(this.textSnapshot);
			}
			else
			{
				if (this._needsNewTexture)
				{
					this.textSnapshot.texture.dispose();
					this.textSnapshot.texture = newTexture;
					this.textSnapshot.readjustSize();
				}
				else
				{
					//this is faster, if we haven't resized the bitmapdata
					Texture existingTexture = this.textSnapshot.texture;
					existingTexture.root.uploadBitmapData(bitmapData);
				}
			}

			this.textSnapshot.alpha = this._text.length > 0 ? 1 : 0;
			bitmapData.dispose();
			this._needsNewTexture = false;
		}
	}
*/
