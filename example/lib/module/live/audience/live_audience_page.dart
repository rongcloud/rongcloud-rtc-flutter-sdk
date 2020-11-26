import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/ui/toast.dart';
import 'package:FlutterRTC/module/live/audience/live_audience_page_presenter.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../../colors.dart';
import 'live_audience_page_contract.dart';

class LiveAudiencePage extends AbstractView {
  @override
  _LiveAudiencePageState createState() => _LiveAudiencePageState();
}

class _LiveAudiencePageState extends AbstractViewState<Presenter, LiveAudiencePage> implements View {
  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Stack(
          children: [
            _buildVideoView(context),
            _buildInfoView(context),
            _buildBottomView(context),
          ],
        ),
      ),
      onWillPop: () => _doExit(context),
    );
  }

  Widget _buildVideoView(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.lightGreen,
      child: Stack(children: [
        _videoView ?? Container(),
        Center(
          child: _buildPullViewByState(context),
        ),
      ]),
    );
  }

  Widget _buildPullViewByState(BuildContext context) {
    switch (_pullState) {
      case 0:
        return _buildPullWaitInfo(context);
      case 2:
        return _buildPullErrorInfo(context);
    }
    return Container();
  }

  Widget _buildPullWaitInfo(BuildContext context) {
    return Text(
      "请稍候...",
      style: TextStyle(
        color: Colors.lightBlueAccent,
        fontSize: 30.0,
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildPullErrorInfo(BuildContext context) {
    return GestureDetector(
      onTap: () => _rePull(context),
      child: Text(
        "拉流失败，点击重试",
        style: TextStyle(
          color: Colors.lightGreen,
          fontSize: 30.0,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  void _rePull(BuildContext context) {
    presenter?.pull();
  }

  Widget _buildInfoView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 45.0,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: ColorConfig.blackAlpha66,
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 30.0,
                            height: 30.0,
                            child: Image.asset("assets/images/default_user_icon.jpg"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 10.0,
                            right: 20.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "主播名称",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                "10.2w本场点赞",
                                style: TextStyle(
                                  fontSize: 7.0,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 30.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: ColorConfig.defaultRed,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 10.0,
                              right: 10.0,
                            ),
                            child: Text(
                              "关注",
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.white,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: Image.asset("assets/images/default_user_icon.jpg"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: Image.asset("assets/images/default_user_icon.jpg"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: ClipOval(
                      child: SizedBox(
                        width: 30.0,
                        height: 30.0,
                        child: Image.asset("assets/images/default_user_icon.jpg"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 30.0,
                      constraints: BoxConstraints(
                        minWidth: 40.0,
                      ),
                      padding: EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: ColorConfig.blackAlpha33,
                      ),
                      child: Text(
                        "0",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    top: 2.0,
                    bottom: 3.0,
                    left: 6.0,
                    right: 6.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: ColorConfig.blackAlpha33,
                  ),
                  child: Text(
                    "更多直播 >",
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomView(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBottomRemoteView(context),
          _buildMessageView(context),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomRemoteView(BuildContext context) {
    return Container(
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 1.0,
        children: _buildRemoteViews(context),
      ),
    );
  }

  List<Widget> _buildRemoteViews(BuildContext context) {
    List<Widget> widgets = List();
    _smallVideoViews.forEach((view) {
      widgets.add(_buildRemoteView(context, view));
    });
    return widgets;
  }

  Widget _buildRemoteView(BuildContext context, TextureView view) {
    return Container(
      color: Colors.yellow,
      alignment: Alignment.center,
      child: view.view,
    );
  }

  Widget _buildMessageView(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 5.0,
        left: 15.0,
      ),
      width: MediaQuery.of(context).size.width / 3 * 2,
      constraints: BoxConstraints(
        maxHeight: 200,
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            shrinkWrap: true,
            controller: _messageController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessage(context, _messages[index]);
            }),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, Message message) {
    return Row(
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 10.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: ColorConfig.blackAlpha33,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 5.0,
                  bottom: 5.0,
                ),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${message.user.name}:',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.lightBlueAccent,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      TextSpan(
                        text: message.message,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 15.0,
        left: 15.0,
        right: 15.0,
      ),
      width: double.infinity,
      height: 35.0,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
              ),
              height: 35.0,
              decoration: BoxDecoration(
                color: ColorConfig.blackAlpha33,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextField(
                controller: _inputMessageController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.send,
                maxLines: 1,
                maxLength: 32,
                maxLengthEnforced: true,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  hintText: "说点什么...",
                  hintStyle: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                ),
                onEditingComplete: () {
                  String message = _inputMessageController.text;
                  _inputMessageController.text = '';
                  _sendMessage(context, message);
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 15.0,
            ),
            child: GestureDetector(
              onTap: () => _doExit(context),
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: Image.asset("assets/images/close.png"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context, String message) {
    presenter.sendMessage(message);
  }

  Future<bool> _doExit(BuildContext context) {
    Loading.show(context);
    presenter.exit(context);
    return Future.value(false);
  }

  @override
  Presenter createPresenter() {
    return LiveAudiencePagePresenter();
  }

  @override
  void onPulled(RCRTCTextureView videoView) {
    setState(() {
      _pullState = 1;
      _videoView = videoView;
    });
  }

  @override
  void onPullError(int code, String message) {
    setState(() {
      _pullState = 2;
    });
  }

  @override
  void onReceiveMessage(Message message) {
    setState(() {
      _messages.add(message);
      Future.delayed(Duration(milliseconds: 50)).then((value) {
        _messageController.jumpTo(_messageController.position.maxScrollExtent);

        // _messageController.animateTo(
        //   _messageController.position.maxScrollExtent,
        //   duration: Duration(milliseconds: 100),
        //   curve: Curves.easeOut,
        // );
      });
    });
  }

  @override
  void onReceiveInviteMessage(User user) async {
    if (_inviting) return;

    _inviting = true;

    var action = await showDialog(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        content: Text(
          "主播邀请你加入连麦，是否加入？",
        ),
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.pop(context);
                _inviting = false;
                _refuseInvite(user);
              },
              child: Text("算了吧")),
          FlatButton(
              onPressed: () {
                Navigator.pop(context);
                _inviting = false;
                _agreeInvite(user);
              },
              child: Text("加入！")),
        ],
      ),
    );

    if (action == null) {
      _inviting = false;
      _refuseInvite(user);
    }
  }

  void _refuseInvite(User user) {
    presenter?.refuseInvite(user);
  }

  void _agreeInvite(User user) {
    setState(() {
      _videoView = null;
      _pullState = 0;
    });
    presenter?.agreeInvite(
      user,
      (videoView) {
        _setSmallView(DefaultData.user, videoView);
      },
      (uid, videoView) {
        if (uid == user.id) {
          setState(() {
            _videoView = videoView;
            _pullState = 1;
          });
        } else {
          _setSmallView(User.unknown(uid), videoView);
        }
      },
      (uid) {
        _removeSmallView(uid);
      },
    );
  }

  void _removeSmallView(String uid) {
    TextureView view = getUsersViewById(uid);
    if (view != null)
      setState(() {
        _smallVideoViews.remove(view);
      });
  }

  TextureView getUsersViewById(String uid) {
    for (TextureView view in _smallVideoViews) {
      if (view.user.id == uid) {
        return view;
      }
    }
    return null;
  }

  void _setSmallView(User user, RCRTCTextureView videoView) {
    TextureView view = getUsersView(user);
    if (view == null) {
      setState(() {
        _smallVideoViews.add(TextureView(user, videoView));
      });
    }
  }

  TextureView getUsersView(User user) {
    return getUsersViewById(user.id);
  }

  @override
  void onExit(BuildContext context) {
    Loading.dismiss(context);
    _exit();
  }

  void _exit() {
    Navigator.pop(context);
  }

  @override
  void onExitWithError(BuildContext context, String info) {
    Toast.show(context, info);
    onExit(context);
  }

  ScrollController _messageController = ScrollController();

  TextEditingController _inputMessageController = TextEditingController();

  List<Message> _messages = List();

  RCRTCTextureView _videoView;

  List<TextureView> _smallVideoViews = List();

  int _pullState = 0;

  bool _inviting = false;
}
