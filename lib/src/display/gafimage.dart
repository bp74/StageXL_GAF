part of stagexl_gaf;

/// GAFImage represents static GAF display object that is part of
/// the [GAFMovieClip].

class GAFImage extends Bitmap implements IGAFImage, IMaxSize {

  IGAFTexture _assetTexture;

  Point _maxSize = null;
  num _filterScale = 1.0;
  CFilter _filterConfig = null;
  bool _orientationChanged = false;

  /// Creates a new [GAFImage] instance.
  ///
  /// @param assetTexture [IGAFTexture] from which it will be created.

  GAFImage(GAFTexture assetTexture)
      : _assetTexture = assetTexture.clone(),
        super(assetTexture.texture);

  //--------------------------------------------------------------------------

  Point get maxSize => _maxSize;

  void set maxSize(Point value) {
    _maxSize = value;
  }

  Matrix get pivotMatrix {
    // TODO: What is this?
    var matrix = _assetTexture.pivotMatrix.clone();
    //matrix.tx = this.pivotX;
    //matrix.ty = this.pivotY;
    return matrix;
  }

  IGAFTexture get assetTexture => _assetTexture;

  void set transformationMatrix(Matrix value) {
    throw new UnimplementedError("transformationMatrix setter");
  }

  //--------------------------------------------------------------------------

  /// Creates a new instance of GAFImage.

  GAFImage copy() => new GAFImage(_assetTexture);

  void invalidateOrientation() {
    _orientationChanged = true;
  }

  /// Change the texture of the [GAFImage] to a new one.

  void changeTexture(IGAFTexture newTexture) {
    this.bitmapData = newTexture.texture;
    _assetTexture = newTexture.clone();
  }


  void setFilterConfig(CFilter value, [num scale = 1]) {
    /*
    if (_filterConfig != value || _filterScale != scale) {
      if( value != null) {
        _filterConfig = value;
        _filterScale = scale;
        GAFFilter gafFilter;
        if (this.filter != null) {
          if (this.filter is GAFFilter) {
            gafFilter = this.filter as GAFFilter;
          } else {
            this.filter.dispose();
            gafFilter = new GAFFilter();
          }
        } else {
          gafFilter = new GAFFilter();
        }

        gafFilter.setConfig(this._filterConfig, this._filterScale);
        this.filter = gafFilter;
      } else {
        if (this.filter != null) {
          this.filter.dispose();
          this.filter = null;
        }
        _filterConfig = null;
        _filterScale = null;
      }
    }*/
  }

  //--------------------------------------------------------------------------

  void _updateTransformMatrix() {
    if (_orientationChanged) {
      this.transformationMatrix = this.transformationMatrix;
      _orientationChanged = false;
    }
  }


  bool _isEquivalent(num a, num b, [num epsilon=0.0001]) {
    return (a - epsilon < b) && (a + epsilon > b);
  }


}
