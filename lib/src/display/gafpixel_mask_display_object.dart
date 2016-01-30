part of stagexl_gaf;

class GAFPixelMaskDisplayObject extends DisplayObjectContainer {

  static final String MASK_MODE = "mask";
  static final int PADDING = 1;
  static final Rectangle sHelperRect = new Rectangle(0,0,0,0);

  DisplayObject _mask;

  RenderTexture _renderTexture;
  RenderTexture _maskRenderTexture;

  Bitmap _image;
  Bitmap _maskImage;

  bool _superRenderFlag = false;

  Point _maskSize;
  bool _staticMaskSize;
  num _scaleFactor;

  bool _mustReorder;

  GAFPixelMaskDisplayObject([num scaleFactor = -1]) {
    this._scaleFactor = scaleFactor;
    this._maskSize = new Point(0, 0);

//    BlendMode.register(MASK_MODE, Context3DBlendFactor.ZERO, Context3DBlendFactor.SOURCE_ALPHA);

  }

  void dispose() {
    this.clearRenderTextures();
  }

  void onContextCreated(Object event) {
    this.refreshRenderTextures();
  }

  void set pixelMask(DisplayObject value) {

    // clean up existing mask if there is one

    if (_mask != null) {
      _mask = null;
      _maskSize.setTo(0, 0);
    }

    if (value != null) {

      _mask = value;

      if (_mask.width == 0 || _mask.height == 0) {
        throw new StateError("Mask must have dimensions. Current dimensions are " + _mask.width + "x" + _mask.height + ".");
      }

      IMaxSize objectWithMaxSize = (_mask is IMaxSize) ? _mask : null;
      if (objectWithMaxSize != null && objectWithMaxSize.maxSize != null) {
        _maskSize.copyFrom(objectWithMaxSize.maxSize);
        _staticMaskSize = true;
      } else {
        sHelperRect.copyFrom(_mask.bounds);
        _maskSize.setTo(sHelperRect.width, sHelperRect.height);
        _staticMaskSize = false;
      }

      this.refreshRenderTextures(null);
    } else {
      this.clearRenderTextures();
    }
  }

  DisplayObject get pixelMask {
    return this._mask;
  }

  void clearRenderTextures() {
    // clean up old render textures and images
    _maskRenderTexture?.dispose();
    _renderTexture?.dispose();
    //_image?.dispose();
    //_maskImage?.dispose();
  }

  void refreshRenderTextures([Event event = null]) {

    if (_mask != null) {
      this.clearRenderTextures();

      this._renderTexture = new RenderTexture(
          this._maskSize.x, this._maskSize.y, false, this._scaleFactor);
      this._maskRenderTexture = new RenderTexture(
          this._maskSize.x + PADDING * 2,
          this._maskSize.y + PADDING * 2,
          false,
          this._scaleFactor);

      // create image with the new render texture
      this._image = new Image(this._renderTexture);
      // create image to blit the mask onto
      this._maskImage = new Image(this._maskRenderTexture);
      this._maskImage.x = this._maskImage.y = -PADDING;
      // set the blending mode to MASK (ZERO, SRC_ALPHA)
      this._maskImage.blendMode = MASK_MODE;
    }
  }

  @override
  void render(RenderSupport support, num parentAlpha) {
    if (this._superRenderFlag || !this._mask) {
      super.render(support, parentAlpha);
    } else if (this._mask != null) {
      int previousStencilRefValue = support.stencilReferenceValue;
      if (previousStencilRefValue != null) support.stencilReferenceValue = 0;

      _tx = this._mask.transformationMatrix.tx;
      _ty = this._mask.transformationMatrix.ty;

      this._mask.getBounds(null, sHelperRect);

      if (!this._staticMaskSize
          //&& (sHelperRect.width > this._maskSize.x || sHelperRect.height > this._maskSize.y)
          &&
          (sHelperRect.width != this._maskSize.x ||
              sHelperRect.height != this._maskSize.y)) {
        this._maskSize.setTo(sHelperRect.width, sHelperRect.height);
        this.refreshRenderTextures();
      }

      this._mask.transformationMatrix.tx = _tx - sHelperRect.x + PADDING;
      this._mask.transformationMatrix.ty = _ty - sHelperRect.y + PADDING;
      this._maskRenderTexture.draw(this._mask);
      this._image.transformationMatrix.tx = sHelperRect.x;
      this._image.transformationMatrix.ty = sHelperRect.y;
      this._mask.transformationMatrix.tx = _tx;
      this._mask.transformationMatrix.ty = _ty;

      this._renderTexture.drawBundled(this.drawRenderTextures);

      if (previousStencilRefValue != null)
        support.stencilReferenceValue = previousStencilRefValue;

      support.addMatrix();
      support.transformMatrix(this._image);
      this._image.render(support, parentAlpha);
      support.popMatrix();
    }
  }

  static num _a;
  static num _b;
  static num _c;
  static num _d;
  static num _tx;
  static num _ty;

  void drawRenderTextures(
      [DisplayObject object = null, Matrix matrix = null, num alpha = 1.0]) {
    _a = this.transformationMatrix.a;
    _b = this.transformationMatrix.b;
    _c = this.transformationMatrix.c;
    _d = this.transformationMatrix.d;
    _tx = this.transformationMatrix.tx;
    _ty = this.transformationMatrix.ty;

    this.transformationMatrix.copyFrom(this._image.transformationMatrix);
    this.transformationMatrix.invert();

    this._superRenderFlag = true;
    this._renderTexture.draw(this);
    this._superRenderFlag = false;

    this.transformationMatrix.a = _a;
    this.transformationMatrix.b = _b;
    this.transformationMatrix.c = _c;
    this.transformationMatrix.d = _d;
    this.transformationMatrix.tx = _tx;
    this.transformationMatrix.ty = _ty;

    //-----------------------------------------------------------------------------------------------------------------

    this._renderTexture.draw(this._maskImage);
  }

  bool get mustReorder {
    return this._mustReorder;
  }

  void set mustReorder(bool value) {
    this._mustReorder = value;
  }
}
