part of stagexl_gaf;

abstract class IGAFImage extends IGAFDisplayObject {
  IGAFTexture get assetTexture;
  String get smoothing;
  void set smoothing(String value);
}
