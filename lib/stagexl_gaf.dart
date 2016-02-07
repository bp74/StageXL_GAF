library stagexl_gaf;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' hide Rectangle, Point;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:stagexl/stagexl.dart';

part 'src/core/gaf_bundle_loader.dart';
part 'src/core/gaf_timelines_manager.dart';

part 'src/data/config/canimation_frame.dart';
part 'src/data/config/canimation_frame_instance.dart';
part 'src/data/config/canimation_frames.dart';
part 'src/data/config/canimation_object.dart';
part 'src/data/config/canimation_objects.dart';
part 'src/data/config/canimation_sequence.dart';
part 'src/data/config/canimation_sequences.dart';
part 'src/data/config/cblur_filter_data.dart';
part 'src/data/config/ccolor_matrix_filter_data.dart';
part 'src/data/config/cfilter.dart';
part 'src/data/config/cfilter_data.dart';
part 'src/data/config/cframe_action.dart';
part 'src/data/config/cframe_sound.dart';
part 'src/data/config/csound.dart';
part 'src/data/config/cstage.dart';
part 'src/data/config/ctext_field_object.dart';
part 'src/data/config/ctext_field_objects.dart';
part 'src/data/config/ctexture_atlas.dart';
part 'src/data/config/ctexture_atlas_csf.dart';
part 'src/data/config/ctexture_atlas_element.dart';
part 'src/data/config/ctexture_atlas_elements.dart';
part 'src/data/config/ctexture_atlas_scale.dart';
part 'src/data/config/ctexture_atlas_source.dart';

part 'src/data/converters/bin_gafasset_config_converter.dart';
part 'src/data/converters/error_constants.dart';
part 'src/data/converters/warning_constants.dart';

part 'src/data/tagfx/tagfx.dart';
part 'src/data/tagfx/tagfxbase.dart';
part 'src/data/tagfx/tagfxsource_bitmap_data.dart';

part 'src/data/gaf_asset.dart';
part 'src/data/gaf_asset_config.dart';
part 'src/data/gaf_bundle.dart'; // ???
part 'src/data/gaf_debug_information.dart';
part 'src/data/gaf_gfxdata.dart';
part 'src/data/gaf_timeline.dart';
part 'src/data/gaf_timeline_config.dart';

part 'src/display/gaf_bitmap.dart';
part 'src/display/gaf_movie_clip.dart';
part 'src/display/gaf_text_field.dart';
part 'src/display/gaf_text_field_text_editor.dart';
part 'src/display/gaf_bitmap_data.dart';
part 'src/display/gaf_display_object.dart';

part 'src/sound/gaf_sound_channel.dart';
part 'src/sound/gaf_sound_data.dart';
part 'src/sound/gaf_sound_manager.dart';



