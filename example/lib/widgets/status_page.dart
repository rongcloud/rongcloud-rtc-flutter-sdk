import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_rtc_plugin/agent/rcrtc_engine.dart';
import 'package:rongcloud_rtc_plugin/agent/rcrtc_status_report.dart';
import 'package:rongcloud_rtc_plugin/agent/stream/rcrtc_camera_output_stream.dart';
import 'package:rongcloud_rtc_plugin/agent/stream/rcrtc_stream.dart';

// ignore: must_be_immutable
class RtcStatusPage extends StatefulWidget {
  RtcStatusPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RtcStatusPageState();
  }
}

class _RtcStatusPageState extends State<RtcStatusPage> with SingleTickerProviderStateMixin implements IRCRTCStatusReportListener {
  _RtcStatusPageState() {
    RCRTCEngine.getInstance().registerStatusReportListener(this);
  }

  StatusBean vsSend;
  StatusBean asSend;
  StatusBean vsRecv;
  StatusBean asRecv;
  StatusBean statusBean;

  @override
  void dispose() {
    RCRTCEngine.getInstance().unRegisterStatusReportListener();
    super.dispose();
  }

  StatusReport _statusReport;
  @override
  onConnectionStats(StatusReport statusReport) async {
    RCRTCStream astream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    RCRTCStream vstream = await RCRTCEngine.getInstance().getDefaultVideoStream();
    if (await RCRTCEngine.getInstance().getRoom().remoteUserList.isNotEmpty && await RCRTCEngine.getInstance().getRoom().remoteUserList[0].streamList.isNotEmpty){
      RCRTCStream rastream = await RCRTCEngine.getInstance().getRoom().remoteUserList[0].streamList[0];
      RCRTCStream rvstream = await RCRTCEngine.getInstance().getRoom().remoteUserList[0].streamList[0];
      this.asRecv = statusReport.statusAudioRcvs[rastream.streamId];
      this.vsRecv = statusReport.statusVideoRcvs[rvstream.streamId];
    }

    setState(() {
      _statusReport = statusReport;
      this.asSend = statusReport.statusAudioSends[astream.streamId];
      this.vsSend = statusReport.statusVideoSends[vstream.streamId];
    });
  }

  final List<Tab> myTabs = <Tab>[
    Tab(text: '全局状态'),
    Tab(text: '音频发送'),
    Tab(text: '视频发送'),
    Tab(text: '音频接收'),
    Tab(text: '视频接收'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  Widget build(BuildContext context) {
    if (_statusReport == null){
      return Container();
    }
    return Container(
      width: 250,
      height: 500,
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBar(
          isScrollable: true,
          labelColor: Colors.blue,
          controller: _tabController,
          tabs: myTabs,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildGlobalInfo(context),
            buildAvInfo(context, 0),
            buildAvInfo(context, 1),
            buildAvInfo(context, 2),
            buildAvInfo(context, 3),
          ],
        ),
      ),
    );
  }

  Widget buildAvInfo(BuildContext context, int tag) {

    if (tag == 0){
      this.statusBean = asSend;
    }else if (tag == 1){
      this.statusBean = vsSend;
    }else if (tag == 2){
      this.statusBean = asRecv;
    }else if (tag == 3){
      this.statusBean = vsRecv;
    }

    if (statusBean == null){
      return Container();
    }

    return Table(

      columnWidths: const {
        0: FixedColumnWidth(120.0),
        1: FixedColumnWidth(120.0),
      },
      border: TableBorder.all(color: Colors.red, width: 1.0, style: BorderStyle.solid),
      children: [
        TableRow(
          children: [
            Text(
              'id:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.id,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'uid:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.uid,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'codecName:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.codecName,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'mediaType:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.mediaType,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'packetLostRate:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.packetLostRate,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'frameHeight:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.frameHeight.toString(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'frameWidth:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.frameWidth.toString(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'frameRate:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.bitRate.toString(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'rtt:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.rtt.toString(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'googJitterReceived:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.googJitterReceived.toString(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'googRenderDelayMs:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.googRenderDelayMs.toString(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'audioOutputLevel:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.audioOutputLevel,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'codecImplementationName:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.codecImplementationName != null ? statusBean.codecImplementationName : '',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'googNacksReceived:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              statusBean.googNacksReceived,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget buildGlobalInfo(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(120.0),
        1: FixedColumnWidth(120.0),
      },
      border: TableBorder.all(color: Colors.red, width: 1.0, style: BorderStyle.solid),
      children: [
        TableRow(
          children: [
            Text(
              'bitRateSend:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              _statusReport.bitRateSend != null ? _statusReport.bitRateSend.toString() : '',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'bitRateRecv:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              _statusReport.bitRateRcv != null ? _statusReport.bitRateRcv.toString() : '',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'rtt:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              _statusReport.rtt != null ? _statusReport.rtt.toString() : '',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'networkType:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              _statusReport.networkType,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'ipAddress:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              _statusReport.ipAddress,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'googAvailableReceiveBandwidth:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              _statusReport.googAvailableReceiveBandwidth,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'googAvailableSendBandwidth:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              _statusReport.googAvailableSendBandwidth,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Text(
              'packetsDiscardedOnSend:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              _statusReport.packetsDiscardedOnSend,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
