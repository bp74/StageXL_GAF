part of stagexl_gaf;

class GAFSoundLoader {
  final CSound config;
  final Completer<Sound> completer = new Completer<Sound>();
  GAFSoundLoader(this.config);
}

//-----------------------------------------------------------------------------

class GAFSound {

  final CSound config;
  final Sound sound;

  GAFSound(this.config, this.sound);

}