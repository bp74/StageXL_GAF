part of stagexl_gaf;

/// GAFImage represents static GAF display object that is part of
/// the [GAFMovieClip].

class GAFImage extends Bitmap implements MaxSize {

  GAFTexture _assetTexture;

  Point _maxSize = null;
  num _filterScale = 1.0;
  CFilter _filterConfig = null;

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

  GAFTexture get assetTexture => _assetTexture;

  void set transformationMatrix(Matrix value) {
    throw new UnimplementedError("transformationMatrix setter");
  }

  //--------------------------------------------------------------------------

  /// Creates a new instance of GAFImage.

  GAFImage copy() => new GAFImage(_assetTexture);

  /// Change the texture of the [GAFImage] to a new one.

  void changeTexture(GAFTexture newTexture) {
    this.bitmapData = newTexture.texture;
    _assetTexture = newTexture.clone();
  }

  //--------------------------------------------------------------------------

  bool _isEquivalent(num a, num b, [num epsilon=0.0001]) {
    return (a - epsilon < b) && (a + epsilon > b);
  }


}
