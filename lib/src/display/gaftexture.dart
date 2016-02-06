part of stagexl_gaf;

class GAFTexture implements IGAFTexture {

  final String id;
  final BitmapData texture;
  final Matrix pivotMatrix;

  GAFTexture(this.id, this.texture, this.pivotMatrix);

  //--------------------------------------------------------------------------

  IGAFTexture clone() => new GAFTexture(id, texture, pivotMatrix.clone());
}
