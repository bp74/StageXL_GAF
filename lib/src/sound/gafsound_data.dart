 part of stagexl_gaf;

class GAFSoundData {

  final Map _sounds = new Map();

  void addSound(CSound soundData, String swfName) {
    if (soundData.linkageName.length > 0) {
      _sounds[soundData.linkageName] = soundData.sound;
    } else {
      _sounds[swfName] ??= {};
      _sounds[swfName][soundData.soundID] = soundData.sound;
    }
  }

  Sound getSoundByLinkage(String linkage) {
    return _sounds[linkage];
  }

  Sound getSound(int soundID, String swfName) {
    return _sounds[swfName][soundID];
  }

  void dispose() {
    /*
    for (Sound sound in this._sounds) {
      sound.close();
    }
    */
  }

}
