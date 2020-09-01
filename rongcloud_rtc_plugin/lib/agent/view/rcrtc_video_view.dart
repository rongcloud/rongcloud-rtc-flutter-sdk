import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../rcrtc_engine.dart';

typedef CreatedCallback(RCRTCVideoView view, String id);

enum RCRTCViewType { local, remote }

class RCRTCVideoView extends StatefulWidget {
  static const String viewTypeId = 'rong.flutter.rtclib/VideoView';
  final CreatedCallback onCreated;
  final RCRTCViewType viewType;
  final _RCRTCVideoViewState state = _RCRTCVideoViewState();
  final String streamId;

  RCRTCVideoView({@required this.onCreated, @required this.viewType, this.streamId}):super(key: Key(streamId.toString()));

  @override
  _RCRTCVideoViewState createState() => state;

  get id => state.id;
}

class _RCRTCVideoViewState extends State<RCRTCVideoView> {
  int id;

  @override
  Widget build(BuildContext context) {
    return _platformView();
  }

  Widget _platformView() {
    final Map<String, dynamic> viewMap = { "tag": widget.viewType.index };
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: RCRTCVideoView.viewTypeId,
          creationParams: viewMap,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: _onViewCreated,
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: RCRTCVideoView.viewTypeId,
          creationParams: viewMap,
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: _onViewCreated,
        );
      default:
        assert(false);
        return null;
    }
  }

  @override
  void dispose() {
    RCRTCEngine.getInstance().releaseVideoView(id);
    super.dispose();
  }

  void _onViewCreated(int id) {
    this.id = id;
    if (widget.onCreated != null) {
      widget.onCreated(widget, widget.streamId);
    }
  }
}
