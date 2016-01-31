part of stagexl_gaf;

class CTextureAtlasElement {

  final String id;
  final String atlasID;

  String linkage = null;
  Rectangle region = null;
  Rectangle scale9Grid = null;
  Matrix pivotMatrix = null;
  bool rotated = false;

  CTextureAtlasElement(this.id, this.atlasID);

}
