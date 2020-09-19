part of stagexl_gaf;

class ErrorConstants {
  static final String SCALE_NOT_FOUND = ' scale was not found in GAF config';
  static final String ATLAS_NOT_FOUND = "There is no texture atlas file '";
  static final String FILE_NOT_FOUND = "File or directory not found: '";
  static final String GAF_NOT_FOUND = 'No GAF animation files found';
  static final String CSF_NOT_FOUND = ' CSF was not found in GAF config';
  static final String TIMELINES_NOT_FOUND = 'No animations found.';
  static final String EMPTY_ZIP = 'zero file count in zip';
  static final String ERROR_LOADING = 'Error occured while loading ';
  static final String ERROR_PARSING = 'GAF parse error';
  static final String UNSUPPORTED_JSON = 'JSON format is no longer supported';
  static final String UNKNOWN_FORMAT = 'Unknown data format.';
}

class WarningConstants {
  static final String UNSUPPORTED_FILTERS = 'Unsupported filter in animation';
  static final String UNSUPPORTED_FILE =
      'You are using an old version of GAF library';
  static final String UNSUPPORTED_TAG =
      'Unsupported tag found, check for playback library updates';
  static final String FILTERS_UNDER_MASK =
      'Warning! Animation contains objects with filters under mask! Online preview is not able to display filters applied under masks (flash player technical limitation). All other runtimes will display this correctly.';
  static final String REGION_NOT_FOUND =
      "In the texture atlas element is missing. This is conversion bug. Please report issue <font color='#0000ff'><u><a href='http://gafmedia.com/contact'>here</a></u></font> and we will fix it (use the Request type - Report Issue).";
}
