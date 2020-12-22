import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class StatusPanel extends StatelessWidget {
  StatusPanel({
    @required this.report,
  });

  @override
  Widget build(BuildContext context) {
    if (report == null) return CircularProgressIndicator();
    return ListView(
      children: [
        _buildLocalStatus(context),
        _buildSendStatus(context),
        _buildReceiveStatus(context),
      ],
    );
  }

  Widget _buildLocalStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            top: 20.dp,
          ),
          child: Text(
            "网络类型: ${report.networkType}",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            top: 5.dp,
          ),
          child: Text(
            "IP: ${report.ipAddress}",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            top: 5.dp,
          ),
          child: Text(
            "发送码率: ${report.bitRateSend}kbps",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            top: 5.dp,
          ),
          child: Text(
            "接收码率: ${report.bitRateRcv}kbps",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            top: 5.dp,
          ),
          child: Text(
            "往返延迟: ${report.rtt}ms",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            top: 20.dp,
          ),
          child: Text(
            "视频发布状态: ",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            right: 20.dp,
            top: 5.dp,
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(
              color: Colors.grey,
              width: 1.dp,
              style: BorderStyle.solid,
            ),
            children: _buildVideoSendStatus(context),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            top: 20.dp,
          ),
          child: Text(
            "音频发布状态: ",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            right: 20.dp,
            top: 5.dp,
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(
              color: Colors.grey,
              width: 1.dp,
              style: BorderStyle.solid,
            ),
            children: _buildAudioSendStatus(context),
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildVideoSendStatus(BuildContext context) {
    List<TableRow> widgets = List();
    widgets.add(
      TableRow(
        children: [
          Text(
            "分辨率",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "帧率",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "码率(kbps)",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "往返延迟(ms)",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "丢包率",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
    report.statusVideoSends.values.forEach((status) {
      widgets.add(
        TableRow(
          children: [
            Text(
              "${status.frameWidth}x${status.frameHeight}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.frameRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.bitRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.rtt}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.packetLostRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      );
    });
    return widgets;
  }

  List<TableRow> _buildAudioSendStatus(BuildContext context) {
    List<TableRow> widgets = List();
    widgets.add(
      TableRow(
        children: [
          Text(
            "码率(kbps)",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "往返延迟(ms)",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "丢包率",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
    report.statusAudioSends.values.forEach((status) {
      widgets.add(
        TableRow(
          children: [
            Text(
              "${status.bitRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.rtt}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.packetLostRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      );
    });
    return widgets;
  }

  Widget _buildReceiveStatus(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            top: 20.dp,
          ),
          child: Text(
            "视频订阅状态: ",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            right: 20.dp,
            top: 5.dp,
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(
              color: Colors.grey,
              width: 1.dp,
              style: BorderStyle.solid,
            ),
            children: _buildVideoReceiveStatus(context),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            top: 20.dp,
          ),
          child: Text(
            "音频订阅状态: ",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.dp,
            right: 20.dp,
            top: 5.dp,
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(
              color: Colors.grey,
              width: 1.dp,
              style: BorderStyle.solid,
            ),
            children: _buildAudioReceiveStatus(context),
          ),
        ),
      ],
    );
  }

  List<TableRow> _buildVideoReceiveStatus(BuildContext context) {
    List<TableRow> widgets = List();
    widgets.add(
      TableRow(
        children: [
          Text(
            "分辨率",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "帧率",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "码率(kbps)",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "丢包率",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
    report.statusVideoRcvs.values.forEach((status) {
      widgets.add(
        TableRow(
          children: [
            Text(
              "${status.frameWidth}x${status.frameHeight}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.frameRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.bitRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.packetLostRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      );
    });
    return widgets;
  }

  List<TableRow> _buildAudioReceiveStatus(BuildContext context) {
    List<TableRow> widgets = List();
    widgets.add(
      TableRow(
        children: [
          Text(
            "音量",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "码率(kbps)",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "丢包率",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
    report.statusAudioRcvs.values.forEach((status) {
      widgets.add(
        TableRow(
          children: [
            Text(
              "${status.audioOutputLevel}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.bitRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              "${status.packetLostRate}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      );
    });
    return widgets;
  }

  final StatusReport report;
}
