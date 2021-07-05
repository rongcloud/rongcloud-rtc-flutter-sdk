import 'dart:async';
import 'dart:convert';

import 'package:rc_rtc_flutter_example/data/constants.dart';
import 'package:rc_rtc_flutter_example/data/data.dart';
import 'package:rc_rtc_flutter_example/frame/network/network.dart';
import 'package:rc_rtc_flutter_example/frame/ui/loading.dart';
import 'package:rc_rtc_flutter_example/frame/utils/extension.dart';
import 'package:rc_rtc_flutter_example/global_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handy_toast/handy_toast.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class InputBox extends StatelessWidget {
  InputBox({
    required this.hint,
    required this.controller,
    this.type,
    this.size,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.dp),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type ?? TextInputType.text,
        textInputAction: TextInputAction.done,
        style: TextStyle(
          fontSize: size as double? ?? 20.sp,
          color: Colors.black,
          decoration: TextDecoration.none,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: size as double? ?? 20.sp,
            color: Colors.black.withOpacity(0.7),
            decoration: TextDecoration.none,
          ),
          contentPadding: EdgeInsets.only(
            top: 2.dp,
            bottom: 0.dp,
            left: 10.dp,
            right: 10.dp,
          ),
          isDense: true,
        ),
        inputFormatters: formatter,
      ),
    );
  }

  final String hint;
  final TextEditingController controller;
  final TextInputType? type;
  final num? size;
  final List<TextInputFormatter>? formatter;
}

class Button extends StatelessWidget {
  Button(
    this.text, {
    this.size,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.dp),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: size as double? ?? 20.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      onTap: callback,
    );
  }

  final String text;
  final num? size;
  final void Function()? callback;
}

class Radios<T> extends StatelessWidget {
  Radios(
    this.text, {
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            value == groupValue ? Icons.radio_button_on : Icons.radio_button_off,
            color: Colors.blue,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
      onTap: () => onChanged(value),
    );
  }

  final String text;
  final T value;
  final T groupValue;
  final void Function(T value) onChanged;
}

class CheckBoxes extends StatelessWidget {
  CheckBoxes(
    this.text, {
    this.enable = true,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            enable && checked ? Icons.check_box : Icons.check_box_outline_blank,
            color: enable ? Colors.blue : Colors.grey,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              color: enable ? Colors.black : Colors.grey,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
      onTap: () => enable ? onChanged(!checked) : null,
    );
  }

  final String text;
  final bool enable;
  final bool checked;
  final void Function(bool checked) onChanged;
}

extension IconExtension on IconData {
  Widget onClick(void Function() onClick) {
    return GestureDetector(
      child: Icon(this),
      onTap: onClick,
    );
  }
}

