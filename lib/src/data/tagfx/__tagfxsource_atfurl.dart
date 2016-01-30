/**
 * Created by Nazar on 13.01.2016.
 */
part of stagexl_gaf;

/**
	 * @
	 */
class TAGFXSourceATFURL extends TAGFXBase {
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

  int _numTextures;
  bool _isCubeMap;

  ATFLoader _atfLoader;
  bool _atfIsLoading;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------
  TAGFXSourceATFURL(String source, GAFATFData atfData) : super() {
    this._source = source;
    this._textureFormat = atfData.format;
    this._numTextures = atfData.numTextures;
    this._isCubeMap = atfData.isCubeMap;

    this.textureSize = new Point(atfData.width, atfData.height);

    this._atfLoader = new ATFLoader();
    this._atfLoader.dataFormat = URLLoaderDataFormat.BINARY;

    this._atfLoader.addEventListener(Event.COMPLETE, this.onATFLoadComplete);
    this
        ._atfLoader
        .addEventListener(IOErrorEvent.IO_ERROR, this.onATFLoadIOError);
    this._atfLoader.addEventListener(
        SecurityErrorEvent.SECURITY_ERROR, this.onATFLoadSecurityError);
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

  void loadATFData(String url) {
    if (this._atfIsLoading) {
      try {
        this._atfLoader.close();
      } catch (e) {}
    }

    this._atfLoader.load(new URLRequest(url));
    this._atfIsLoading = true;
  }

  //--------------------------------------------------------------------------
  //
  // OVERRIDDEN METHODS
  //
  //--------------------------------------------------------------------------

  @override
  String get sourceType {
    return TAGFXBase.SOURCE_TYPE_ATF_URL;
  }

  @override
  Texture get texture {
    if (!this._texture) {
      this._texture = Texture.empty(
          this._textureSize.x / this._textureScale,
          this._textureSize.y / this._textureScale,
          false,
          GAF.useMipMaps && this._numTextures > 1,
          false,
          this._textureScale,
          this._textureFormat,
          false);

      this._texture.root.onRestore = () {
        loadATFData(_source);
      };

      loadATFData(this._source);
    }

    return this._texture;
  }

  //--------------------------------------------------------------------------
  //
  //  EVENT HANDLERS
  //
  //--------------------------------------------------------------------------

  void onATFLoadComplete(Event event) {
    this._atfIsLoading = false;

    ATFLoader loader = event.currentTarget as ATFLoader;
    ByteList sourceBA = loader.data as ByteList;
    this._texture.root.uploadAtfData(sourceBA, 0, (Texture texture) {
      sourceBA.clear();
    });
  }

  void onATFLoadIOError(IOErrorEvent event) {
    this._atfIsLoading = false;
    ATFLoader loader = event.currentTarget as ATFLoader;
    throw new StateError(
        "Can't restore lost context from a ATF file. Can't load file: " +
            loader.urlRequest.url,
        event.errorID);
  }

  void onATFLoadSecurityError(SecurityErrorEvent event) {
    this._atfIsLoading = false;
    ATFLoader loader = event.currentTarget as ATFLoader;
    throw new StateError(
        "Can't restore lost context from a ATF file. Can't load file: " +
            loader.urlRequest.url,
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

class ATFLoader extends URLLoader {
  URLRequest _req;
  ATFLoader([URLRequest request = null]) : super(request) {
    this._req = request;
  }

  @override
  void load(URLRequest request) {
    this._req = request;
    super.load(request);
  }

  URLRequest get urlRequest {
    return this._req;
  }
}
