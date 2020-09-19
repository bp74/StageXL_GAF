part of stagexl_gaf;

class ActionEvent extends Event {
  final String data;

  ActionEvent(String type, bool bubbles, this.data) : super(type, bubbles);
}

class SequenceEvent extends Event {
  static const String SEQUENCE_START = 'typeSequenceStart';
  static const String SEQUENCE_END = 'typeSequenceEnd';

  final CAnimationSequence sequence;

  SequenceEvent(String type, bool bubbles, this.sequence)
      : super(type, bubbles);
}
