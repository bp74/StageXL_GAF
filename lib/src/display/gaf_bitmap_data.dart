part of stagexl_gaf;

class GAFBitmapData extends BitmapData {

  final Rectangle<num> scale9Grid;
  final Matrix transformationMatrix;

  GAFBitmapData(
      this.scale9Grid,
      this.transformationMatrix,
      RenderTextureQuad renderTextureQuad)
      : super.fromRenderTextureQuad(renderTextureQuad) {

    // TODO: replace transformationMatrix by something else
  }

  //---------------------------------------------------------------------------

  @override
  void render(RenderState renderState) {
    if (this.scale9Grid == null) {
      super.render(renderState);
    } else {
      // TODO: implement scale9Grid with custom ixList and vxList!
      var renderTexture = this.renderTextureQuad.renderTexture;
      var ixList = this.renderTextureQuad.ixList;
      var vxList = this.renderTextureQuad.vxList;
      renderState.renderTextureMesh(renderTexture, ixList, vxList);
    }
  }

}
