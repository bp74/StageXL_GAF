part of stagexl_gaf;

class CAnimationFrames {

  final List<CAnimationFrame> frames  = new List<CAnimationFrame>();

  //---------------------------------------------------------------------------

  void addFrame(CAnimationFrame frame) {
    frames.add(frame);
  }

  CAnimationFrame getFrame(int frameNumber) {
    for (var frame in frames) {
      if (frame.frameNumber == frameNumber) return frame;
    }
    return null;
  }

}
