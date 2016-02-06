part of stagexl_gaf;

/// An abstract class describes objects that contain all data used to
/// initialize static GAF display objects such as <code>GAFImage</code>.

abstract class IGAFTexture {

  /// Returns Starling Texture object.

  BitmapData get texture;

  /// Returns pivot matrix of the static GAF display object.

  Matrix get pivotMatrix;

  /// An internal identifier of the region in a texture atlas.

  String get id;

  /// Returns a new object that is a clone of this object.

  IGAFTexture clone();
}
