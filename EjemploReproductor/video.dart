import 'dart:html';

class VideoExample {
  VideoElement _videoDom;
  CanvasElement _canvasCopy;
  CanvasElement _canvasDraw;
  List<num> _offsets;
  List<num> _inertias;
  CanvasRenderingContext2D _ctxCopy, _ctxDraw;
  bool _animationRunning = false;

  final _outPadding = 100;
  final _slices = 4;

  VideoExample() {
    var inertia = -2.0;

    _videoDom = querySelector('#video-canvas-fancy');
    _canvasCopy = querySelector('#canvas-copy-fancy');
    _canvasDraw = querySelector('#canvas-draw-fancy');
    _offsets = <num>[];
    _inertias = <num>[];

    for (var i = 0; i < _slices; i++) {
      _offsets.add(0);
      _inertias.add(inertia);
      inertia += 0.4;
    }

    _videoDom.onCanPlay.listen((e) => _onCanPlay());
    _videoDom.onPlay.listen((e) => _onPlay());
    _videoDom.onPause.listen((e) => _stopAnimation());
    _videoDom.onEnded.listen((e) => _stopAnimation());
  }

  void _onCanPlay() {
    _canvasCopy.width = _canvasDraw.width = _videoDom.videoWidth;
    _canvasCopy.height = _videoDom.videoHeight;
    _canvasDraw.height = _videoDom.videoHeight + _outPadding;
    _ctxCopy = _canvasCopy.context2D;
    _ctxDraw = _canvasDraw.context2D;
  }

  void _onPlay() {
    _animationRunning = true;
    _processEffectFrame();
  }

  void _processEffectFrame() {
    if (!_animationRunning) return;
    var sliceWidth = _videoDom.videoWidth / _slices;
    _ctxCopy.drawImage(_videoDom, 0, 0);
    _ctxDraw.clearRect(0, 0, _canvasDraw.width, _canvasDraw.height);
    for (var i = 0; i < _slices; i++) {
      var sx = i * sliceWidth;
      var sy = 0;
      var sw = sliceWidth;
      var sh = _videoDom.videoHeight;
      var dx = sx;
      var dy = _offsets[i] + sy + _outPadding;
      var dw = sw;
      var dh = sh;
      _ctxDraw.drawImageScaledFromSource(_canvasCopy, sx, sy, sw, sh, dx, dy, dw, dh);
      if ((_offsets[i] + _inertias[i]).abs() < _outPadding) {
        _offsets[i] += _inertias[i];
      } else {
        _inertias[i] = -_inertias[i];
      }
    }
    window.requestAnimationFrame((double time) {
      _processEffectFrame();
      return false;
    });
  }

  void _stopAnimation() {
    _animationRunning = false;
  }
}

void main() {
  new VideoExample();
}
