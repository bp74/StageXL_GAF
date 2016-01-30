part of stagexl_gaf;

class GAFSoundChannel extends EventDispatcher {

  final String swfName;
  final int soundID;

  SoundChannel _soundChannel;
  EventStreamSubscription<Event> _subscription;

  GAFSoundChannel(this.swfName, this.soundID);

  //---------------------------------------------------------------------------

  SoundChannel get soundChannel => _soundChannel;

  set soundChannel(SoundChannel soundChannel) {
    _subscription?.cancel();
    _soundChannel = soundChannel;
    _subscription = soundChannel.onComplete.listen(this.dispatchEvent);
  }

  void stop() {
    _soundChannel?.stop();
  }
}
