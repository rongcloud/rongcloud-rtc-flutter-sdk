import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/global_config.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:FlutterRTC/widgets/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:handy_toast/handy_toast.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'connect_page_contract.dart';
import 'connect_page_presenter.dart';

class ConnectPage extends AbstractView {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends AbstractViewState<ConnectPagePresenter, ConnectPage> implements View {
  @override
  ConnectPagePresenter createPresenter() {
    return ConnectPagePresenter();
  }

  @override
  void dispose() {
    if (_connected) _disconnect();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'RTC Flutter Demo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outlined,
            ),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20.dp),
        child: Column(
          children: [
            InputBox(
              hint: 'Input a user name.',
              controller: _userInputController,
            ),
            Divider(
              height: 15.dp,
              color: Colors.transparent,
            ),
            Row(
              children: [
                Spacer(),
                Button(
                  _connected ? '断开链接' : '链接',
                  callback: () => _connected ? _disconnect() : _connect(),
                ),
                Spacer(),
              ],
            ),
            _connected
                ? Container(
                    padding: EdgeInsets.only(top: 20.dp),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Radios(
                              '会议模式',
                              value: Mode.Meeting,
                              groupValue: _mode,
                              onChanged: (value) {
                                _inputController.text = '';
                                setState(() {
                                  _mode = value;
                                });
                              },
                            ),
                            Spacer(),
                            Radios(
                              '主播模式',
                              value: Mode.Host,
                              groupValue: _mode,
                              onChanged: (value) {
                                _inputController.text = '';
                                setState(() {
                                  _mode = value;
                                });
                              },
                            ),
                            Spacer(),
                            Radios(
                              '观众模式',
                              value: Mode.Audience,
                              groupValue: _mode,
                              onChanged: (value) {
                                _inputController.text = '';
                                setState(() {
                                  _mode = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Divider(
                          height: 15.dp,
                          color: Colors.transparent,
                        ),
                        _buildArea(context),
                        Divider(
                          height: 15.dp,
                          color: Colors.transparent,
                        ),
                        _mode != Mode.Audience
                            ? CheckBoxes(
                                '开启大小流',
                                checked: _config.enableTinyStream,
                                onChanged: (checked) {
                                  setState(() {
                                    _config.enableTinyStream = checked;
                                  });
                                },
                              )
                            : Container(),
                        _mode != Mode.Audience
                            ? Divider(
                                height: 15.dp,
                                color: Colors.transparent,
                              )
                            : Container(),
                        Row(
                          children: [
                            Spacer(),
                            Button(
                              _getAction(),
                              callback: _action,
                            ),
                            Spacer(),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    String info = '默认参数: \n'
        'App Key:${GlobalConfig.appKey}\n'
        'Nav Server:${GlobalConfig.navServer}\n'
        'File Server:${GlobalConfig.fileServer}\n'
        'Media Server:${GlobalConfig.mediaServer.isEmpty ? '自动获取' : GlobalConfig.mediaServer}\n';
    if (_connected)
      info += '当前使用: \n'
          'App Key:${DefaultData.user.key}\n'
          'Nav Server:${DefaultData.user.navigate}\n'
          'File Server:${DefaultData.user.file}\n'
          'Media Server:${DefaultData.user.media.isEmpty ? '自动获取' : DefaultData.user.media}\n';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('默认配置'),
          content: SelectableText(
            info,
          ),
          actions: [
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _disconnect() {
    presenter?.disconnect();
    setState(() {
      _connected = false;
    });
  }

  void _connect() {
    FocusScope.of(context).requestFocus(FocusNode());

    String name = _userInputController.text;

    if (name.isEmpty) return 'User Name Should not be null!'.toast();

    Loading.show(context);
    presenter?.login(name);
  }

  String _getHint() {
    switch (_mode) {
      case Mode.Meeting:
        return 'Meeting id';
      case Mode.Host:
        return 'Room id';
      case Mode.Audience:
        return 'Room id';
    }
    return '???';
  }

  Widget _buildArea(BuildContext context) {
    switch (_mode) {
      case Mode.Meeting:
        return InputBox(
          hint: '${_getHint()}.',
          controller: _inputController,
        );
      case Mode.Host:
        return Column(
          children: [
            InputBox(
              hint: '${_getHint()}.',
              controller: _inputController,
            ),
            Divider(
              height: 10.dp,
              color: Colors.transparent,
            ),
            Row(
              children: [
                Spacer(),
                Radios(
                  '音视频模式',
                  value: RCRTCLiveType.AudioVideo,
                  groupValue: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
                Spacer(),
                Radios(
                  '音频模式',
                  value: RCRTCLiveType.Audio,
                  groupValue: _type,
                  onChanged: (value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
                Spacer(),
              ],
            ),
          ],
        );
      case Mode.Audience:
        return Row(
          children: [
            Expanded(
              child: InputBox(
                hint: '${_getHint()}.',
                controller: _inputController,
              ),
            ),
            // VerticalDivider(
            //   width: 10.dp,
            //   color: Colors.transparent,
            // ),
            // Button(
            //   '获取',
            //   callback: () => _showUrl(context),
            // ),
          ],
        );
    }
    return Container();
  }

  // void _showUrl(BuildContext context) {
  //   TextEditingController controller = TextEditingController();
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('获取URL'),
  //         content: InputBox(
  //           hint: 'Room ID.',
  //           controller: controller,
  //         ),
  //         actions: [
  //           FlatButton(
  //             child: Text('Ok'),
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _url(context, controller.text);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _url(BuildContext context, String id) async {
  //   Loading.show(context);
  //   Result result = await presenter?.url(id);
  //   if (result.code != 0)
  //     result.content.toast();
  //   else
  //     _inputController.text = result.content;
  //   Loading.dismiss(context);
  // }

  String _getAction() {
    switch (_mode) {
      case Mode.Meeting:
        return '加入会议';
      case Mode.Host:
        return '开始直播';
      case Mode.Audience:
        return '观看直播';
    }
    return '???';
  }

  void _action() {
    String info = _inputController.text;
    if (info.isEmpty) return '${_getHint()} should not be null!'.toast();
    Loading.show(context);
    RCRTCLiveType type = _mode == Mode.Host ? _type : RCRTCLiveType.AudioVideo;
    if (_mode != Mode.Audience) RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) => stream.enableTinyStream(_config.enableTinyStream));
    presenter?.action(info, _mode, type);
  }

  @override
  void onConnected(String id) {
    Loading.dismiss(context);
    'IM Connected.'.toast();
    setState(() {
      _connected = true;
    });
  }

  @override
  void onConnectError(int code, String id) {
    Loading.dismiss(context);
    'IM Connect Error, code = $code'.toast();
    setState(() {
      _connected = false;
    });
  }

  void onDone(String info) {
    Loading.dismiss(context);
    switch (_mode) {
      case Mode.Meeting:
        _toMeeting();
        break;
      case Mode.Host:
        _toHost();
        break;
      case Mode.Audience:
        _toAudience(info);
        break;
    }
  }

  void _toMeeting() {
    Navigator.pushNamed(
      context,
      RouterManager.MEETING,
      arguments: _config.toJson(),
    );
  }

  void _toHost() {
    Navigator.pushNamed(
      context,
      RouterManager.HOST,
      arguments: _config.toJson(),
    );
  }

  void _toAudience(String url) {
    Navigator.pushNamed(
      context,
      RouterManager.AUDIENCE,
      arguments: url,
    );
  }

  void onError(int code, String info) {
    Loading.dismiss(context);
    '${_getAction()}失败, Code = $code, Info = $info'.toast();
  }

  TextEditingController _userInputController = TextEditingController();
  TextEditingController _inputController = TextEditingController();

  bool _connected = false;
  Mode _mode = Mode.Meeting;
  RCRTCLiveType _type = RCRTCLiveType.AudioVideo;

  Config _config = Config.config();
}
