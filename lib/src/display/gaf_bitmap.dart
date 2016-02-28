part of stagexl_gaf;

/// The [GAFBitmap] display object represents a static image that is
/// part of the [GAFMovieClip].

class GAFBitmap extends Bitmap implements GAFDisplayObject {

  final Matrix pivotMatrix = new Matrix.fromIdentity();

  GAFBitmap(GAFBitmapData gafBitmapData) : super(gafBitmapData) {
    this.pivotMatrix.copyFrom(gafBitmapData.pivotMatrix);
  }

  //--------------------------------------------------------------------------

  @override
  GAFBitmapData get bitmapData => super.bitmapData;

  @override
  void set bitmapData(GAFBitmapData value) {
    this.bitmapData = value;
    this.pivotMatrix.copyFrom(value.pivotMatrix);
  }

  //--------------------------------------------------------------------------

  /// Creates a clone of this [GAFBitmap].

  GAFBitmap clone() => new GAFBitmap(this.bitmapData);
}
