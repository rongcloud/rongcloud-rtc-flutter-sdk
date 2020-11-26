import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../rcrtc_engine.dart';

typedef TextureViewCreatedCallback(RCRTCTextureView view, int id);

class RCRTCTextureView extends StatefulWidget {
  RCRTCTextureView(
    this.callback, {
    this.fit = BoxFit.cover,
    this.mirror = false,
  })  : assert(fit != null),
        assert(mirror != null),
        super(key: Key('RCRTCTextureView[${DateTime.now().microsecondsSinceEpoch}]'));

  final bool mirror;
  final BoxFit fit;
  final TextureViewCreatedCallback callback;

  @override
  State<StatefulWidget> createState() => _RCRTCTextureViewState(this);
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
        int rotation = map['rotation'];
        bool change = false;
        if (rotation == 90 || rotation == 270) {
          if (_rotation != 90 && _rotation != 270) change = true;
        } else {
          if (_rotation != 0 && _rotation != 180) change = true;
        }
        _rotation = rotation;
        if (change) {
          setState(() {
            if (_rotation == 90 || _rotation == 270) {
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
          if (_rotation == 90 || _rotation == 270) {
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => _buildVideoView(constraints),
    );
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      child: FittedBox(
        fit: _view.fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _width.toDouble(),
          height: _height.toDouble(),
          child: Transform(
            transform: Matrix4.rotationY(_view.mirror ? -pi : 0.0),
            alignment: FractionalOffset.center,
            child: Texture(textureId: _textureId),
          ),
        ),
      ),
    );
  }
}
