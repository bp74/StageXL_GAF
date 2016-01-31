/**
 * Created by Nazar on 11.06.2015.
 */
part of stagexl_gaf;

/** @ */
class GAFAsset {
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

  GAFAssetConfig _config;

  List<GAFTimeline> _timelines;
  Map<String, GAFTimeline> _timelinesMap = new Map<String, GAFTimeline>();
  Map<String, GAFTimeline> _timelinesByLinkage = new Map<String, GAFTimeline>();

  num _scale;
  num _csf;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  GAFAsset(GAFAssetConfig config) {
    _config = config;
    _scale = config.defaultScale;
    _csf = config.defaultContentScaleFactor;
    _timelines = new List<GAFTimeline>();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  /**
		 * Disposes all assets in bundle
		 */
  void dispose() {
    _timelines?.forEach((t) => t.dispose());
    _timelines = null;
    _config?.dispose();
    _config = null;
  }

  void addGAFTimeline(GAFTimeline timeline) {
    // use namespace gaf_internal;
    if (!_timelinesMap.containsKey(timeline.id)) {
      _timelinesMap[timeline.id] = timeline;
      _timelines.add(timeline);
      if (timeline.config.linkage != null) {
        _timelinesByLinkage[timeline.linkage] = timeline;
      }
    } else {
      throw new StateError("Bundle error. More then one timeline use id: '" + timeline.id + "'");
    }
  }

  /**
		 * Returns <code>GAFTimeline</code> from gaf asset by linkage
		 * @param linkage linkage in a *.fla file library
		 * @return <code>GAFTimeline</code> from gaf asset
		 */

  GAFTimeline getGAFTimelineByLinkage(String linkage) {
    return this._timelinesByLinkage[linkage];
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

  /** @
		 * Returns <code>GAFTimeline</code> from gaf asset by ID
		 * @param id internal timeline id
		 * @return <code>GAFTimeline</code> from gaf asset
		 */

  GAFTimeline _getGAFTimelineByID(String id) {
    return _timelinesMap[id];
  }

  /** @
		 * Returns <code>GAFTimeline</code> from gaf asset bundle by linkage
		 * @param linkage linkage in a *.fla file library
		 * @return <code>GAFTimeline</code> from gaf asset
		 */
  GAFTimeline _getGAFTimelineByLinkage(String linkage) {
    return _timelinesByLinkage[linkage];
  }

  IGAFTexture _getCustomRegion(String linkage, [num scale, num csf]) {

    if (scale == null) scale = this._scale;
    if (csf == null) csf = this._csf;

    IGAFTexture gafTexture;
    CTextureAtlasScale atlasScale;
    CTextureAtlasCSF atlasCSF;
    CTextureAtlasElement element;

    int tasl = _config.allTextureAtlases.length;

    for (int i = 0; i < tasl; i++) {
      atlasScale = _config.allTextureAtlases[i];

      if (atlasScale.scale == scale) {
        int tacsfl = atlasScale.allContentScaleFactors.length;

        for (int j = 0; j < tacsfl; j++) {
          atlasCSF = atlasScale.allContentScaleFactors[j];

          if (atlasCSF.csf == csf) {
            element = atlasCSF.elements.getElementByLinkage(linkage);

            if (element != null) {
              BitmapData texture = atlasCSF.atlas._getTextureByIDAndAtlasID(element.id, element.atlasID);
              Matrix pivotMatrix = element.pivotMatrix;
              if (element.scale9Grid != null) {
                gafTexture = new GAFScale9Texture(id, texture, pivotMatrix, element.scale9Grid);
              } else {
                gafTexture = new GAFTexture(id, texture, pivotMatrix);
              }
            }

            break;
          }
        }
        break;
      }
    }

    return gafTexture;
  }

  /** @ */
  num _getValidScale(num value) {
    int index = MathUtility.getItemIndex(this._config.scaleValues, value);
    if (index != -1) {
      return this._config.scaleValues[index];
    }
    return null;
  }

  /** @ */
  bool _hasCSF(num value) {
    return MathUtility.getItemIndex(this._config.csfValues, value) >= 0;
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

  /**
		 * Returns all <code>GAFTimeline's</code> from gaf asset as <code>List/code>
		 * @return <code>GAFTimeline's</code> from gaf asset
		 */
  List<GAFTimeline> get timelines => _timelines;

  String get id => _config.id;

  num get scale => _scale;

  set scale(num value) {
    _scale = value;
  }

  num get csf => _csf;

  set csf(num value) {
    _csf = value;
  }
}
