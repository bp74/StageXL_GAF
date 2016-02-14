part of stagexl_gaf;

class CAnimationFrames {

  final List<CAnimationFrame> _frames = new List<CAnimationFrame>();

  //---------------------------------------------------------------------------

  List<CAnimationFrame> get all => _frames;

  //---------------------------------------------------------------------------

  void addFrame(CAnimationFrame frame) {
    _frames.add(frame);
  }

  CAnimationFrame getFrame(int frameNumber) {
    for (var frame in _frames) {
      if (frame.frameNumber == frameNumber) return frame;
    }
    return null;
  }

}
