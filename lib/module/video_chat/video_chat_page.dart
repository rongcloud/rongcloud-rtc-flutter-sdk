import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/module/video_chat/video_chat_page_contract.dart';
import 'package:FlutterRTC/module/video_chat/video_chat_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'video_chat_settings.dart';
import 'video_chat_widgets.dart';

class VideoChatPage extends AbstractView {
  final bool _debug = false;

  VideoChatPage();

  @override
  State<StatefulWidget> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends AbstractViewState<Presenter, VideoChatPage> with WidgetsBindingObserver implements View {
  static const String _tag = '_VideoPageState';
  StreamConfig _streamConfig = StreamConfig();
  FunctionConfig _functionConfig = FunctionConfig();
  RCRTCRoom _room;
  RCRTCLocalUser _localUser;

  RCRTCVideoStreamConfig _defaultVideoStreamConfig;
  List<MemberItemView> _userViewList = List();
  List<RCRTCStream> _streamsOnSmallScreen = [];
  RCRTCStream _streamOnFullScreen;
  bool _hideSettingsPanel = false;

  _VideoChatPageState() {
    _room = RCRTCEngine.getInstance().room;
    _localUser = _room.localUser;
    _userViewList.add(MemberItemView(_localUser));
  }

  @override
  void initState() {
    super.initState();
    RCRTCLog.d(_tag, 'initState');
    _setRoomEventListener();
    _defaultVideoStreamConfig =
        RCRTCVideoStreamConfig(300, 1000, RCRTCFps.fps_30, RCRTCVideoResolution.RESOLUTION_720_1280);
    if (!widget._debug) {
      _streamConfig.audioVideo = true;
      _handleAudioVideoStreamChanged();
      for (var remoteUser in _room.remoteUserList) {
        RCRTCLog.d(_tag, 'subscribeAVStream userId = ${remoteUser.id}');
        _localUser.subscribeStreams(remoteUser.streamList).then((code) {
          RCRTCLog.d(_tag, 'subscribeAVStream, code = $code');
          if (code != 0) return;
          setState(() => remoteUser.streamList.whereType<RCRTCVideoInputStream>().forEach(_firstDisplay));
        });
      }
      _appearRemoteListItem(_room.remoteUserList);
    }
    _handleSpeakerChanged(_functionConfig.speakerEnable);
  }

  @override
  Widget buildWidget(BuildContext context) {
    ScreenUtil.init(context, width: 375, height: 667);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(child: _fullScreenVideoView()),
              SizedBox(height: ScreenUtil().setWidth(90)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
//              SizedBox(
//                height: ScreenUtil().setHeight(90),
              Row(
                children: _smallScreenVideoView(),
              ),
              Offstage(
                offstage: _hideSettingsPanel,
                child: VideoSettingsPanel(
                  streamConfig: _streamConfig,
                  functionConfig: _functionConfig,
                  onStreamChanged: (index) {
                    switch (index) {
                      case StreamConfig.AudioVideo:
                        _handleAudioVideoStreamChanged();
                        break;
                      case StreamConfig.Audio:
                        _handleAudioStreamChanged();
                        break;
                      case StreamConfig.Video:
                        _handleVideoStreamChanged();
                        break;
                      default:
                        assert(false);
                    }
                  },
                  onResolutionChanged: (index) {
                    RCRTCVideoResolution resolution = index;
                    switch (index) {
                      case RCRTCVideoResolution.RESOLUTION_240_320:
                        break;
                      case RCRTCVideoResolution.RESOLUTION_480_640:
                        break;
                      case RCRTCVideoResolution.RESOLUTION_720_1280:
                        break;
//                      case RCRTCVideoResolution.RESOLUTION_1280_1920:
//                        break;
                      default:
                        assert(false);
                    }
                    _handleResolutionChanged(resolution);
                  },
                  onSpeakerChanged: (value) => _handleSpeakerChanged(value),
                ),
              ),
              VideoCoreButtonPanel(
                onSettingsPressed: () {
//                  setState(() => _hideSettingsPanel = !_hideSettingsPanel);
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
//                        height: ScreenUtil().setHeight(300),
                        child: ListView.separated(
                          itemCount: _userViewList.length,
                          itemBuilder: (context, index) => _userViewList[index],
                          separatorBuilder: (BuildContext context, int index) => Divider(height: 0),
                        ),
                      );
                    },
                  );
                },
                onHangUpPressed: () {
                  RCRTCEngine.getInstance().leaveRoom().then((value) {
                    Navigator.pop(context);
                  });
                },
                onSwitchCameraPressed: () {
                  RCRTCEngine.getInstance().defaultVideoStream.then((video) => video.switchCamera());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  _appearRemoteListItem(List<RCRTCRemoteUser> users) {
    setState(() {
      users.forEach((user) {
        var listItem = MemberItemView(user);
        _userViewList.add(listItem);
      });
    });
  }

  _disappearRemoteListItem(RCRTCRemoteUser user) {
    setState(() {
      _userViewList.removeWhere((element) => element.user.id == user.id);
    });
  }

  Widget _fullScreenVideoView() {
    if (_streamOnFullScreen == null) {
      return Container(color: Colors.grey);
    } else {
      return RCRTCVideoView(
        streamId: _streamOnFullScreen.streamId,
        viewType: _videoViewTypeOf(_streamOnFullScreen),
        onCreated: (view, id) => _setViewToStream(view, id, _streamOnFullScreen),
      );
    }
  }

  List<Widget> _smallScreenVideoView() {
    return _streamsOnSmallScreen.map((stream) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            VideoMinorView(
              RCRTCVideoView(
                streamId: stream.streamId,
                onCreated: (view, id) => _setViewToStream(view, id, stream),
                viewType: _videoViewTypeOf(stream),
              ),
            ),
            Positioned(
              top: 0,
              child: Text("Id:${_getUserIdByStreamId(stream.streamId)}"),
            )
          ],
        ),

        /*
          VideoMinorView(
          RCRTCVideoView(
            streamId: stream.streamId,
            onCreated: (view, id) => _setViewToStream(view, stream),
            viewType: _videoViewTypeOf(stream),
          ),
        ),*/

        onTap: () => _switchToFullScreen(stream),
      );
    }).toList();
  }

  RCRTCViewType _videoViewTypeOf(RCRTCStream stream) {
    return stream is RCRTCCameraOutputStream ? RCRTCViewType.local : RCRTCViewType.remote;
  }

  _setViewToStream(RCRTCVideoView view, int id, RCRTCStream stream) {
    if (stream is RCRTCVideoOutputStream) {
      stream.setVideoView(view, id);
    } else if (stream is RCRTCVideoInputStream) {
      stream.setVideoView(view, id);
    }
  }

  _firstDisplay(RCRTCStream stream) {
    if (_streamOnFullScreen == null) {
      _streamOnFullScreen = stream;
    } else {
      _streamsOnSmallScreen.add(stream);
      _switchToTinyStream(stream);
    }
  }

  /// should be called only when small window clicked.
  _switchToFullScreen(RCRTCStream stream) {
    setState(() {
      _switchToTinyStream(_streamOnFullScreen);
      var index = _streamsOnSmallScreen.indexOf(stream);
      if (index >= 0) {
        _streamsOnSmallScreen[index] = _streamOnFullScreen;
        _streamOnFullScreen = stream;
        _switchToNormalStream(stream);
      } else {
        // unexpectedly case.
      }
    });
  }

  _switchToTinyStream(RCRTCStream stream) {
    if (stream is RCRTCVideoInputStream && stream.streamTag == RCRTCStream.rongTag) {
      _room.remoteUserList.firstWhere((user) => user.streamList.contains(stream))?.switchToTinyStream();
    }
  }

  _switchToNormalStream(RCRTCStream stream) {
    if (stream is RCRTCVideoInputStream && stream.streamTag == RCRTCStream.rongTag) {
      _room.remoteUserList.firstWhere((user) => user.streamList.contains(stream))?.switchToNormalStream();
    }
  }

  _dismissOnWindow(RCRTCStream stream) {
    setState(() {
      if (_streamOnFullScreen == stream) {
        _streamOnFullScreen = _streamsOnSmallScreen.removeLast();
        _switchToNormalStream(_streamOnFullScreen);
      } else {
        _streamsOnSmallScreen.remove(stream);
      }
    });
  }

  void _setRoomEventListener() {
    _room.onRemoteUserJoined = (RCRTCRemoteUser remoteUser) {
      RCRTCLog.d(_tag, " onRemoteUserJoined $remoteUser");
      _appearRemoteListItem([remoteUser]);
    };

    _room.onRemoteUserLeft = (RCRTCRemoteUser remoteUser) {
      RCRTCLog.d(_tag, 'onRemoteUserUnpublishResource');
      setState(() => remoteUser.streamList.forEach(_dismissOnWindow));
      _disappearRemoteListItem(remoteUser);
    };

    _room.onRemoteUserPublishResource = (RCRTCRemoteUser remoteUser, List<RCRTCInputStream> streamList) {
      RCRTCLog.d(_tag, 'onRemoteUserPublishResource');
      _localUser.subscribeStreams(streamList).then((code) {
        RCRTCLog.d(_tag, 'subscribeAVStream, code = $code');
        if (code != 0) return;
        setState(() => streamList.whereType<RCRTCVideoInputStream>().forEach(_firstDisplay));
      });
      // TODO: (wangjingbiao): 更新用户列表
//      _appearRemoteListItem([remoteUser]);
    };

    _room.onRemoteUserUnpublishResource = (RCRTCRemoteUser remoteUser, var streamList) {
      RCRTCLog.d(_tag, 'onRemoteUserUnpublishResource');
      setState(() => streamList.forEach(_dismissOnWindow));
      // TODO: (wangjingbiao):跟新list列表
    };
  }

  _handleAudioVideoStreamChanged() {
    if (_streamConfig.audioVideo) {
      RCRTCEngine.getInstance().defaultVideoStream.then((camera) {
        RCRTCLog.d(_tag, 'renderView localView');
        camera.setVideoConfig(_defaultVideoStreamConfig);
        camera.startCamera();
        RCRTCLog.d(_tag, 'publishDefaultAVStream');
        _localUser.publishDefaultStreams().then((code) {
          RCRTCLog.d(_tag, 'publishDefaultAVStream, code = $code');
          setState(() => _firstDisplay(camera));
        });
      });
    } else {
      RCRTCEngine.getInstance().defaultVideoStream.then((stream) {
        stream?.stopCamera();
        setState(() => _dismissOnWindow(stream));
      });
      _localUser.unpublishDefaultStreams();
    }
  }

  _handleAudioStreamChanged() {
    RCRTCEngine.getInstance().defaultAudioStream.then((value) {
      _streamConfig.audio ? _localUser.publishStreams([value]) : _localUser.unPublishStreams([value]);
    });
  }

  _handleVideoStreamChanged() {
    if (_streamConfig.video) {
      RCRTCEngine.getInstance().defaultVideoStream.then((stream) {
        stream.startCamera();
        stream.setVideoConfig(_defaultVideoStreamConfig);
        setState(() => _firstDisplay(stream));
        _localUser.publishStreams([stream]);
      });
    } else {
      RCRTCEngine.getInstance().defaultVideoStream.then((stream) {
        stream.stopCamera();
        setState(() => _dismissOnWindow(stream));
        _localUser.unPublishStreams([stream]);
      });
    }
  }

  _handleSpeakerChanged(bool enable) {
    RCRTCEngine.getInstance().enableSpeaker(enable);
  }

  _handleResolutionChanged(RCRTCVideoResolution selectedResolution) {
    RCRTCEngine.getInstance().defaultVideoStream.then((value) {
      _defaultVideoStreamConfig?.resolution = selectedResolution;
      value.setVideoConfig(_defaultVideoStreamConfig);
    });
  }

  String _getUserIdByStreamId(String streamId) {
    Iterator<RCRTCRemoteUser> i = _room.remoteUserList.iterator;
    while (i.moveNext()) {
      RCRTCRemoteUser remoteUser = i.current;
      Iterator<RCRTCStream> iStream = remoteUser.streamList.iterator;
      while (iStream.moveNext()) {
        RCRTCStream stream = iStream.current;
        if (stream.streamId == streamId && stream.type == MediaType.video) {
          return remoteUser.id;
        }
      }
    }

    for (var stream in _localUser.streamList) {
      if (stream.streamId == streamId && stream.type == MediaType.video) {
        return _localUser.id;
      }
    }

    return "";
  }

  @override
  Presenter createPresenter() {
    return VideoChatPagePresenter();
  }
}
