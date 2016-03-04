part of stagexl_gaf;

/// The [GAFBitmap] display object represents a static image that is
/// part of the [GAFMovieClip].

class GAFBitmap extends Bitmap implements GAFDisplayObject {

  final Matrix pivotMatrix = new Matrix.fromIdentity();
  //final Rectangle<num> scale9Grid = new Rectangle<num>(0, 0, 0, 0);

  GAFBitmap(GAFBitmapData gafBitmapData) : super(gafBitmapData) {
    this.pivotMatrix.copyFrom(gafBitmapData.config.matrix);
    //this.scale9Grid.copyFrom(gafBitmapData.element.scale9Grid);
  }

  //--------------------------------------------------------------------------

  @override
  GAFBitmapData get bitmapData => super.bitmapData;

  @override
  void set bitmapData(GAFBitmapData value) {
    this.bitmapData = value;
    this.pivotMatrix.copyFrom(value.config.matrix);
    //this.scale9Grid.copyFrom(value.element.scale9Grid);
  }

  //--------------------------------------------------------------------------

  /// Creates a clone of this [GAFBitmap].

  GAFBitmap clone() => new GAFBitmap(this.bitmapData);
}
