/*
 Feathers
 Copyright 2012-2014 Joshua Tynjala. All Rights Reserved.

 This program is free software. You can redistribute and/or modify it in
 accordance with the terms of the accompanying license agreement.
 */
part of stagexl_gaf;

//AS3 removed

// use namespace gaf_internal;
/*
	[Exclude(name="numChildren",kind="property")]
	[Exclude(name="isFlattened",kind="property")]
	[Exclude(name="addChild",kind="method")]
	[Exclude(name="addChildAt",kind="method")]
	[Exclude(name="broadcastEvent",kind="method")]
	[Exclude(name="broadcastEventWith",kind="method")]
	[Exclude(name="contains",kind="method")]
	[Exclude(name="getChildAt",kind="method")]
	[Exclude(name="getChildByName",kind="method")]
	[Exclude(name="getChildIndex",kind="method")]
	[Exclude(name="removeChild",kind="method")]
	[Exclude(name="removeChildAt",kind="method")]
	[Exclude(name="removeChildren",kind="method")]
	[Exclude(name="setChildIndex",kind="method")]
	[Exclude(name="sortChildren",kind="method")]
	[Exclude(name="swapChildren",kind="method")]
	[Exclude(name="swapChildrenAt",kind="method")]
	[Exclude(name="flatten",kind="method")]
	[Exclude(name="unflatten",kind="method")]
*/
/**
	 * @
	 */

class GAFScale9Image extends Sprite {
  // TODO: Implement or replace GAFScale9Image

	GAFScale9Image(GAFScale9Texture textures, [num textureScale = 1]) : super() {

	}
}

