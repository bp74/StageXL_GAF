/**
 * Created by Nazar on 05.03.14.
 */
part of stagexl_gaf;

class GAFScale9Texture implements IGAFTexture {

}

/*
class GAFScale9Texture implements IGAFTexture {
  //--------------------------------------------------------------------------
  //
  //  PUBLIC VARIABLES
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE VARIABLES
  //
  //--------------------------------------------------------------------------

  /**
		 * @
		 */
  static final String DIMENSIONS_ERROR =
      "The width and height of the scale9Grid must be greater than zero.";
  /**
		 * @
		 */
  static final Rectangle HELPER_RECTANGLE = new Rectangle();

  String _id;
  Texture _texture;
  Matrix _pivotMatrix;
  Rectangle _scale9Grid;

  Texture _topLeft;
  Texture _topCenter;
  Texture _topRight;
  Texture _middleLeft;
  Texture _middleCenter;
  Texture _middleRight;
  Texture _bottomLeft;
  Texture _bottomCenter;
  Texture _bottomRight;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------
  GAFScale9Texture(
      String id, Texture texture, Matrix pivotMatrix, Rectangle scale9Grid) {
    this._id = id;
    this._pivotMatrix = pivotMatrix;

    if (scale9Grid.width <= 0 || scale9Grid.height <= 0) {
      throw new ArgumentError(DIMENSIONS_ERROR);
    }
    this._texture = texture;
    this._scale9Grid = scale9Grid;
    this.initialize();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------
  void copyFrom(IGAFTexture newTexture) {
    if (newTexture is GAFScale9Texture) {
      this._id = newTexture.id;
      this._texture = newTexture.texture;
      this._pivotMatrix.copyFrom(newTexture.pivotMatrix);
      this._scale9Grid.copyFrom((newTexture as GAFScale9Texture).scale9Grid);
      this._topLeft = (newTexture as GAFScale9Texture).topLeft;
      this._topCenter = (newTexture as GAFScale9Texture).topCenter;
      this._topRight = (newTexture as GAFScale9Texture).topRight;
      this._middleLeft = (newTexture as GAFScale9Texture).middleLeft;
      this._middleCenter = (newTexture as GAFScale9Texture).middleCenter;
      this._middleRight = (newTexture as GAFScale9Texture).middleRight;
      this._bottomLeft = (newTexture as GAFScale9Texture).bottomLeft;
      this._bottomCenter = (newTexture as GAFScale9Texture).bottomCenter;
      this._bottomRight = (newTexture as GAFScale9Texture).bottomRight;
    } else {
      throw new StateError("Incompatiable types GAFScale9Texture and " +
          getQualifiedTypeName(newTexture));
    }
  }
  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  void initialize() {
    Rectangle textureFrame = _texture.frame;
    if (textureFrame == null) {
      textureFrame = HELPER_RECTANGLE;
      textureFrame.setTo(0, 0, _texture.width, _texture.height);
    }
    num leftWidth = _scale9Grid.left;
    num centerWidth = _scale9Grid.width;
    num rightWidth =
        textureFrame.width - _scale9Grid.width - _scale9Grid.x;
    num topHeight = _scale9Grid.y;
    num middleHeight = _scale9Grid.height;
    num bottomHeight =
        textureFrame.height - _scale9Grid.height - _scale9Grid.y;

    num regionLeftWidth = leftWidth + textureFrame.x;
    num regionTopHeight = topHeight + textureFrame.y;
    num regionRightWidth = rightWidth - (textureFrame.width - _texture.width) - textureFrame.left;
    num regionBottomHeight = bottomHeight - (textureFrame.height - _texture.height) - textureFrame.top;

    bool hasLeftFrame = regionLeftWidth != leftWidth;
    bool hasTopFrame = regionTopHeight != topHeight;
    bool hasRightFrame = regionRightWidth != rightWidth;
    bool hasBottomFrame = regionBottomHeight != bottomHeight;

    Rectangle topLeftRegion = new Rectangle(0, 0, regionLeftWidth, regionTopHeight);
    Rectangle topLeftFrame = (hasLeftFrame || hasTopFrame)
        ? new Rectangle(textureFrame.x, textureFrame.y, leftWidth, topHeight)
        : null;
    this._topLeft =
        Texture.fromTexture(this._texture, topLeftRegion, topLeftFrame);

    Rectangle topCenterRegion =
        new Rectangle(regionLeftWidth, 0, centerWidth, regionTopHeight);
    Rectangle topCenterFrame = hasTopFrame
        ? new Rectangle(0, textureFrame.y, centerWidth, topHeight)
        : null;
    this._topCenter =
        Texture.fromTexture(this._texture, topCenterRegion, topCenterFrame);

    Rectangle topRightRegion = new Rectangle(
        regionLeftWidth + centerWidth, 0, regionRightWidth, regionTopHeight);
    Rectangle topRightFrame = (hasTopFrame || hasRightFrame)
        ? new Rectangle(0, textureFrame.y, rightWidth, topHeight)
        : null;
    this._topRight =
        Texture.fromTexture(this._texture, topRightRegion, topRightFrame);

    Rectangle middleLeftRegion =
        new Rectangle(0, regionTopHeight, regionLeftWidth, middleHeight);
    Rectangle middleLeftFrame = hasLeftFrame
        ? new Rectangle(textureFrame.x, 0, leftWidth, middleHeight)
        : null;
    this._middleLeft =
        Texture.fromTexture(this._texture, middleLeftRegion, middleLeftFrame);

    Rectangle middleCenterRegion = new Rectangle(
        regionLeftWidth, regionTopHeight, centerWidth, middleHeight);
    this._middleCenter = Texture.fromTexture(this._texture, middleCenterRegion);

    Rectangle middleRightRegion = new Rectangle(regionLeftWidth + centerWidth,
        regionTopHeight, regionRightWidth, middleHeight);
    Rectangle middleRightFrame =
        hasRightFrame ? new Rectangle(0, 0, rightWidth, middleHeight) : null;
    this._middleRight =
        Texture.fromTexture(this._texture, middleRightRegion, middleRightFrame);

    Rectangle bottomLeftRegion = new Rectangle(
        0, regionTopHeight + middleHeight, regionLeftWidth, regionBottomHeight);
    Rectangle bottomLeftFrame = (hasLeftFrame || hasBottomFrame)
        ? new Rectangle(textureFrame.x, 0, leftWidth, bottomHeight)
        : null;
    this._bottomLeft =
        Texture.fromTexture(this._texture, bottomLeftRegion, bottomLeftFrame);

    Rectangle bottomCenterRegion = new Rectangle(regionLeftWidth,
        regionTopHeight + middleHeight, centerWidth, regionBottomHeight);
    Rectangle bottomCenterFrame =
        hasBottomFrame ? new Rectangle(0, 0, centerWidth, bottomHeight) : null;
    this._bottomCenter = Texture.fromTexture(
        this._texture, bottomCenterRegion, bottomCenterFrame);

    Rectangle bottomRightRegion = new Rectangle(regionLeftWidth + centerWidth,
        regionTopHeight + middleHeight, regionRightWidth, regionBottomHeight);
    Rectangle bottomRightFrame = (hasBottomFrame || hasRightFrame)
        ? new Rectangle(0, 0, rightWidth, bottomHeight)
        : null;
    this._bottomRight =
        Texture.fromTexture(this._texture, bottomRightRegion, bottomRightFrame);
  }

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  String get id {
    return this._id;
  }

  Matrix get pivotMatrix {
    return this._pivotMatrix;
  }

  Texture get texture {
    return this._texture;
  }

  Rectangle get scale9Grid {
    return this._scale9Grid;
  }

  Texture get topLeft {
    return this._topLeft;
  }

  Texture get topCenter {
    return this._topCenter;
  }

  Texture get topRight {
    return this._topRight;
  }

  Texture get middleLeft {
    return this._middleLeft;
  }

  Texture get middleCenter {
    return this._middleCenter;
  }

  Texture get middleRight {
    return this._middleRight;
  }

  Texture get bottomLeft {
    return this._bottomLeft;
  }

  Texture get bottomCenter {
    return this._bottomCenter;
  }

  Texture get bottomRight {
    return this._bottomRight;
  }

  IGAFTexture clone() {
    return new GAFScale9Texture(
        this._id, this._texture, this._pivotMatrix.clone(), this._scale9Grid);
  }

  //--------------------------------------------------------------------------
  //
  //  STATIC METHODS
  //
  //--------------------------------------------------------------------------
}
*/