part of stagexl_gaf;

class CAnimationSequences {

  final List<CAnimationSequence> _sequences;
  final Map<int, CAnimationSequence> _sequencesStartMap;
  final Map<int, CAnimationSequence> _sequencesEndMap;

  CAnimationSequences()
      : _sequences = new List<CAnimationSequence>(),
        _sequencesStartMap = new Map<int, CAnimationSequence>(),
        _sequencesEndMap = new Map<int, CAnimationSequence>();

  //--------------------------------------------------------------------------

  Iterable<CAnimationSequence> get sequences => _sequences;

  //--------------------------------------------------------------------------

  void addSequence(CAnimationSequence sequence) {
    _sequences.add(sequence);
    if (_sequencesStartMap.containsKey(sequence.startFrameNo) == false) {
      _sequencesStartMap[sequence.startFrameNo] = sequence;
    }
    if (_sequencesEndMap.containsKey(sequence.endFrameNo) == false) {
      _sequencesEndMap[sequence.endFrameNo] = sequence;
    }
  }

  CAnimationSequence getSequenceStart(int frameNo) {
    return _sequencesStartMap[frameNo];
  }

  CAnimationSequence getSequenceEnd(int frameNo) {
    return _sequencesEndMap[frameNo];
  }

  int getStartFrameNo(String sequenceID) {
    for (CAnimationSequence sequence in _sequences) {
      if (sequence.id == sequenceID) return sequence.startFrameNo;
    }
    return 0;
  }

  CAnimationSequence getSequenceByID(String id) {
    for (CAnimationSequence sequence in _sequences) {
      if (sequence.id == id) return sequence;
    }
    return null;
  }

  CAnimationSequence getSequenceByFrame(int frameNo) {
    for (CAnimationSequence sequence in _sequences) {
      if (sequence.isSequenceFrame(frameNo)) return sequence;
    }
    return null;
  }

}
