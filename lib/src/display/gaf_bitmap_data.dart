part of stagexl_gaf;

class GAFBitmapData extends BitmapData {

  final String id;
  final Rectangle<num> scale9Grid;
  final Matrix transformationMatrix;

  GAFBitmapData(
      this.id, this.scale9Grid, this.transformationMatrix,
      RenderTextureQuad renderTextureQuad)
      : super.fromRenderTextureQuad(renderTextureQuad);

  // TODO: implement scale9Grid
  // TODO: remove transformationMatrix by changing vxList

}
