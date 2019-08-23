part of stagexl_gaf;

class CTextureAtlasElement {

  final int id;
  final int atlasID;
  final Matrix matrix = Matrix.fromIdentity();
  final Rectangle<int> region = Rectangle<int>(0, 0, 0, 0);

  String linkage;
  Rectangle scale9Grid;
  bool rotated = false;

  CTextureAtlasElement(this.id, this.atlasID);

}
