part of stagexl_gaf;

/// GAFImage represents static GAF display object that is part of
/// the [GAFMovieClip].

class GAFImage extends Bitmap implements IGAFImage, IMaxSize {

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

  IGAFTexture _assetTexture;

  CFilter _filterConfig;
  num _filterScale;

  Point _maxSize;

  bool _orientationChanged = false;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  /// Creates a new <code>GAFImage</code> instance.
  ///
  /// @param assetTexture [IGAFTexture] from which it will be created.

  GAFImage(GAFTexture assetTexture) : super(assetTexture.texture) {
    _assetTexture = assetTexture.clone();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  /// Creates a new instance of GAFImage.

  GAFImage copy() => new GAFImage(_assetTexture);

  void invalidateOrientation() {
    _orientationChanged = true;
  }

  /// Change the texture of the <code>GAFImage</code> to a new one.
  /// @param newTexture the new <code>IGAFTexture</code> which will be used to replace existing one.

  void changeTexture(IGAFTexture newTexture) {
    this.texture = newTexture.texture;
    this.readjustSize();
    _assetTexture.copyFrom(newTexture);
  }

  void setFilterConfig(CFilter value,[num scale=1]) {

    /*
    if (this._filterConfig != value || this._filterScale != scale)
    {
      if( value != null)
      {
        this._filterConfig = value;
        this._filterScale = scale;
        GAFFilter gafFilter;
        if (this.filter != null)
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
      else
      {
        if (this.filter != null)
        {
          this.filter.dispose();
          this.filter = null;
        }
        this._filterConfig = null;
        this._filterScale = NaN;
      }
    }
    */
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  void _updateTransformMatrix() {
    if (_orientationChanged) {
      this.transformationMatrix = this.transformationMatrix;
      _orientationChanged = false;
    }
  }

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  /*

  @override
  void dispose() {

    if (this.filter != null) {
      this.filter.dispose();
      this.filter = null;
    }

    this._assetTexture = null;
    this._filterConfig = null;

    super.dispose();
  }

  */

  /*
  @override
  Rectangle getBounds(DisplayObject targetSpace,[Rectangle resultRect=null])
  {
    if (resultRect == null) resultRect = new Rectangle();

    if (targetSpace == this) // optimization
    {
      mVertexData.getPosition(3, HELPER_POINT);
      resultRect.setTo(0.0, 0.0, HELPER_POINT.x, HELPER_POINT.y);
    }
    else if (targetSpace == parent && rotation == 0.0 && isEquivalent(skewX, skewY)) // optimization
    {
      num scaleX = this.scaleX;
      num scaleY = this.scaleY;
      mVertexData.getPosition(3, HELPER_POINT);
      resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
          HELPER_POINT.x * scaleX, HELPER_POINT.y * scaleY);
      if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
      if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
    }
    else if (is3D != null && stage != null)
    {
      stage.getCameraPosition(targetSpace, HELPER_POINT_3D);
      getTransformationMatrix3D(targetSpace, HELPER_MATRIX_3D);
      mVertexData.getBoundsProjected(HELPER_MATRIX_3D, HELPER_POINT_3D, 0, 4, resultRect);
    }
    else
    {
      getTransformationMatrix(targetSpace, HELPER_MATRIX);
      mVertexData.getBounds(HELPER_MATRIX, 0, 4, resultRect);
    }

    return resultRect;
  }
  */

  bool _isEquivalent(num a, num b, [num epsilon=0.0001]) {
    return (a - epsilon < b) && (a + epsilon > b);
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

  Point get maxSize => _maxSize;

  void set maxSize(Point value) {
    _maxSize = value;
  }

  IGAFTexture get assetTexture => _assetTexture;

  Matrix get pivotMatrix {
    // TODO: What is this?
    var matrix = _assetTexture.pivotMatrix.clone();
    //matrix.tx = this.pivotX;
    //matrix.ty = this.pivotY;
    return matrix;
  }

}
