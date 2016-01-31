part of stagexl_gaf;

class CAnimationSequence {

  final String id;
  final int startFrameNo;
  final int endFrameNo;

  // first frame is "1" !!!

  CAnimationSequence(this.id, this.startFrameNo, this.endFrameNo);

  //--------------------------------------------------------------------------

  bool isSequenceFrame(int frameNo) {
    return frameNo >= startFrameNo && frameNo <= endFrameNo;
  }

}
