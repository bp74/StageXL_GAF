part of stagexl_gaf;

class GAFTexture {

  final String id;
  final BitmapData texture;
  final Matrix pivotMatrix;
  final Rectangle<num> scale9Grid;  // TODO: implement scale9Grid

  GAFTexture(this.id, this.texture, this.pivotMatrix, this.scale9Grid);

  //--------------------------------------------------------------------------

  GAFTexture clone() {
    var pivotMatrix = this.pivotMatrix.clone();
    var scale9Grid = this.scale9Grid?.clone();
    return new GAFTexture(id, texture, pivotMatrix, scale9Grid);
  }
}
