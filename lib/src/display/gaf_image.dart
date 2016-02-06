part of stagexl_gaf;

/// GAFImage represents static GAF display object that is part of
/// the [GAFMovieClip].

class GAFImage extends Bitmap implements MaxSize {

  GAFTexture _assetTexture;
  Point _maxSize = null;

  /// Creates a new [GAFImage] instance.
  ///
  /// @param assetTexture [IGAFTexture] from which it will be created.

  GAFImage(GAFTexture assetTexture)
      : _assetTexture = assetTexture.clone(),
        super(assetTexture.texture);

  //--------------------------------------------------------------------------

  GAFTexture get assetTexture => _assetTexture;

  Point get maxSize => _maxSize;

  void set maxSize(Point value) {
    _maxSize = value;
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
