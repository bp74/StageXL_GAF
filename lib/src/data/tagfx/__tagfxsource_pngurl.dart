/**
 * Created by Nazar on 12.01.2016.
 */
part of stagexl_gaf;

/**
	 * @
	 */
class TAGFXSourcePNGURL extends TAGFXBase {
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

  Loader _pngLoader;
  bool _pngIsLoading;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------
  TAGFXSourcePNGURL(String source, Point textureSize, [String format = "bgra"])
      : super() {
    this._source = source;
    this._textureSize = textureSize;
    this._textureFormat = format;

    this._pngLoader = new Loader();
    this
        ._pngLoader
        .contentLoaderInfo
        .addEventListener(Event.COMPLETE, this.onPNGLoadComplete);
    this
        ._pngLoader
        .contentLoaderInfo
        .addEventListener(IOErrorEvent.IO_ERROR, this.onPNGLoadError);
    this._pngLoader.contentLoaderInfo.addEventListener(
        AsyncErrorEvent.ASYNC_ERROR, this.onPNGLoadAsyncError);
    this._pngLoader.contentLoaderInfo.addEventListener(
        SecurityErrorEvent.SECURITY_ERROR, this.onPNGLoadSecurityError);
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  void loadBitmapData(String url) {
    if (this._pngIsLoading) {
      try {
        this._pngLoader.close();
      } catch (e) {}
    }

    this._pngLoader.load(new URLRequest(url), new LoaderContext());
    this._pngIsLoading = true;
  }

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  @override
  String get sourceType {
    return TAGFXBase.SOURCE_TYPE_PNG_URL;
  }

  @override
  Texture get texture {
    if (!this._texture) {
      this._texture = Texture.empty(
          this._textureSize.x / this._textureScale,
          this._textureSize.y / this._textureScale,
          true,
          GAF.useMipMaps,
          false,
          this._textureScale,
          this._textureFormat,
          false);
      this._texture.root.onRestore = () {
        loadBitmapData(_source);
      };

      loadBitmapData(this._source);
    }

    return this._texture;
  }

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  void onPNGLoadComplete(Event event) {
    this._pngIsLoading = false;

    LoaderInfo info = event.currentTarget as LoaderInfo;
    BitmapData bmpd = (info.content as Bitmap).bitmapData;
    this._texture.root.uploadBitmapData(bmpd);

    this._pngLoader.unload();
    bmpd.dispose();
  }

  void onPNGLoadError(IOErrorEvent event) {
    this._pngIsLoading = false;

    LoaderInfo info = event.currentTarget as LoaderInfo;
    throw new StateError(
        "Can't restore lost context from a PNG file. Can't load file: " +
            info.url,
        event.errorID);
  }

  void onPNGLoadAsyncError(AsyncErrorEvent event) {
    this._pngIsLoading = false;

    LoaderInfo info = event.currentTarget as LoaderInfo;
    throw new StateError(
        "Can't restore lost context from a PNG file. Can't load file: " +
            info.url,
        event.errorID);
  }

  void onPNGLoadSecurityError(SecurityErrorEvent event) {
    this._pngIsLoading = false;

    LoaderInfo info = event.currentTarget as LoaderInfo;
    throw new StateError(
        "Can't restore lost context from a PNG file. Can't load file: " +
            info.url,
        event.errorID);
  }

  //--------------------------------------------------------------------------
  //
  //  GETTERS AND SETTERS
  //
  //--------------------------------------------------------------------------

  //--------------------------------------------------------------------------
  //
  //  STATIC METHODS
  //
  //--------------------------------------------------------------------------
}
