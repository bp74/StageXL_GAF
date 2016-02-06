part of stagexl_gaf;

/// [GAFBitmap] represents static GAF display object that is part of
/// the [GAFMovieClip].

class GAFBitmap extends Bitmap implements MaxSize {

  GAFBitmapData _gafBitmapData;
  Point _maxSize = null;

  /// Creates a new [GAFBitmap] instance.
  ///
  /// @param assetTexture [IGAFTexture] from which it will be created.

  GAFBitmap(GAFBitmapData gafBitmapData)
      : _gafBitmapData = gafBitmapData,
        super(gafBitmapData);

  //--------------------------------------------------------------------------

  GAFBitmapData get gafBitmapData => _gafBitmapData;

  Point get maxSize => _maxSize;

  void set maxSize(Point value) {
    _maxSize = value;
  }

  //--------------------------------------------------------------------------

  /// Creates a new instance of GAFImage.

  GAFBitmap copy() => new GAFBitmap(_gafBitmapData);

  /// Change the texture of the [GAFBitmap] to a new one.

  void changeTexture(GAFBitmapData gafBitmapData) {
    this.bitmapData = gafBitmapData;
    _gafBitmapData = gafBitmapData.clone();
  }

}
