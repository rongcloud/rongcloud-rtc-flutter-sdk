import 'package:rc_rtc_flutter_example/data/constants.dart';
import 'package:rc_rtc_flutter_example/data/data.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/view.dart';
import 'package:rc_rtc_flutter_example/frame/ui/loading.dart';
import 'package:rc_rtc_flutter_example/frame/utils/extension.dart';
import 'package:rc_rtc_flutter_example/widgets/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:handy_toast/handy_toast.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'audience_page_contract.dart';
import 'audience_page_presenter.dart';

class AudiencePage extends AbstractView {
  @override
  _AudiencePageState createState() => _AudiencePageState();
}

class _AudiencePageState extends AbstractViewState<AudiencePagePresenter, AudiencePage> implements View, IRCRTCStatusReportListener {
  @override
  AudiencePagePresenter createPresenter() {
    return AudiencePagePresenter();
  }

  @override
  void init(BuildContext context) {
    super.init(context);

    var user = User.remote(ModalRoute.of(context)?.settings.arguments as String);
    _host = UserView(user);
    _host.mirror = false;

    RCRTCEngine.getInstance().registerStatusReportListener(this);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('观看直播'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.message,
              ),
              onPressed: () => _showMessagePanel(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Row(
              children: [
                Radios(
                  '音频',
                  value: AVStreamType.audio,
                  groupValue: _type,
                  onChanged: (dynamic value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
                Spacer(),
                Radios(
                  '视频',
                  value: AVStreamType.video,
                  groupValue: _type,
                  onChanged: (dynamic value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
                Spacer(),
                Radios(
                  '音视频',
                  value: AVStreamType.audio_video,
                  groupValue: _type,
                  onChanged: (dynamic value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
                Spacer(),
                Radios(
                  '小视频',
                  value: AVStreamType.video_tiny,
                  groupValue: _type,
                  onChanged: (dynamic value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
                Spacer(),
                Radios(
                  '小音视频',
                  value: AVStreamType.audio_video_tiny,
                  groupValue: _type,
                  onChanged: (dynamic value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
              ],
            ),
            Divider(
              height: 5.dp,
              color: Colors.transparent,
            ),
            Row(
              children: [
                Spacer(),
                Button(
                  '订阅',
                  callback: () => _refresh(),
                ),
                Spacer(),
              ],
            ),
            Divider(
              height: 5.dp,
              color: Colors.transparent,
            ),
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                color: Colors.blue,
                child: Stack(
                  children: [
                    _host.widget ?? Container(),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: 5.dp,
                          top: 5.dp,
                        ),
                        child: BoxFitChooser(
                          fit: _host.fit,
                          onSelected: (fit) {
                            setState(() {
                              _host.fit = fit;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 5.dp,
              color: Colors.transparent,
            ),
            Row(
              children: [
                Spacer(),
                Button(
                  _speaker ? '扬声器' : '听筒',
                  size: 15.sp,
                  callback: () => _changeSpeaker(),
                ),
                Spacer(),
              ],
            ),
            Divider(
              height: 5.dp,
              color: Colors.transparent,
            ),
            StatefulBuilder(builder: (context, setter) {
              _reportSetter = setter;
              return StatusTable(
                _report,
                role: Role.Audience,
              );
            }),
          ],
        ),
      ),
      onWillPop: () => _exit(),
    );
  }

  void _showMessagePanel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return MessagePanel(RCRTCEngine.getInstance().getRoom()!.id, false);
      },
    );
  }

  void _refresh() {
    if (_type == AVStreamType.audio) {
      _host.videoStream = null;
      setState(() {});
    }
    presenter.subscribe(_type);
  }

  void _changeSpeaker() async {
    bool result = await presenter.changeSpeaker(!_speaker);
    setState(() {
      _speaker = result;
    });
  }

  Future<bool> _exit() {
    Loading.show(context);
    presenter.exit();
    Loading.dismiss(context);
    return Future.value(true);
  }

  @override
  void onConnectionStats(StatusReport report) {
    _report = report;
    _reportSetter?.call(() {});
  }

  @override
  void onConnected() {
    'Subscribe success!'.toast();
  }

  @override
  void onAudioStreamReceived(RCRTCAudioInputStream? stream) {
    _host.audioStream = stream;
    setState(() {});
  }

  @override
  void onVideoStreamReceived(RCRTCVideoInputStream? stream) {
    _host.videoStream = stream;
    setState(() {});
  }

  @override
  void onConnectError(int? code, String? message) {
    'Subscribe error, code = $code, message = $message'.toast();
  }

  late UserView _host;
  StatusReport? _report;
  StateSetter? _reportSetter;
  AVStreamType _type = AVStreamType.audio_video;
  bool _speaker = false;
}
