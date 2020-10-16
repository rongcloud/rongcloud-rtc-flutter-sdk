import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/ui/toast.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import '../../colors.dart';
import '../../global_config.dart';
import 'home_page_contract.dart';
import 'home_page_model.dart';
import 'home_page_presenter.dart';

class HomePage extends AbstractView {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends AbstractViewState<Presenter, HomePage> implements View {
  @override
  Widget buildWidget(BuildContext context) {
    _userAvatar = DefaultData.user.avatar;
    return Scaffold(
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 && !_isLoading) {
            // TODO 暂时没有加载更多
            // if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
            //   _loadLiveRoomList();
            // }
          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () => _refreshLiveRoomList(),
          child: CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                actions: [
                  new IconButton(icon: Icon(Icons.account_circle), onPressed: () => _buildUserInfoDialog(context)),
                ],
                backgroundColor: ColorConfig.defaultGradientEnd,
                expandedHeight: 256.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(GlobalConfig.appTitle),
                  centerTitle: true,
                  background: Image(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/login_logo.png'),
                  ),
                ),
              ),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () => _requestJoinLiveRoom(context, _list.list[index]),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        color: ColorConfig.defaultGradientStart,
                        child: Stack(
                          children: [
                            Text('Room\n${_list.list[index].id}'),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _list?.list?.length ?? 0,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            gradient: LinearGradient(
              colors: [
                ColorConfig.defaultGradientStart,
                ColorConfig.defaultGradientEnd,
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Icon(Icons.add),
          ),
        ),
        onTap: () => _buildConfirmRoomInfoDialog(context),
      ),
    );
  }

