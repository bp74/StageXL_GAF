part of stagexl_gaf;

/// The [GAFSoundManager] provides an abstract class to control GAF sound playback.
/// All adjustments made through [GAFSoundManager] affects all GAF sounds.

class GAFSoundManager {

	Map<String, Map<int, List<GAFSoundChannel>>> _soundChannels = {};

  static GAFSoundManager _getInstance;

  GAFSoundManager._() {

  }

  /// The instance of the <code>GAFSoundManager</code> (singleton)
  ///
  /// @return The instance of the <code>GAFSoundManager</code>

  static GAFSoundManager getInstance() {
    _getInstance ??=  new GAFSoundManager._();
    return _getInstance;
  }

  //---------------------------------------------------------------------------

  /// The volume of the GAF sounds, ranging from 0 (to as silent) 1 (full volume).
  /// @param volume the volume of the sound

  void setVolume(num volume) {

    for (String swfName in _soundChannels.keys) {
      for (int soundID in _soundChannels[swfName].keys) {
        for (var channel in _soundChannels[swfName][soundID]) {
          channel.soundChannel.soundTransform = new SoundTransform(volume);
        }
      }
    }
  }

  /// Stops all GAF sounds currently playing

  void stopAll() {

    for (String swfName in _soundChannels.keys) {
      for (int soundID in _soundChannels[swfName].keys) {
        for (var channel in _soundChannels[swfName][soundID]) {
          channel.stop();
        }
      }
    }

    _soundChannels = {};
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void _play(Sound sound, int soundID, Map soundOptions, String swfName) {

    bool continueSound = soundOptions["continue"] ?? false;
    // int repeatCount = soundOptions["repeatCount"] ?? 1;

    if (continueSound
			&& _soundChannels.containsKey(swfName)
			&& _soundChannels[swfName].containsKey(soundID)) {
      //sound already in play - no need to launch it again
      return;
    }

    // TODO: add support for repeat count

    GAFSoundChannel soundData = new GAFSoundChannel(swfName, soundID);
    soundData.soundChannel = sound.play();

    soundData.on(Event.COMPLETE).first.then((e) {
      if (_soundChannels.containsKey(swfName)) {
        _soundChannels[swfName].remove(soundID);
      }
    });

		_soundChannels[swfName] ??= {};
		_soundChannels[swfName][soundID] ??= <GAFSoundChannel>[];
		_soundChannels[swfName][soundID].add(soundData);
	}

  /// stop a sound
  ///
  /// @param soundID
  /// @param swfName

  void _stop(int soundID, String swfName) {
    if (_soundChannels.containsKey(swfName) == false) return;
    if (_soundChannels[swfName].containsKey(soundID) == false) return;
    var channels = _soundChannels[swfName].remove(soundID);
    channels.forEach((channel) => channel.stop());
  }
}
