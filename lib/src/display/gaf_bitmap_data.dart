part of stagexl_gaf;

class GAFBitmapData extends BitmapData {

  final Rectangle<num> scale9Grid;
  final Matrix pivotMatrix;

  GAFBitmapData(
      this.scale9Grid,
      this.pivotMatrix,
      RenderTextureQuad renderTextureQuad)
      : super.fromRenderTextureQuad(renderTextureQuad) {

    // TODO: replace transformationMatrix by something else
    // TODO: implement scale9Grid with custom ixList and vxList!
  }

}
