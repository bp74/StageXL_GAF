part of stagexl_gaf;

class GAFBitmapData extends BitmapData {

  final String id;
  final Matrix transformationMatrix;
  final Rectangle<num> scale9Grid;

  GAFBitmapData(
      String id, RenderTextureQuad renderTextureQuad,
      Matrix transformationMatrix, Rectangle<num> scale9Grid)

      : this.id = id,
        this.transformationMatrix = transformationMatrix,
        this.scale9Grid = scale9Grid,
        super.fromRenderTextureQuad(renderTextureQuad) {

    // TODO: implement scale9Grid
    // TODO: remove transformationMatrix by changing vxList

  }

}
