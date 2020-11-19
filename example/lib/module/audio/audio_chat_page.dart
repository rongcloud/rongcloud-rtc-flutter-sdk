import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart' as PermissionHandler;
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

class AudioChatPage extends StatefulWidget {
  @override
  _AudioChatPageState createState() => _AudioChatPageState();
}

class _AudioChatPageState extends State<AudioChatPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _subscribe();
    _mic = await PermissionHandler.Permission.microphone.request().isGranted;
    setState(() {});
    if (_mic) {
      _publish();
    }
  }

  void _subscribe() {
    RCRTCRoom room = RCRTCEngine.getInstance().getRoom();
    RCRTCLocalUser localUser = room.localUser;

    for (RCRTCRemoteUser user in room.remoteUserList) {
      localUser.subscribeStreams(user.streamList);
      _addUser(user.id);
    }

    room.onRemoteUserPublishResource = (user, streams) {
      localUser.subscribeStreams(streams);
      _addUser(user.id);
    };

    room.onRemoteUserUnPublishResource = (user, streams) {
      localUser.unsubscribeStreams(streams);

      streams.whereType<RCRTCAudioInputStream>().forEach((stream) {
        _removeUser(user.id);
      });
    };

    room.onRemoteUserLeft = (user) {
      _removeUser(user.id);
    };
  }

  Future<void> _publish() async {
    RCRTCOutputStream stream = await RCRTCEngine.getInstance().getDefaultAudioStream();
    RCRTCLocalUser user = RCRTCEngine.getInstance().getRoom().localUser;
    int code = await user.publishStreams([stream]);
    if (code == 0) _addUser(user.id);
  }

  void _addUser(String id) {
    if (!_users.contains(id)) _users.add(id);
    setState(() {});
  }

  void _removeUser(String id) {
    _users.remove(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _mic ? _buildNormal() : _buildNoPermission(),
          _buildEndCallButton(),
        ],
      ),
    );
  }

  Widget _buildNormal() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      childAspectRatio: 1.0,
      children: _buildViews(context),
    );
  }

  Widget _buildNoPermission() {
    return Text(
      "没有麦克风权限，请设置给予",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildEndCallButton() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 15.0,
      ),
      child: GestureDetector(
        onTap: () => _exit(),
        child: SizedBox(
          width: 85.0,
          height: 85.0,
          child: Icon(
            FontAwesomeIcons.phoneSlash,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Future<void> _exit() async {
    RCRTCEngine.getInstance().leaveRoom();
    RongIMClient.disconnect(false);
    Navigator.pop(context);
  }

  List<Widget> _buildViews(BuildContext context) {
    List<Widget> widgets = List();
    _users.forEach((user) {
      widgets.add(Container(
        color: Colors.yellow,
        alignment: Alignment.center,
        child: Text(
          user,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            decoration: TextDecoration.none,
          ),
        ),
      ));
    });
    return widgets;
  }

  bool _mic = false;
  List<String> _users = List();
}
