part of stagexl_gaf;

/// The [GAFBitmap] display object represents a static image that is
/// part of the [GAFMovieClip].

class GAFBitmap extends Bitmap implements GAFDisplayObject {

  final Matrix pivotMatrix = new Matrix.fromIdentity();

  GAFBitmap(GAFBitmapData gafBitmapData) : super(gafBitmapData) {
    this.pivotMatrix.copyFrom(gafBitmapData.config.matrix);
  }

  //--------------------------------------------------------------------------

  @override
  GAFBitmapData get bitmapData => super.bitmapData;

  @override
  void set bitmapData(GAFBitmapData value) {
    this.pivotMatrix.copyFrom(value.config.matrix);
    super.bitmapData = value;
  }

  //--------------------------------------------------------------------------

  /// Creates a clone of this [GAFBitmap].

  GAFBitmap clone() => new GAFBitmap(this.bitmapData);

  //--------------------------------------------------------------------------

  @override
  void render(RenderState renderState) {

    var bitmapData = this.bitmapData;
    if (bitmapData == null) return;

    var scale9Grid = bitmapData.config.scale9Grid;
    var renderTextureQuad = bitmapData.renderTextureQuad;

    if (scale9Grid == null) {
      renderState.renderTextureQuad(renderTextureQuad);
    } else {
      // http://gafmedia.com/forum/viewtopic.php?f=3&t=540
      // we will add it once GAFConverter exports it!
      throw new UnimplementedError("Implement support for scale9Grid");
    }
  }

}