/*
class GAFScale9Image extends Sprite
    implements IValidating, IGAFImage, IMaxSize, IGAFDebug {
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

  static final Matrix HELPER_MATRIX = new Matrix.fromIdentity();
  static final Point HELPER_POINT = new Point(0, 0);
  static Image sHelperImage;
  bool _propertiesChanged = true;
  bool _layoutChanged = true;
  bool _renderingChanged = true;
  Rectangle _frame;
  GAFScale9Texture _textures;
  num _width = NaN;
  num _height = NaN;
  num _textureScale = 1;
  String _smoothing = TextureSmoothing.BILINEAR;
  int _color = 0xffffff;
  bool _useSeparateBatch = true;
  Rectangle _hitArea;
  QuadBatch _batch;
  bool _isValidating = false;
  bool _isInvalid = false;
  ValidationQueue _validationQueue;
  int _depth = -1;

  List<int> _debugColors;
  List<num> _debugAlphas;

  CFilter _filterConfig;
  num _filterScale;

  Point _maxSize;

  bool _pivotChanged;

  num __debugOriginalAlpha = null;

  bool _orientationChanged;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  /**
		 * GAFScale9Image represents display object that is part of the <code>GAFMovieClip</code>
		 * Scales an image with nine regions to maintain the aspect ratio of the
		 * corners regions. The top and bottom regions stretch horizontally, and the
		 * left and right regions scale vertically. The center region stretches in
		 * both directions to fill the remaining space.
		 * @param textures  The textures displayed by this image.
		 * @param textureScale The amount to scale the texture. Useful for DPI changes.
		 * @see com.catalystapps.gaf.display.GAFImage
		 */
  GAFScale9Image(GAFScale9Texture textures, [num textureScale = 1]) : super() {
    this.textures = textures;
    this._textureScale = textureScale;
    this._hitArea = new Rectangle(0, 0, 0, 0);
    this.invalidateSize();

    this._batch = new QuadBatch();
    this._batch.touchable = false;
    this.addChild(this._batch);

    this.addEventListener(Event.FLATTEN, this.flattenHandler);
    this.addEventListener(Event.ADDED_TO_STAGE, this.addedToStageHandler);
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  /**
		 * Creates a new instance of GAFScale9Image.
		 */
  GAFScale9Image copy() {
    return new GAFScale9Image(this._textures, this._textureScale);
  }

  void set debugColors(List<int> value) {
    this._debugColors = new List<int>(4);
    this._debugAlphas = new List<num>(4);

    num alpha0;
    num alpha1;

    switch (value.length) {
      case 1:
        this._debugColors[0] = value[0];
        this._debugColors[1] = value[0];
        this._debugColors[2] = value[0];
        this._debugColors[3] = value[0];
        alpha0 = (value[0] >> /*>*/ 24) / 255;
        this._debugAlphas[0] = alpha0;
        this._debugAlphas[1] = alpha0;
        this._debugAlphas[2] = alpha0;
        this._debugAlphas[3] = alpha0;
        break;
      case 2:
        this._debugColors[0] = value[0];
        this._debugColors[1] = value[0];
        this._debugColors[2] = value[1];
        this._debugColors[3] = value[1];
        alpha0 = (value[0] >> /*>*/ 24) / 255;
        alpha1 = (value[1] >> /*>*/ 24) / 255;
        this._debugAlphas[0] = alpha0;
        this._debugAlphas[1] = alpha0;
        this._debugAlphas[2] = alpha1;
        this._debugAlphas[3] = alpha1;
        break;
      case 3:
        this._debugColors[0] = value[0];
        this._debugColors[1] = value[0];
        this._debugColors[2] = value[1];
        this._debugColors[3] = value[2];
        alpha0 = (value[0] >> /*>*/ 24) / 255;
        this._debugAlphas[0] = alpha0;
        this._debugAlphas[1] = alpha0;
        this._debugAlphas[2] = (value[1] >> /*>*/ 24) / 255;
        this._debugAlphas[3] = (value[2] >> /*>*/ 24) / 255;
        break;
      case 4:
        this._debugColors[0] = value[0];
        this._debugColors[1] = value[1];
        this._debugColors[2] = value[2];
        this._debugColors[3] = value[3];
        this._debugAlphas[0] = (value[0] >> /*>*/ 24) / 255;
        this._debugAlphas[1] = (value[1] >> /*>*/ 24) / 255;
        this._debugAlphas[2] = (value[2] >> /*>*/ 24) / 255;
        this._debugAlphas[3] = (value[3] >> /*>*/ 24) / 255;
        break;
    }
  }

  /**
		 * @copy feathers.core.IValidating#validate()
		 */
  void validate() {
    if (!this._isInvalid) {
      return;
    }
    if (this._isValidating) {
      if (this._validationQueue) {
        //we were already validating, and something else told us to
        //validate. that's bad.
        this._validationQueue.addControl(this, true);
      }
      return;
    }
    this._isValidating = true;
    if (this._propertiesChanged ||
        this._layoutChanged ||
        this._renderingChanged) {
      this._batch.batchable = !this._useSeparateBatch;
      this._batch.reset();

      if (sHelperImage == null) {
        //because Scale9Textures enforces it, we know for sure that
        //this texture will have a size greater than zero, so there
        //won't be an error from Quad.
        sHelperImage = new Image(this._textures.middleCenter);
      }
      //sHelperImage.smoothing = this._smoothing; //not supported in StageXL

      if (!setDebugVertexColors([0, 1, 2, 3])) {
        sHelperImage.color = this._color;
      }

      Rectangle grid = this._textures.scale9Grid;
      num scaledLeftWidth = grid.x * this._textureScale;
      num scaledRightWidth =
          (this._frame.width - grid.x - grid.width) * this._textureScale;
      num sumLeftAndRight = scaledLeftWidth + scaledRightWidth;
      num distortionScale;
      if (sumLeftAndRight > this._width) {
        distortionScale = (this._width / sumLeftAndRight);
        scaledLeftWidth *= distortionScale;
        scaledRightWidth *= distortionScale;
        sumLeftAndRight + scaledLeftWidth + scaledRightWidth;
      }
      num scaledCenterWidth = this._width - sumLeftAndRight;
      num scaledTopHeight = grid.y * this._textureScale;
      num scaledBottomHeight =
          (this._frame.height - grid.y - grid.height) * this._textureScale;
      num sumTopAndBottom = scaledTopHeight + scaledBottomHeight;
      if (sumTopAndBottom > this._height) {
        distortionScale = (this._height / sumTopAndBottom);
        scaledTopHeight *= distortionScale;
        scaledBottomHeight *= distortionScale;
        sumTopAndBottom = scaledTopHeight + scaledBottomHeight;
      }
      num scaledMiddleHeight = this._height - sumTopAndBottom;

      if (scaledTopHeight > 0) {
        if (scaledLeftWidth > 0) {
          this.setDebugColor(0);
          sHelperImage.texture = this._textures.topLeft;
          sHelperImage.readjustSize();
          sHelperImage.width = scaledLeftWidth;
          sHelperImage.height = scaledTopHeight;
          sHelperImage.x = scaledLeftWidth - sHelperImage.width;
          sHelperImage.y = scaledTopHeight - sHelperImage.height;
          this._batch.addImage(sHelperImage);
        }

        if (scaledCenterWidth > 0) {
          this.setDebugVertexColors([0, 1, 0, 1]);
          sHelperImage.texture = this._textures.topCenter;
          sHelperImage.readjustSize();
          sHelperImage.width = scaledCenterWidth;
          sHelperImage.height = scaledTopHeight;
          sHelperImage.x = scaledLeftWidth;
          sHelperImage.y = scaledTopHeight - sHelperImage.height;
          this._batch.addImage(sHelperImage);
        }

        if (scaledRightWidth > 0) {
          this.setDebugColor(1);
          sHelperImage.texture = this._textures.topRight;
          sHelperImage.readjustSize();
          sHelperImage.width = scaledRightWidth;
          sHelperImage.height = scaledTopHeight;
          sHelperImage.x = this._width - scaledRightWidth;
          sHelperImage.y = scaledTopHeight - sHelperImage.height;
          this._batch.addImage(sHelperImage);
        }
      }

      if (scaledMiddleHeight > 0) {
        if (scaledLeftWidth > 0) {
          this.setDebugVertexColors([0, 0, 2, 2]);
          sHelperImage.texture = this._textures.middleLeft;
          sHelperImage.readjustSize();
          sHelperImage.width = scaledLeftWidth;
          sHelperImage.height = scaledMiddleHeight;
          sHelperImage.x = scaledLeftWidth - sHelperImage.width;
          sHelperImage.y = scaledTopHeight;
          this._batch.addImage(sHelperImage);
        }

        if (scaledCenterWidth > 0) {
          this.setDebugVertexColors([0, 1, 2, 3]);
          sHelperImage.texture = this._textures.middleCenter;
          sHelperImage.readjustSize();
          sHelperImage.width = scaledCenterWidth;
          sHelperImage.height = scaledMiddleHeight;
          sHelperImage.x = scaledLeftWidth;
          sHelperImage.y = scaledTopHeight;
          this._batch.addImage(sHelperImage);
        }

        if (scaledRightWidth > 0) {
          this.setDebugVertexColors([1, 1, 3, 3]);
          sHelperImage.texture = this._textures.middleRight;
          sHelperImage.readjustSize();
          sHelperImage.width = scaledRightWidth;
          sHelperImage.height = scaledMiddleHeight;
          sHelperImage.x = this._width - scaledRightWidth;
          sHelperImage.y = scaledTopHeight;
          this._batch.addImage(sHelperImage);
        }
      }

      if (scaledBottomHeight > 0) {
        if (scaledLeftWidth > 0) {
          this.setDebugColor(2);
          sHelperImage.texture = this._textures.bottomLeft;
          sHelperImage.readjustSize();
          sHelperImage.width = scaledLeftWidth;
          sHelperImage.height = scaledBottomHeight;
          sHelperImage.x = scaledLeftWidth - sHelperImage.width;
          sHelperImage.y = this._height - scaledBottomHeight;
          this._batch.addImage(sHelperImage);
        }

        if (scaledCenterWidth > 0) {
          this.setDebugVertexColors([2, 3, 2, 3]);
          sHelperImage.texture = this._textures.bottomCenter;
          sHelperImage.readjustSize();
          sHelperImage.width = scaledCenterWidth;
          sHelperImage.height = scaledBottomHeight;
          sHelperImage.x = scaledLeftWidth;
          sHelperImage.y = this._height - scaledBottomHeight;
          this._batch.addImage(sHelperImage);
        }

        if (scaledRightWidth > 0) {
          this.setDebugColor(3);
          sHelperImage.texture = this._textures.bottomRight;
          sHelperImage.readjustSize();
          sHelperImage.width = scaledRightWidth;
          sHelperImage.height = scaledBottomHeight;
          sHelperImage.x = this._width - scaledRightWidth;
          sHelperImage.y = this._height - scaledBottomHeight;
          this._batch.addImage(sHelperImage);
        }
      }
    }

    this._propertiesChanged = false;
    this._layoutChanged = false;
    this._renderingChanged = false;
    this._isInvalid = false;
    this._isValidating = false;
  }

  /**
		 * Readjusts the dimensions of the image according to its current
		 * textures. Call this method to synchronize image and texture size
		 * after assigning textures with a different size.
		 */
  void readjustSize() {
    this.invalidateSize();
  }

  void invalidateSize() {
    Matrix mtx = this.transformationMatrix;
    num scaleX = sqrt(mtx.a * mtx.a + mtx.b * mtx.b);
    num scaleY = sqrt(mtx.c * mtx.c + mtx.d * mtx.d);

    if (scaleX < 0.99 || scaleX > 1.01 || scaleY < 0.99 || scaleY > 1.01) {
      this._width = this._frame.width * scaleX;
      this._height = this._frame.height * scaleY;

      HELPER_POINT.x = mtx.a;
      HELPER_POINT.y = mtx.b;
      HELPER_POINT.normalize(1);
      mtx.a = HELPER_POINT.x;
      mtx.b = HELPER_POINT.y;

      HELPER_POINT.x = mtx.c;
      HELPER_POINT.y = mtx.d;
      HELPER_POINT.normalize(1);
      mtx.c = HELPER_POINT.x;
      mtx.d = HELPER_POINT.y;
    } else {
      this._width = this._frame.width;
      this._height = this._frame.height;
    }

    this._layoutChanged = true;
    this.invalidate();
  }

  /** @ */
  void setFilterConfig(CFilter value, [num scale = 1]) {
    if (!Starling.current.contextValid) {
      return;
    }

    if (this._filterConfig != value || this._filterScale != scale) {
      if (value != null) {
        this._filterConfig = value;
        this._filterScale = scale;
        GAFFilter gafFilter;
        if (this._batch.filter) {
          if (this._batch.filter is GAFFilter) {
            gafFilter = this._batch.filter as GAFFilter;
          } else {
            this._batch.filter.dispose();
            gafFilter = new GAFFilter();
          }
        } else {
          gafFilter = new GAFFilter();
        }

        gafFilter.setConfig(this._filterConfig, this._filterScale);
        this._batch.filter = gafFilter;
      } else {
        if (this._batch.filter) {
          this._batch.filter.dispose();
          this._batch.filter = null;
        }
        this._filterConfig = null;
        this._filterScale = null;
      }
    }
  }

  /** @ */
  void invalidateOrientation() {
    this._orientationChanged = true;
    invalidateSize();
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  /**
		 * @
		 */
  void invalidate() {
    if (this._isInvalid) {
      return;
    }
    this._isInvalid = true;
    if (!this._validationQueue) {
      return;
    }
    this._validationQueue.addControl(this, false);
  }

  void setDebugColor(int idx) {
    if (this._debugColors != null) {
      sHelperImage.color = this._debugColors[idx];
      sHelperImage.alpha = this._debugAlphas[idx];
    }
  }

  bool setDebugVertexColors(List indexes) {
    if (this._debugColors != null) {
      int i;
      for (i = 0; i < indexes.length; i++) {
        sHelperImage.setVertexColor(i, this._debugColors[indexes[i]]);
        sHelperImage.setVertexAlpha(i, this._debugAlphas[indexes[i]]);
      }
    }
    return this._debugColors != null;
  }

  void __debugHighlight() {
    // use namespace gaf_internal;
    if ((this.__debugOriginalAlpha) == null) {
      this.__debugOriginalAlpha = this.alpha;
    }
    this.alpha = 1;
  }

  void __debugLowlight() {
    // use namespace gaf_internal;
    if ((this.__debugOriginalAlpha) == null) {
      this.__debugOriginalAlpha = this.alpha;
    }
    this.alpha = .05;
  }

  void __debugResetLight() {
    // use namespace gaf_internal;
    if ((this.__debugOriginalAlpha) != null) {
      this.alpha = this.__debugOriginalAlpha;
      this.__debugOriginalAlpha = null;
    }
  }

  //[Inline]
  void updateTransformMatrix() {
    if (this._orientationChanged) {
      this.transformationMatrix = this.transformationMatrix;
      this._orientationChanged = false;
    }
  }

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  /**
		 * @
		 */
  @override
  void set transformationMatrix(Matrix matrix) {
    super.transformationMatrix = matrix;
    this._layoutChanged = true;
    this.invalidate();
  }

  /**
		 * @
		 */
  @override
  Rectangle getBounds(DisplayObject targetSpace,
      [Rectangle resultRect = null]) {
    (resultRect != null) ? resultRect : resultRect = new Rectangle();

    if (targetSpace == this) // optimization
        {
      resultRect.copyFrom(this._hitArea);
    } else {
      num minX = double.MAX_FINITE, maxX = -double.MAX_FINITE;
      num minY = double.MAX_FINITE, maxY = -double.MAX_FINITE;

      this.getTransformationMatrix(targetSpace, HELPER_MATRIX);

      num coordsX;
      num coordsY;

      for (int i = 0; i < 4; i++) {
        coordsX = i < 2 ? this._hitArea.x : this._hitArea.right;
        coordsY = i % 2 < 1 ? this._hitArea.y : this._hitArea.bottom;
        MatrixUtil.transformCoords(
            HELPER_MATRIX, coordsX, coordsY, HELPER_POINT);
        minX = /*Math.*/ min(minX, HELPER_POINT.x);
        maxX = /*Math.*/ max(maxX, HELPER_POINT.x);
        minY = /*Math.*/ min(minY, HELPER_POINT.y);
        maxY = /*Math.*/ max(maxY, HELPER_POINT.y);
      }

      resultRect.x = minX;
      resultRect.y = minY;
      resultRect.width = maxX - minX;
      resultRect.height = maxY - minY;
    }

    return resultRect;
  }

  /**
		 * @
		 */
  @override
  DisplayObject hitTest(Point localPoint, [bool forTouch = false]) {
    if (forTouch && (!this.visible || !this.touchable)) {
      return null;
    }
    return this._hitArea.containsPoint(localPoint) ? this : null;
  }

  /**
		 * @
		 */
  @override
  num get width {
    return this._width;
  }

  /**
		 * @
		 */
  @override
  void set width(num value) {
    if (this._width == value) {
      return;
    }

    super.width = value;

    this._width = this._hitArea.width = value;
    this._layoutChanged = true;
    this.invalidate();
  }

  /**
		 * @
		 */
  @override
  num get height {
    return this._height;
  }

  /**
		 * @
		 */
  @override
  void set height(num value) {
    if (this._height == value) {
      return;
    }

    super.height = value;

    this._height = this._hitArea.height = value;
    this._layoutChanged = true;
    this.invalidate();
  }

  @override
  void set scaleX(num value) {
    if (this.scaleX != value) {
      super.scaleX = value;

      this._layoutChanged = true;
      this.invalidate();
    }
  }

  @override
  void set scaleY(num value) {
    if (this.scaleY != value) {
      super.scaleY = value;

      this._layoutChanged = true;
      this.invalidate();
    }
  }

  @override
  void set pivotX(num value) {
    this._pivotChanged = true;
    super.pivotX = value;
  }

  @override
  void set pivotY(num value) {
    this._pivotChanged = true;
    super.pivotY = value;
  }

  @override
  num get x {
    updateTransformMatrix();
    return super.x;
  }

  @override
  num get y {
    updateTransformMatrix();
    return super.y;
  }

  @override
  num get rotation {
    updateTransformMatrix();
    return super.rotation;
  }

  @override
  num get scaleX {
    updateTransformMatrix();
    return super.scaleX;
  }

  @override
  num get scaleY {
    updateTransformMatrix();
    return super.scaleY;
  }

  @override
  num get skewX {
    updateTransformMatrix();
    return super.skewX;
  }

  @override
  num get skewY {
    updateTransformMatrix();
    return super.skewY;
  }

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  void flattenHandler(Event event) {
    this.validate();
  }

  void addedToStageHandler(Event event) {
    this._depth = getDisplayObjectDepthFromStage(this);
    this._validationQueue = ValidationQueue.forStarling(Starling.current);
    if (this._isInvalid) {
      this._validationQueue.addControl(this, false);
    }
  }

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  IGAFTexture get assetTexture {
    return this._textures;
  }

  /**
		 * The textures displayed by this image.
		 *
		 * <p>In the following example, the textures are changed:</p>
		 *
		 * <listing version="3.0">
		 * image.textures = new Scale9Textures( texture, scale9Grid );</listing>
		 */
  GAFScale9Texture get textures {
    return this._textures;
  }

  /**
		 * @
		 */
  void set textures(GAFScale9Texture value) {
    if (value == null) {
      throw new IllegalOperationError("Scale9Image textures cannot be null.");
    }

    if (this._textures != value) {
      this._textures = value;
      Texture texture = this._textures.texture;
      this._frame = texture.frame;
      if (this._frame == null) {
        this._frame = new Rectangle(0, 0, texture.width, texture.height);
      }
      this._layoutChanged = true;
      this._renderingChanged = true;
      this.invalidate();
    }
  }

  /**
		 * The amount to scale the texture. Useful for DPI changes.
		 *
		 * <p>In the following example, the texture scale is changed:</p>
		 *
		 * <listing version="3.0">
		 * image.textureScale = 2;</listing>
		 *
		 * @default 1
		 */
  num get textureScale {
    return this._textureScale;
  }

  /**
		 * @
		 */
  void set textureScale(num value) {
    if (!MathUtility.equals(this._textureScale, value)) {
      this._textureScale = value;
      this._layoutChanged = true;
      this.invalidate();
    }
  }

  /**
		 * The smoothing value to pass to the images.
		 *
		 * <p>In the following example, the smoothing is changed:</p>
		 *
		 * <listing version="3.0">
		 * //image.smoothing = TextureSmoothing.NONE; //not supported in StageXL</listing>
		 *
		 * @default starling.textures.TextureSmoothing.BILINEAR
		 *
		 * @see starling.textures.TextureSmoothing
		 */
  String get smoothing {
    return this._smoothing;
  }

  /**
		 * @
		 */
  void set smoothing(String value) {
    if (this._smoothing != value) {
      this._smoothing = value;
      this._propertiesChanged = true;
      this.invalidate();
    }
  }

  /**
		 * The color value to pass to the images.
		 *
		 * <p>In the following example, the color is changed:</p>
		 *
		 * <listing version="3.0">
		 * image.color = 0xff00ff;</listing>
		 *
		 * @default 0xffffff
		 */
  int get color {
    return this._color;
  }

  /**
		 * @
		 */
  void set color(int value) {
    if (this._color != value) {
      this._color = value;
      this._propertiesChanged = true;
      this.invalidate();
    }
  }

  /**
		 * Determines if the regions are batched normally by Starling or if
		 * they're batched separately.
		 *
		 * <p>In the following example, the separate batching is disabled:</p>
		 *
		 * <listing version="3.0">
		 * image.useSeparateBatch = false;</listing>
		 *
		 * @default true
		 */
  bool get useSeparateBatch {
    return this._useSeparateBatch;
  }

  /**
		 * @
		 */
  void set useSeparateBatch(bool value) {
    if (this._useSeparateBatch != value) {
      this._useSeparateBatch = value;
      this._renderingChanged = true;
      this.invalidate();
    }
  }

  /**
		 * @copy feathers.core.IValidating#depth
		 */
  int get depth {
    return this._depth;
  }

  /** @ */
  Point get maxSize {
    return this._maxSize;
  }

  /** @ */
  void set maxSize(Point value) {
    this._maxSize = value;
  }

  /** @ */
  Matrix get pivotMatrix {
    HELPER_MATRIX.copyFrom(this._textures.pivotMatrix);

    if (this._pivotChanged) {
      HELPER_MATRIX.tx = HELPER_MATRIX.a * this.pivotX;
      HELPER_MATRIX.ty = HELPER_MATRIX.d * this.pivotY;
    }

    return HELPER_MATRIX;
  }

  //--------------------------------------------------------------------------
  //
  //  STATIC METHODS
  //
  //--------------------------------------------------------------------------
}
*/
