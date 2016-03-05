part of stagexl_gaf;

/// The [GAFBitmap] display object represents a static image that is
/// part of the [GAFMovieClip].

class GAFBitmap extends Bitmap implements GAFDisplayObject {

  GAFBitmap(GAFBitmapData gafBitmapData) : super(gafBitmapData);

  //--------------------------------------------------------------------------

  @override
  GAFBitmapData get bitmapData => super.bitmapData;

  @override
  Matrix get pivotMatrix => bitmapData.config.matrix;

  @override
  void set bitmapData(GAFBitmapData value) {
    this.bitmapData = value;
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
      throw new UnimplementedError("Implement support for scale9Grid");
      //this.transformationMatrix = this.transformationMatrix;
      //var ixList = new Int16List(9 * 6);
      //var vxList = new Float32List(16 * 4);
      //var renderTexture = renderTextureQuad.renderTexture;
      //renderState.renderTextureMesh(renderTexture, ixList, vxList);
    }
  }

}
