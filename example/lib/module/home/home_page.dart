import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:flutter/material.dart';

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
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      _gotoSetting();
                    },
                  )
                ],
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
        onTap: () => _goToConfig(),
      ),
    );
  }

  @override
  Presenter createPresenter() {
    return HomePagePresenter();
  }

  @override
  void onLiveRoomListLoaded(RoomList list) {
    _isLoading = false;
    setState(() {
      _list = list;
    });
  }

  @override
  void onLiveRoomListLoadError(String info) {
    _isLoading = false;
    // TODO 列表获取失败
  }

  @override
  void onLiveRoomJoinError(BuildContext context, String info) {
    print("onLiveRoomJoinError info = $info");
    Loading.dismiss(context);
  }

  @override
  void onLiveRoomJoined(BuildContext context, Room room) {
    Loading.dismiss(context);
    _gotoAudience(room.id, room.url);
  }

  void _goToConfig() {
    Navigator.pushNamed(context, RouterManager.CONFIG);
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

  Future<void> _refreshLiveRoomList() async {
    _isLoading = true;
    presenter?.loadLiveRoomList(true);
  }

  Future<void> _loadLiveRoomList() async {
    _isLoading = true;
    presenter?.loadLiveRoomList();
  }

  void _gotoSetting() {
    Navigator.pushNamed(context, RouterManager.SETTINGS);
  }

  Future<void> _requestJoinLiveRoom(BuildContext context, Room room) async {
    Loading.show(context);
    presenter.requestJoinLiveRoom(context, room);
  }

  bool _isLoading = false;

  RoomList _list;
}