extension StringExtension on String {
  Widget toText({
    Color color = Colors.black,
  }) {
    return Text(
      this,
      style: TextStyle(
        fontSize: 15.sp,
        color: color,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget onClick(
    void Function() onClick, {
    Color color = Colors.white,
  }) {
    return GestureDetector(
      child: Text(
        this,
        style: TextStyle(
          fontSize: 15.sp,
          color: color,
          decoration: TextDecoration.none,
        ),
      ),
      onTap: onClick,
    );
  }
}

class UserView {
  UserView(this.user);

  Widget? get widget {
    if (_build) {
      _build = false;
      _widget = _videoStream != null
          ? RCRTCTextureView(
              (videoView, id) {
                _videoStream.setTextureView(id);
              },
              fit: _fit,
              mirror: _mirror,
            )
          : null;
    }
    return _widget;
  }

  bool get self {
    return user.id == DefaultData.user?.id;
  }

  bool get audio => _audio;

  set audioStream(dynamic stream) {
    assert(stream == null || stream is RCRTCAudioInputStream || stream is RCRTCAudioOutputStream, 'unsupported stream type ${stream.runtimeType}!');
    _audioStream = stream;
    if (stream != null && stream is RCRTCAudioInputStream) _remoteAudioStream = stream;
    _audio = _audioStream != null;
    invalidate();
  }

  RCRTCAudioInputStream? get audioStream => _remoteAudioStream;

  bool get video => _video;

  set videoStream(dynamic stream) {
    assert(stream == null || stream is RCRTCVideoInputStream || stream is RCRTCVideoOutputStream, 'unsupported stream type ${stream.runtimeType}!');
    _videoStream = stream;
    if (stream != null && stream is RCRTCVideoInputStream) _remoteVideoStream = stream;
    _video = _videoStream != null;
    invalidate();
  }

  RCRTCVideoInputStream? get videoStream => _remoteVideoStream;

  BoxFit get fit => _fit;

  set fit(BoxFit fit) {
    _fit = fit;
    invalidate();
  }

  bool get mirror => _mirror;

  set mirror(bool mirror) {
    _mirror = mirror;
    invalidate();
  }

  void invalidate() {
    _build = true;
  }

  bool _build = true;

  BoxFit _fit = BoxFit.contain;
  bool _mirror = true;

  final User user;

  dynamic _audioStream;
  RCRTCAudioInputStream? _remoteAudioStream;
  bool _audio = false;

  dynamic _videoStream;
  RCRTCVideoInputStream? _remoteVideoStream;
  bool _video = false;

  Widget? _widget;
}

class StatusTable extends StatelessWidget {
  StatusTable(
    this.report, {
    required this.role,
    this.audio,
    this.video,
  });

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case Role.Local:
        return _buildLocal(context);
      case Role.Remote:
        return _buildRemote(context);
      case Role.Audience:
      default:
        return _buildAudience(context);
    }
  }

  Widget _buildLocal(BuildContext context) {
    List<TableRow> rows = [];

    rows.add(TableRow(
      children: [
        Text(
          '网络类型:\n${report?.networkType ?? 'Unknown'}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          'IP:${report?.ipAddress ?? 'Unknown'}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ));
    rows.add(TableRow(
      children: [
        Text(
          '上行:\n${report?.bitRateSend ?? '-- '}kbps',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '下行:\n${report?.bitRateRcv ?? '-- '}kbps',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '往返:\n${report?.rtt ?? '-- '}ms',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ));

    if (report?.statusVideoSends.isNotEmpty ?? false) {
      report?.statusVideoSends.forEach((stream, status) {
        rows.add(TableRow(
          children: [
            Text(
              '${(status.id.endsWith('tiny') || status.id.endsWith('tiny_video')) ? '小流' : '大流'}\n${status.bitRate}kbps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${status.frameWidth}x${status.frameHeight}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${status.frameRate}fps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '丢包率:${status.packetLostRate}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ));
      });
    }

    if (report?.statusAudioSends.isNotEmpty ?? false) {
      report?.statusAudioSends.forEach((stream, status) {
        rows.add(TableRow(
          children: [
            Text(
              '音频\n${status.bitRate}kbps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '丢包率:${status.packetLostRate}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ));
      });
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
        color: Colors.grey,
        width: 1,
        style: BorderStyle.solid,
      ),
      children: rows,
    );
  }

  Widget _buildRemote(BuildContext context) {
    StatusBean? audio = getAudioStatus();
    StatusBean? video = getVideoStatus();
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      textDirection: TextDirection.ltr,
      border: TableBorder.all(
        color: Colors.grey,
        width: 1,
        style: BorderStyle.solid,
      ),
      children: [
        TableRow(
          children: [
            Text(
              '视频码率',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${video?.bitRate ?? '-- '}kbps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              '视频帧率',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${video?.frameRate ?? '-- '}fps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              '视频分辨率',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${video != null ? '${video.frameWidth}x${video.frameHeight}' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              '视频丢包率',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${video?.packetLostRate ?? '-- '}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              '音频码率',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${audio?.bitRate ?? '-- '}kbps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              '音频丢包率',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${audio?.packetLostRate ?? '-- '}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ],
    );
  }

  StatusBean? getAudioStatus() {
    if ((audio?.isNotEmpty ?? false) && (report?.statusAudioRcvs.containsKey(audio) ?? false)) {
      return report?.statusAudioRcvs[audio];
    }
    return null;
  }

  StatusBean? getVideoStatus() {
    if ((video?.isNotEmpty ?? false) && (report?.statusVideoRcvs.containsKey(video) ?? false)) {
      return report?.statusVideoRcvs[video];
    }
    return null;
  }

  Widget _buildAudience(BuildContext context) {
    List<TableRow> rows = [];

    rows.add(TableRow(
      children: [
        Text(
          '网络类型:\n${report?.networkType ?? 'Unknown'}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          'IP:${report?.ipAddress ?? 'Unknown'}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ));
    rows.add(TableRow(
      children: [
        Text(
          '上行:\n${report?.bitRateSend ?? '-- '}kbps',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '下行:\n${report?.bitRateRcv ?? '-- '}kbps',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '往返:\n${report?.rtt ?? '-- '}ms',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ));

    if (report?.statusVideoRcvs.isNotEmpty ?? false) {
      report?.statusVideoRcvs.forEach((stream, status) {
        rows.add(TableRow(
          children: [
            Text(
              '视频\n${status.bitRate}kbps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${status.frameWidth}x${status.frameHeight}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '${status.frameRate}fps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '丢包率:${status.packetLostRate}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ));
      });
    }

    if (report?.statusAudioRcvs.isNotEmpty ?? false) {
      report?.statusAudioRcvs.forEach((stream, status) {
        rows.add(TableRow(
          children: [
            Text(
              '音频\n${status.bitRate}kbps',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              '丢包率:${status.packetLostRate}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ));
      });
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(
        color: Colors.grey,
        width: 1,
        style: BorderStyle.solid,
      ),
      children: rows,
    );
  }

  final StatusReport? report;
  final Role role;
  final String? video, audio;
}

class MixConfig extends StatefulWidget {
  MixConfig({
    required this.callback,
  });

  @override
  _MixConfigState createState() => _MixConfigState(this);

  final RCRTCMixConfig config = RCRTCMixConfig();
  final Callback callback;
}

class _MixConfigState extends State<MixConfig> {
  _MixConfigState(this.widget) {
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('自定义布局'),
      ),
      body: Column(
        children: [
          Divider(
            height: 20.dp,
            color: Colors.transparent,
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10.dp),
              children: [
                Row(
                  children: [
                    Spacer(),
                    Radios(
                      '自定义',
                      value: MixLayoutMode.CUSTOM,
                      groupValue: widget.config.mode,
                      onChanged: (dynamic mode) {
                        setState(() {
                          widget.config.mode = mode;
                        });
                      },
                    ),
                    Spacer(),
                    Radios(
                      '悬浮',
                      value: MixLayoutMode.SUSPENSION,
                      groupValue: widget.config.mode,
                      onChanged: (dynamic mode) {
                        setState(() {
                          widget.config.mode = mode;
                        });
                      },
                    ),
                    Spacer(),
                    Radios(
                      '自适应',
                      value: MixLayoutMode.ADAPTIVE,
                      groupValue: widget.config.mode,
                      onChanged: (dynamic mode) {
                        setState(() {
                          widget.config.mode = mode;
                        });
                      },
                    ),
                    Spacer(),
                  ],
                ),
                Divider(
                  height: 10.dp,
                  color: Colors.transparent,
                ),
                Row(
                  children: [
                    '主位置用户ID:'.toText(),
                    VerticalDivider(
                      width: 5.dp,
                      color: Colors.transparent,
                    ),
                    Expanded(
                      child: InputBox(
                        hint: '请输入有效信息',
                        controller: _mainUserIdInputController,
                        size: 15.sp,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 10.dp,
                  color: Colors.transparent,
                ),
                Row(
                  children: [
                    '主位置视频流ID:'.toText(),
                    VerticalDivider(
                      width: 5.dp,
                      color: Colors.transparent,
                    ),
                    Expanded(
                      child: InputBox(
                        hint: '请输入有效信息',
                        controller: _mainStreamIdInputController,
                        size: 15.sp,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 10.dp,
                  color: Colors.transparent,
                ),
                _buildVideoConfig(context),
                Button(
                  '视频设置',
                  callback: () {
                    _showSetVideoConfig(context);
                  },
                ),
                Divider(
                  height: 10.dp,
                  color: Colors.transparent,
                ),
                _buildTinyVideoConfig(context),
                Button(
                  '小视频设置',
                  callback: () {
                    _showSetTinyVideoConfig(context);
                  },
                ),
                Divider(
                  height: 10.dp,
                  color: Colors.transparent,
                ),
                _buildAudioConfig(context),
                Button(
                  '音频设置',
                  callback: () {
                    _showSetAudioConfig(context);
                  },
                ),
                Divider(
                  height: 10.dp,
                  color: Colors.transparent,
                ),
                _buildVideoExtendConfig(context),
                Button(
                  '视频额外设置',
                  callback: () {
                    _showSetVideoExtendConfig(context);
                  },
                ),
                Divider(
                  height: 10.dp,
                  color: Colors.transparent,
                ),
                widget.config.mode == MixLayoutMode.CUSTOM ? _buildCustoms(context) : Container(),
              ],
            ),
          ),
          Divider(
            height: 20.dp,
            color: Colors.transparent,
          ),
          Row(
            children: [
              Spacer(),
              Button(
                '提交',
                callback: () => _ok(),
              ),
              VerticalDivider(
                width: 20.dp,
                color: Colors.transparent,
              ),
              Button(
                '重置',
                callback: () => _reset(),
              ),
              Spacer(),
            ],
          ),
          Divider(
            height: 20.dp,
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoConfig(BuildContext context) {
    VideoLayout? layout = widget.config.mediaConfig?.videoConfig?.videoLayout;
    if (layout != null) {
      return Row(
        children: [
          Text(
            '码率: ${layout.bitrate}, 帧率: ${layout.fps}\n'
            'width: ${layout.width}, height: ${layout.height}\n',
            softWrap: true,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          VerticalDivider(
            width: 10.dp,
            color: Colors.transparent,
          ),
          Icons.clear.onClick(() {
            setState(() {
              widget.config.mediaConfig?.videoConfig?.videoLayout = null;
              _mediaConfigNullable();
            });
          }),
        ],
      );
    }
    return Container();
  }

  void _showSetVideoConfig(BuildContext context) {
    TextEditingController bitrateInputController = TextEditingController();
    TextEditingController fpsInputController = TextEditingController();
    TextEditingController widthInputController = TextEditingController();
    TextEditingController heightInputController = TextEditingController();

    VideoLayout? layout = widget.config.mediaConfig?.videoConfig?.videoLayout;
    bitrateInputController.text = '${layout?.bitrate ?? 3000}';
    fpsInputController.text = '${layout?.fps ?? 30}';
    widthInputController.text = '${layout?.width ?? 720}';
    heightInputController.text = '${layout?.height ?? 1280}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('视频配置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  '码率:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: bitrateInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '帧率:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: fpsInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '视频宽度:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: widthInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '视频高度:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: heightInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                String bitrate = bitrateInputController.text;
                String fps = fpsInputController.text;
                String width = widthInputController.text;
                String height = heightInputController.text;
                if (bitrate.isEmpty) return 'Bitrate should not be null!'.toast();
                if (fps.isEmpty) return 'FPS should not be null!'.toast();
                if (width.isEmpty) return 'Width should not be null!'.toast();
                if (height.isEmpty) return 'Height should not be null!'.toast();
                VideoLayout layout = VideoLayout(bitrate.toInt as int, fps.toInt as int, width.toInt as int, height.toInt as int);
                if (widget.config.mediaConfig == null) widget.config.mediaConfig = MediaConfig();
                if (widget.config.mediaConfig?.videoConfig == null) widget.config.mediaConfig?.videoConfig = VideoConfig();
                setState(() {
                  widget.config.mediaConfig?.videoConfig?.videoLayout = layout;
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTinyVideoConfig(BuildContext context) {
    VideoLayout? layout = widget.config.mediaConfig?.videoConfig?.tinyVideoLayout;
    if (layout != null) {
      return Row(
        children: [
          Text(
            '码率: ${layout.bitrate}, 帧率: ${layout.fps}\n'
            'width: ${layout.width}, height: ${layout.height}\n',
            softWrap: true,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          VerticalDivider(
            width: 10.dp,
            color: Colors.transparent,
          ),
          Icons.clear.onClick(() {
            setState(() {
              widget.config.mediaConfig?.videoConfig?.tinyVideoLayout = null;
              _mediaConfigNullable();
            });
          }),
        ],
      );
    }
    return Container();
  }

  void _showSetTinyVideoConfig(BuildContext context) {
    TextEditingController bitrateInputController = TextEditingController();
    TextEditingController fpsInputController = TextEditingController();
    TextEditingController widthInputController = TextEditingController();
    TextEditingController heightInputController = TextEditingController();

    VideoLayout? layout = widget.config.mediaConfig?.videoConfig?.tinyVideoLayout;
    bitrateInputController.text = '${layout?.bitrate ?? 300}';
    fpsInputController.text = '${layout?.fps ?? 15}';
    widthInputController.text = '${layout?.width ?? 180}';
    heightInputController.text = '${layout?.height ?? 320}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('小视频配置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  '码率:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: bitrateInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '帧率:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: fpsInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '视频宽度:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: widthInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '视频高度:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: heightInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                String bitrate = bitrateInputController.text;
                String fps = fpsInputController.text;
                String width = widthInputController.text;
                String height = heightInputController.text;
                if (bitrate.isEmpty) return 'Bitrate should not be null!'.toast();
                if (fps.isEmpty) return 'FPS should not be null!'.toast();
                if (width.isEmpty) return 'Width should not be null!'.toast();
                if (height.isEmpty) return 'Height should not be null!'.toast();
                VideoLayout layout = VideoLayout(bitrate.toInt as int, fps.toInt as int, width.toInt as int, height.toInt as int);
                if (widget.config.mediaConfig == null) widget.config.mediaConfig = MediaConfig();
                if (widget.config.mediaConfig?.videoConfig == null) widget.config.mediaConfig?.videoConfig = VideoConfig();
                setState(() {
                  widget.config.mediaConfig?.videoConfig?.tinyVideoLayout = layout;
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioConfig(BuildContext context) {
    AudioConfig? config = widget.config.mediaConfig?.audioConfig;
    if (config != null) {
      return Row(
        children: [
          Text(
            '码率: ${config.bitrate}',
            softWrap: true,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          VerticalDivider(
            width: 10.dp,
            color: Colors.transparent,
          ),
          Icons.clear.onClick(() {
            setState(() {
              widget.config.mediaConfig?.audioConfig = null;
              _mediaConfigNullable();
            });
          }),
        ],
      );
    }
    return Container();
  }

  void _showSetAudioConfig(BuildContext context) {
    TextEditingController bitrateInputController = TextEditingController();

    AudioConfig? config = widget.config.mediaConfig?.audioConfig;
    bitrateInputController.text = '${config?.bitrate ?? 40}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('音频配置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  '码率:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: bitrateInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                String bitrate = bitrateInputController.text;
                if (bitrate.isEmpty) return 'Bitrate should not be null!'.toast();
                AudioConfig config = AudioConfig(bitrate.toInt as int);
                if (widget.config.mediaConfig == null) widget.config.mediaConfig = MediaConfig();
                setState(() {
                  widget.config.mediaConfig?.audioConfig = config;
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildVideoExtendConfig(BuildContext context) {
    VideoExtend? extend = widget.config.mediaConfig?.videoConfig?.extend;
    if (extend != null) {
      return Row(
        children: [
          Text(
            '是否裁剪: ${extend.renderMode == VideoRenderMode.CROP ? '是' : '否'}',
            softWrap: true,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          VerticalDivider(
            width: 10.dp,
            color: Colors.transparent,
          ),
          Icons.clear.onClick(() {
            setState(() {
              widget.config.mediaConfig?.videoConfig?.extend = null;
              _mediaConfigNullable();
            });
          }),
        ],
      );
    }
    return Container();
  }

  void _mediaConfigNullable() {
    if (widget.config.mediaConfig?.videoConfig?.extend == null && widget.config.mediaConfig?.videoConfig?.videoLayout == null && widget.config.mediaConfig?.videoConfig?.tinyVideoLayout == null) {
      widget.config.mediaConfig?.videoConfig = null;
    }
    if (widget.config.mediaConfig?.videoConfig == null && widget.config.mediaConfig?.audioConfig == null) {
      widget.config.mediaConfig = null;
    }
  }

  void _showSetVideoExtendConfig(BuildContext context) {
    VideoRenderMode mode = widget.config.mediaConfig?.videoConfig?.extend?.renderMode ?? VideoRenderMode.CROP;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('视频额外配置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckBoxes(
                '是否裁剪',
                checked: mode == VideoRenderMode.CROP,
                onChanged: (crop) {
                  setState(() {
                    mode = crop ? VideoRenderMode.CROP : VideoRenderMode.WHOLE;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                VideoExtend extend = VideoExtend(mode);
                if (widget.config.mediaConfig == null) widget.config.mediaConfig = MediaConfig();
                if (widget.config.mediaConfig?.videoConfig == null) widget.config.mediaConfig?.videoConfig = VideoConfig();
                setState(() {
                  widget.config.mediaConfig?.videoConfig?.extend = extend;
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustoms(BuildContext context) {
    List<Widget> list = [];

    list.add(
      Row(
        children: [
          Text(
            '子视频布局',
            softWrap: true,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
          VerticalDivider(
            width: 10.dp,
            color: Colors.transparent,
          ),
          Button(
            '设置子视频布局',
            size: 15.sp,
            callback: () => _showSetSubLayout(context),
          ),
        ],
      ),
    );

    widget.config.customLayoutList?.customLayout.forEach(
      (layout) {
        list.add(
          Row(
            children: [
              Text(
                'User id: ${layout.userId}\n'
                'Stream id: ${layout.streamId}\n'
                'x: ${layout.x}, y: ${layout.y}\n'
                'width: ${layout.width}, height: ${layout.height}',
                softWrap: true,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
              VerticalDivider(
                width: 10.dp,
                color: Colors.transparent,
              ),
              Icons.clear.onClick(() {
                setState(() {
                  widget.config.customLayoutList?.customLayout.remove(layout);
                  _customNullable();
                });
              }),
            ],
          ),
        );
      },
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 10.dp,
      ),
      child: Column(
        children: list,
      ),
    );
  }

  void _customNullable() {
    if (widget.config.customLayoutList?.customLayout.isEmpty ?? true) widget.config.customLayoutList = null;
  }

  void _showSetSubLayout(BuildContext context) {
    TextEditingController userIdInputController = TextEditingController();
    TextEditingController streamIdInputController = TextEditingController();
    TextEditingController streamVideoXInputController = TextEditingController();
    TextEditingController streamVideoYInputController = TextEditingController();
    TextEditingController streamVideoWidthInputController = TextEditingController();
    TextEditingController streamVideoHeightInputController = TextEditingController();

    streamVideoXInputController.text = '0';
    streamVideoYInputController.text = '0';
    streamVideoWidthInputController.text = '180';
    streamVideoHeightInputController.text = '320';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('设置子布局'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputBox(
                hint: '用户ID',
                controller: userIdInputController,
                size: 15.sp,
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              InputBox(
                hint: '视频流ID',
                controller: streamIdInputController,
                size: 15.sp,
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '视频位置X:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: streamVideoXInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '视频位置Y:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: streamVideoYInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '视频宽度:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: streamVideoWidthInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                height: 10.dp,
                color: Colors.transparent,
              ),
              Row(
                children: [
                  '视频高度:'.toText(),
                  VerticalDivider(
                    width: 5.dp,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: InputBox(
                      hint: '请输入有效数字',
                      controller: streamVideoHeightInputController,
                      type: TextInputType.number,
                      size: 15.sp,
                      formatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                String uid = userIdInputController.text;
                String sid = streamIdInputController.text;
                String x = streamVideoXInputController.text;
                String y = streamVideoYInputController.text;
                String width = streamVideoWidthInputController.text;
                String height = streamVideoHeightInputController.text;
                if (uid.isEmpty) return 'User id should not be null!'.toast();
                if (sid.isEmpty) return 'Stream id should not be null!'.toast();
                if (x.isEmpty) return 'X should not be null!'.toast();
                if (y.isEmpty) return 'Y should not be null!'.toast();
                if (width.isEmpty) return 'Width should not be null!'.toast();
                if (height.isEmpty) return 'Height should not be null!'.toast();
                CustomLayout layout = CustomLayout(uid, sid, x.toInt as int, y.toInt as int, width.toInt as int, height.toInt as int);
                if (widget.config.customLayoutList == null) widget.config.customLayoutList = CustomLayoutList([]);
                setState(() {
                  widget.config.customLayoutList?.customLayout.removeWhere((element) => element.streamId == layout.streamId);
                  widget.config.customLayoutList?.customLayout.add(layout);
                });
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  List<Stream> _streams() {
    List<Stream> list = [];
    List<RCRTCRemoteUser>? users = RCRTCEngine.getInstance().getRoom()?.remoteUserList;
    users?.forEach((user) {
      List<RCRTCInputStream> streams = user.streamList;
      streams.forEach((stream) {
        if (stream.type == MediaType.video) {
          list.add(Stream(user.id, stream.streamId));
        }
      });
    });
    RCRTCEngine.getInstance().getDefaultVideoStream().then((stream) {
      var user = DefaultData.user;
      if (user != null && stream != null) {
        list.add(Stream(user.id, stream.streamId));
      }
    });
    return list;
  }

  void _ok() {
    if (_mainUserIdInputController.text.isEmpty) return 'Main User ID Should not be null!'.toast();
    if (_mainStreamIdInputController.text.isEmpty) return 'Main Stream ID Should not be null!'.toast();

    if (widget.config.mode == MixLayoutMode.CUSTOM) {
      var list = widget.config.customLayoutList;
      if (list == null || list.customLayout.isEmpty) return 'Sub Video Config Should not be null!'.toast();
    }

    widget.config.hostUserId = _mainUserIdInputController.text;
    widget.config.hostStreamId = _mainStreamIdInputController.text;
    widget.callback.call(widget.config);
  }

  void _reset() async {
    _mainUserIdInputController.text = "${RCRTCEngine.getInstance().getRoom()?.localUser.id}";
    _mainStreamIdInputController.text = "${(await RCRTCEngine.getInstance().getDefaultVideoStream())?.streamId}";
    widget.config.mode = MixLayoutMode.SUSPENSION;
    widget.config.mediaConfig = null;
    widget.config.customLayoutList = null;
    setState(() {});
  }

  final MixConfig widget;

  TextEditingController _mainUserIdInputController = TextEditingController();
  TextEditingController _mainStreamIdInputController = TextEditingController();
}

class CDNConfig extends StatefulWidget {
  CDNConfig({
    required this.id,
    required this.info,
    required this.cdnList,
  });

  @override
  _CDNConfigState createState() => _CDNConfigState(this);

  final String id;
  final List<CDNInfo> cdnList;
  final RCRTCLiveInfo info;
}

class _CDNConfigState extends State<CDNConfig> {
  _CDNConfigState(this.widget);

  @override
  void dispose() {
    _token.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('配置CDN'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () => _showAddCDN(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20.dp),
        itemCount: widget.cdnList.length,
        itemBuilder: (context, index) {
          CDNInfo cdn = widget.cdnList[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${index + 1} 播放地址 \nRTMP地址：${cdn.rtmp} \nHLS地址：${cdn.hls} \nFLV地址：${cdn.flv}',
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              VerticalDivider(
                width: 10.dp,
                color: Colors.transparent,
              ),
              Icons.clear.onClick(() {
                setState(() {
                  widget.info.removePublishStreamUrl(cdn.push);
                  widget.cdnList.remove(cdn);
                });
              }),
            ],
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 15.dp,
            color: Colors.transparent,
          );
        },
      ),
    );
  }

  void _showAddCDN(BuildContext context) async {
    List<CDN> list = await _loadCDNs(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('请选择CDN'),
          content: _buildCDNSelector(context, list),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<CDN>> _loadCDNs(BuildContext context) {
    Loading.show(context);
    Completer<List<CDN>> completer = Completer();
    List<CDN> list = [];
    Http.get(
      '${GlobalConfig.host}/cdns',
      null,
      (error, data) {
        jsonDecode(data).forEach((id, name) {
          list.add(CDN(id, name));
        });
        Loading.dismiss(context);
        completer.complete(list);
      },
      (error) {
        Loading.dismiss(context);
        '获取CDN列表失败'.toast();
        completer.complete(list);
      },
      _token,
    );
    return completer.future;
  }

  Widget _buildCDNSelector(BuildContext context, List<CDN> list) {
    return Container(
      width: 100.dp,
      height: 100.dp,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return list[index].name.onClick(
            () async {
              CDNInfo? info = await _loadCDN(context, list[index].id);
              if (info == null)
                '获取CDN地址失败'.toast();
              else
                setState(() {
                  widget.info.addPublishStreamUrl(info.push);
                  widget.cdnList.add(info);
                });
              Navigator.pop(context);
            },
            color: Colors.blue,
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 15.dp,
            color: Colors.transparent,
          );
        },
        itemCount: list.length,
      ),
    );
  }

  Future<CDNInfo?> _loadCDN(BuildContext context, String id) async {
    Loading.show(context);
    String? session = await RCRTCEngine.getInstance().getRoom()?.getSessionId();
    Completer<CDNInfo> completer = Completer();
    Http.get(
      '${GlobalConfig.host}/cdn/$id/sealLive/$session',
      null,
      (error, data) {
        Loading.dismiss(context);
        print("GPTest data = $data");
        completer.complete(CDNInfo.fromJons(jsonDecode(data)));
      },
      (error) {
        Loading.dismiss(context);
        completer.complete(null);
      },
      _token,
    );
    return completer.future;
  }

  final CDNConfig widget;

  final CancelToken _token = CancelToken();
}

class BoxFitChooser extends StatelessWidget {
  BoxFitChooser({
    required this.fit,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: fit,
      items: [
        DropdownMenuItem<BoxFit>(
          value: BoxFit.contain,
          child: Text(
            '自适应',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        DropdownMenuItem<BoxFit>(
          value: BoxFit.cover,
          child: Text(
            '裁剪',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        DropdownMenuItem<BoxFit>(
          value: BoxFit.fill,
          child: Text(
            '填充',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        // DropdownMenuItem<BoxFit>(
        //   value: BoxFit.fitWidth,
        //   child: Text('FitWidth'),
        // ),
        // DropdownMenuItem<BoxFit>(
        //   value: BoxFit.fitHeight,
        //   child: Text('FitHeight'),
        // ),
        // DropdownMenuItem<BoxFit>(
        //   value: BoxFit.scaleDown,
        //   child: Text('ScaleDown'),
        // ),
        // DropdownMenuItem<BoxFit>(
        //   value: BoxFit.none,
        //   child: Text('None'),
        // ),
      ],
      onChanged: (dynamic value) {
        onSelected?.call(value);
      },
    );
  }

  final BoxFit fit;
  final void Function(BoxFit value)? onSelected;
}

class MessagePanel extends StatefulWidget {
  MessagePanel(this.id, this.host);

  @override
  _MessagePanelState createState() => _MessagePanelState(this);

  final String id;
  final bool host;
}

class _MessagePanelState extends State<MessagePanel> {
  _MessagePanelState(this.widget) {
    RongIMClient.onMessageReceived = (message, left) {
      _received(message);
    };
  }

  void _received(Message? message) {
    if (message == null) return;
    setState(() {
      _messages.add(message);
    });
  }

  @override
  void dispose() {
    RongIMClient.onMessageReceived = null;
    _leave(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('消息面板'),
      ),
      body: Column(
        children: [
          Divider(
            height: 20.dp,
            color: Colors.transparent,
          ),
          Row(
            children: [
              Spacer(),
              Button(
                '${_joined ? '离开' : '加入'}聊天室',
                callback: () => _action(),
              ),
              Spacer(),
            ],
          ),
          Divider(
            height: 20.dp,
            color: Colors.transparent,
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 10.dp),
              itemBuilder: (context, index) {
                return '${_messages[index].senderUserId}${_messages[index].senderUserId == DefaultData.user?.id ? '(我)' : ''}:${_messages[index].content?.conversationDigest()}'.toText();
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: 15.dp,
                  color: Colors.transparent,
                );
              },
              itemCount: _messages.length,
            ),
          ),
          Divider(
            height: 20.dp,
            color: Colors.transparent,
          ),
          Row(
            children: [
              Spacer(),
              Button(
                '发送消息',
                callback: () => _send(),
              ),
              Spacer(),
            ],
          ),
          Divider(
            height: 20.dp,
            color: Colors.transparent,
          ),
        ],
      ),
    );
  }

  void _action() {
    if (!_joined)
      _join();
    else
      _leave();
  }

  void _join() {
    if (_joined) return;
    setState(() {
      _joined = true;
    });
    RongIMClient.joinChatRoom(widget.id, -1);
  }

  void _leave([bool set = true]) {
    if (!_joined) return;
    if (set)
      setState(() {
        _joined = false;
      });
    RongIMClient.quitChatRoom(widget.id);
  }

  void _send() async {
    if (!_joined) return '请先加入房间'.toast();
    TextMessage message = TextMessage();
    message.content = '我是${widget.host ? '主播' : '观众'}';
    _received(await RongIMClient.sendMessage(RCConversationType.ChatRoom, widget.id, message));
  }

  final MessagePanel widget;
  final List<Message> _messages = [];
  bool _joined = false;
}