  void _buildUserInfoDialog(BuildContext context) {
    userNameController.text = DefaultData.user.name;
    if (userNameController.text != null) {
      _nameAutoFocus = false;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: EdgeInsets.all(0),
              children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: LinearGradient(
                      colors: [
                        ColorConfig.defaultGradientStart,
                        ColorConfig.defaultGradientEnd,
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: _buildUserName(context),
                ),
              ],
            ),
          );
        });
  }

  void _buildConfirmRoomInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setter) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: EdgeInsets.all(0),
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(
                    colors: [
                      ColorConfig.defaultGradientStart,
                      ColorConfig.defaultGradientEnd,
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      child: _buildTypeChooser(context, setter),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.only(top: 10.0),
                    //   child: _buildUserId(context),
                    // ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: _buildRoomId(context),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: _buildStart(context),
                    ),
                  ],
                ),
              )
            ],
          );
        });
      },
    );
  }

  Widget _buildTypeChooser(BuildContext context, StateSetter setter) {
    return Container(
      // width: 300.0,
      // height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child: Row(
              children: [
                Radio(
                  value: 0,
                  groupValue: _type,
                  onChanged: null,
                ),
                Text(
                  "Video Chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            onTap: () => changeType(0, setter),
          ),
          GestureDetector(
            child: Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: _type,
                  onChanged: null,
                ),
                Text(
                  "Live Chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            onTap: () => changeType(1, setter),
          ),
        ],
      ),
    );
  }

  void changeType(int type, StateSetter setter) {
    setter(() {
      _type = type;
    });
  }

  void _buildUserAvatarDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Text('选择头像'),
            ),
            content: Container(
              height: 300.0,
              width: 100.0,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 20,
                itemBuilder: (BuildContext context, int index) {
                  return IconButton(
                    icon: Image.asset('assets/images/user_avatar/user_avatar_$index.png'),
                    onPressed: () {
                      _userAvatar = 'assets/images/user_avatar/user_avatar_$index.png';
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          );
        });
  }

  Widget _buildUserName(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: [
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 280.0,
                  // height: 70.0,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                          left: 25.0,
                          right: 25.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Image.asset(_userAvatar),
                              iconSize: 25,
                              onPressed: () {
                                setState(() {
                                  _buildUserAvatarDialog(context);
                                });
                              },
                            ),
                            TextFormField(
                                autofocus: _nameAutoFocus,
                                controller: userNameController,
                                decoration: InputDecoration(
                                  labelText: "设置用户名：",
                                  hintText: DefaultData.user.name,
                                  // prefixIcon: Icon(Icons.person),
                                ),
                                validator: (v) {
                                  return v.trim().isNotEmpty && v.trim().length >= 6 ? null : "用户名长度不能少于 6 个字母";
                                }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                          left: 25.0,
                          right: 25.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            new IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                if (DefaultData.user.name.isNotEmpty) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            new IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () {
                                if ((_formKey.currentState as FormState).validate()) {
                                  DefaultData.setUserName(userNameController.text);
                                  DefaultData.setUserAvatar(_userAvatar);
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomId(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: [
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 280.0,
                  height: 70.0,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                          left: 25.0,
                          right: 25.0,
                        ),
                        child: TextField(
                          controller: roomIdController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.houseUser,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: 'Room ID',
                            hintStyle: TextStyle(fontSize: 17.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStart(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorConfig.defaultGradientStart,
            offset: Offset(1.0, 6.0),
            blurRadius: 20.0,
          ),
          BoxShadow(
            color: ColorConfig.defaultGradientEnd,
            offset: Offset(1.0, 6.0),
            blurRadius: 20.0,
          ),
        ],
        gradient: LinearGradient(
          colors: [
            ColorConfig.defaultGradientEnd,
            ColorConfig.defaultGradientStart,
          ],
          begin: const FractionalOffset(0.2, 0.2),
          end: const FractionalOffset(1.0, 1.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: MaterialButton(
        highlightColor: Colors.transparent,
        splashColor: ColorConfig.defaultGradientEnd,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 42.0),
          child: Text(
            'START',
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
        ),
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());

          // String uid = userIdController.value.text;
          // if (uid.isEmpty) {
          //   Toast.show(context, "User Id can't be null.");
          //   return;
          // }
          String rid = roomIdController.value.text;
          if (rid.isEmpty) {
            Toast.show(context, "Room Id can't be null.");
            return;
          }
          Navigator.pop(context);
          _requestJoinRoom(context, rid, _type == 0 ? RCRTCRoomType.Normal : RCRTCRoomType.Live);
        },
      ),
    );
  }

  @override
  Presenter createPresenter() {
    return HomePagePresenter();
  }

  @override
  void onServerVersionLoaded(String version) {
    // TODO 暂无处理
  }

  @override
  void onLoginSuccess() {
    // TODO 暂无处理
  }

  @override
  void onLoginError(String info) {
    // TODO 暂无处理
  }

  @override
  void onLiveRoomListLoaded(RoomList list) {
    _isLoading = false;
    setState(() {
      _list = list;
    });
    if (DefaultData.user.name.isEmpty) {
      _buildUserInfoDialog(context);
    }
  }

  @override
  void onLiveRoomListLoadError(String info) {
    _isLoading = false;
    // TODO 列表获取失败
  }

  @override
  void onLiveRoomCreated(BuildContext context) {
    Loading.dismiss(context);
    if (_type == 0) {
      _gotoChat();
    } else {
      _gotoHost();
    }
  }

  void _gotoChat() {
    Navigator.pushNamed(context, RouterManager.VIDEO_CHAT);
  }

  void _gotoHost() {
    Navigator.pushNamed(context, RouterManager.LIVE_HOST);
  }

  @override
  void onLiveRoomCreateError(BuildContext context, String info) {
    print("onLiveRoomCreateError info = $info");
    Loading.dismiss(context);
  }

  @override
  void onLiveRoomJoined(BuildContext context, Room room) {
    Loading.dismiss(context);
    _gotoAudience(room.id, room.url);
  }

  void _gotoAudience(String roomId, String url) {
    Navigator.pushNamed(
      context,
      RouterManager.LIVE_AUDIENCE,
      arguments: {
        'roomId': roomId,
        'url': url,
      },
    );
  }

  @override
  void onLiveRoomJoinError(BuildContext context, String info) {
    print("onLiveRoomJoinError info = $info");
    Loading.dismiss(context);
  }

  Future<void> _refreshLiveRoomList() async {
    _isLoading = true;
    presenter?.loadLiveRoomList(true);
  }

  Future<void> _loadLiveRoomList() async {
    _isLoading = true;
    presenter?.loadLiveRoomList();
  }

  Future<void> _requestJoinRoom(BuildContext context, String rid, RCRTCRoomType type) async {
    Loading.show(context);
    presenter.requestJoinRoom(context, rid, type);
  }

  Future<void> _requestJoinLiveRoom(BuildContext context, Room room) async {
    Loading.show(context);
    presenter.requestJoinLiveRoom(context, room);
  }

  bool _isLoading = false;
  bool _nameAutoFocus = true;

  RoomList _list;

  int _type = 0;
  String _userAvatar;

  GlobalKey _formKey = new GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController roomIdController = TextEditingController();
}
