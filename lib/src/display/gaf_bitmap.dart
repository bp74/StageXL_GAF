part of stagexl_gaf;

/// The [GAFBitmap] display object represents a static image that is
/// part of the [GAFMovieClip].

class GAFBitmap extends Bitmap implements GAFDisplayObject {

  Point maxSize = null;

  GAFBitmap(GAFBitmapData gafBitmapData) : super(gafBitmapData);

  //--------------------------------------------------------------------------

  @override
  GAFBitmapData get bitmapData => super.bitmapData;

  @override
  void set bitmapData(GAFBitmapData value) {
    this.bitmapData = value;
  }

  //--------------------------------------------------------------------------

  /// Creates a clone of this [GAFBitmap].

  GAFBitmap clone() => new GAFBitmap(this.bitmapData);
}
