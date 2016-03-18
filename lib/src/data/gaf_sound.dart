part of stagexl_gaf;

class GAFSound {

  final CSound config;
  final Sound sound;

  GAFSound(this.config, this.sound);

  //---------------------------------------------------------------------------

  SoundChannel play() => sound.play();
}
