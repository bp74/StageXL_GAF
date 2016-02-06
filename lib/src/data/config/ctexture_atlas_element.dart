part of stagexl_gaf;

class CTextureAtlasElement {

  final String id;
  final String atlasID;
  final Matrix pivotMatrix = new Matrix.fromIdentity();
  final Rectangle<int> region = new Rectangle<int>(0, 0, 0, 0);

  String linkage = null;
  Rectangle scale9Grid = null;
  bool rotated = false;

  CTextureAtlasElement(this.id, this.atlasID);

}
