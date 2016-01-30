part of stagexl_gaf;


class CAnimationSequences {

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

  List<CAnimationSequence> _sequences;

  Map<int, CAnimationSequence> _sequencesStartMap;
  Map<int, CAnimationSequence> _sequencesEndMap;

  //--------------------------------------------------------------------------
  //
  //  CONSTRUCTOR
  //
  //--------------------------------------------------------------------------

  CAnimationSequences() {
    _sequences = new List<CAnimationSequence>();
    _sequencesStartMap = new Map<int, CAnimationSequence>();
    _sequencesEndMap = new Map<int, CAnimationSequence>();
  }

  //--------------------------------------------------------------------------
  //
  //  PUBLIC METHODS
  //
  //--------------------------------------------------------------------------

  void addSequence(CAnimationSequence sequence) {

    _sequences.add(sequence);

    if (!_sequencesStartMap.containsKey(sequence.startFrameNo)) {
      _sequencesStartMap[sequence.startFrameNo] = sequence;
    }

    if (!_sequencesEndMap.containsKey(sequence.endFrameNo)) {
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
    for (CAnimationSequence sequence in this._sequences) {
      if (sequence.id == id) return sequence;
    }
    return null;
  }

  CAnimationSequence getSequenceByFrame(int frameNo) {
    for (int i = 0; i < _sequences.length; i++) {
      if (_sequences[i].isSequenceFrame(frameNo)) {
        return _sequences[i];
      }
    }
    return null;
  }

  //--------------------------------------------------------------------------
  //
  //  PRIVATE METHODS
  //
  //--------------------------------------------------------------------------

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

  List<CAnimationSequence> get sequences => _sequences;

}
