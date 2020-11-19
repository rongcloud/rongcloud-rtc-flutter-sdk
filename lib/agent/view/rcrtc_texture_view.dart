import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../rcrtc_engine.dart';

enum RCRTCViewType {
  local,
  remote,
}

typedef TextureViewCreatedCallback(RCRTCTextureView view, int id);

class RCRTCTextureView extends StatefulWidget {
  RCRTCTextureView(
    this.callback, {
    this.boxFit = BoxFit.cover,
    this.viewType = RCRTCViewType.local,
    this.mirror = false,
  })  : assert(boxFit != null),
        assert(mirror != null),
        super(key: Key('RCRTCTextureView[${DateTime.now().microsecondsSinceEpoch}]'));

  bool mirror;
  final BoxFit boxFit;
  final RCRTCViewType viewType;
  final TextureViewCreatedCallback callback;

  _RCRTCTextureViewState _state;

  @override
  State<StatefulWidget> createState() => _createState();

  State<StatefulWidget> _createState() {
    _state = _RCRTCTextureViewState(this);
    return _state;
  }

  bool isMirror() {
    return mirror;
  }

  void setMirror(bool isMirror) {
    this.mirror = isMirror;
    _state.setMirror();
  }
}

class _RCRTCTextureViewState extends State<RCRTCTextureView> {
  int _width = 0;
  int _height = 0;
  int _rotation = 0;
  int _textureId = -1;
  StreamSubscription<dynamic> _eventSubscription;

  RCRTCTextureView _view;

  _RCRTCTextureViewState(this._view);

  void setMirror() {
    setState(() {});
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'didTextureChangeRotation':
        if (_rotation != map['rotation']) {
          setState(() {
            _rotation = map['rotation'];
            if (_rotation == 270 || _rotation == 90) {
              int temp = _height;
              _height = _width;
              _width = temp;
            } else {
              int temp = _width;
              _width = _height;
              _height = temp;
            }
          });
        }
        break;
      case 'didTextureChangeVideoSize':
        setState(() {
          _rotation = map['rotation'];
          if (_rotation == 270 || _rotation == 90) {
            _height = map['width'];
            _width = map['height'];
          } else {
            _width = map['width'];
            _height = map['height'];
          }
        });
        break;
      case 'didFirstFrameRendered':
        break;
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }

  Future<void> initialize() async {
    _textureId = await RCRTCEngine.getInstance().createVideoRenderer();
    _eventSubscription = EventChannel('rong.flutter.rtclib/VideoTextureView:$_textureId').receiveBroadcastStream().listen(eventListener, onError: errorListener);
    _view.callback(_view, _textureId);
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    RCRTCEngine.getInstance().disposeVideoRenderer(_textureId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) => _buildVideoView(constraints));
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    // FittedSizes sizes = applyBoxFit(
    //   BoxFit.contain,
    //   Size(
    //     _width,
    //     _height,
    //   ),
    //   Size(
    //     constraints.maxWidth,
    //     constraints.maxHeight,
    //   ),
    // );
    return Center(
      child: Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FittedBox(
          fit: _view.boxFit,
          child: SizedBox.fromSize(
            child: Transform(
              transform: Matrix4.identity()
                ..rotateY(
                  _view.mirror ? -pi : 0.0,
                ),
              alignment: FractionalOffset.center,
              child: Texture(textureId: _textureId),
            ),
            size: Size(_width.toDouble(), _height.toDouble()),
          ),
        ),
      ),
    );
  }
}
