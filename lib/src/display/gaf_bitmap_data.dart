part of stagexl_gaf;

class GAFBitmapData extends BitmapData {

  final Rectangle<num> scale9Grid;
  final Matrix transformationMatrix;

  GAFBitmapData(
      this.scale9Grid, this.transformationMatrix,
      RenderTextureQuad renderTextureQuad)
      : super.fromRenderTextureQuad(renderTextureQuad);

  // TODO: implement scale9Grid
  // TODO: remove transformationMatrix by changing vxList

}
