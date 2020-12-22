import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'live_home_page_contract.dart';
import 'live_home_page_presenter.dart';

class LiveHomePage extends AbstractView {
  @override
  _LiveHomePageState createState() => _LiveHomePageState();
}

class _LiveHomePageState extends AbstractViewState<Presenter, LiveHomePage> implements View {
  @override
  Presenter createPresenter() {
    return LiveHomePagePresenter();
  }

  @override
  void init(BuildContext context) {
    super.init(context);
    _loadLiveRoomList();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.backgroundColor,
      appBar: AppBar(
        title: Text(
          '视频互动直播',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: ColorConfig.emptyTextColor,
            decoration: TextDecoration.none,
          ),
        ),
        leading: IconButton(
          icon: 'navigator_back'.png.image,
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: ColorConfig.backgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshLiveRoomList(),
        child: _buildBody(context),
      ),
      floatingActionButton: FloatingActionButton(
        child: 'create_room'.png.image,
        onPressed: () => _goToConfig(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    int count = _list?.list?.length ?? 0;
    return count > 0 ? _buildRoomList(context, count) : _buildEmptyInfo();
  }

  Widget _buildRoomList(BuildContext context, int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.dp),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.dp,
          crossAxisSpacing: 8.dp,
          childAspectRatio: 1.0,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          return _buildRoom(context, _list.list[index]);
        },
      ),
    );
  }

  Widget _buildRoom(BuildContext context, Room room) {
    return Container(
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: room.user.cover.assetImage,
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.dp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.id,
              softWrap: true,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              room.user.name,
              softWrap: true,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    ).toButton(
      onPressed: () => _requestJoinLiveRoom(context, room),
    );
  }

  Widget _buildEmptyInfo() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(top: 140.dp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          "video_live_list_empty".png.image,
          Text(
            "当前暂无内容呦~",
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorConfig.emptyTextColor,
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    ).toButton(
      onPressed: () => _refreshLiveRoomList(),
    );
  }

  Future<void> _refreshLiveRoomList() async {
    if (_isLoading) return;
    _isLoading = true;
    presenter?.loadLiveRoomList(true);
  }

  Future<void> _loadLiveRoomList() async {
    if (_isLoading) return;
    _isLoading = true;
    presenter?.loadLiveRoomList();
  }

  Future<void> _requestJoinLiveRoom(BuildContext context, Room room) async {
    Loading.show(context);
    presenter.requestJoinLiveRoom(context, room);
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
  }

  @override
  void onLiveRoomJoinError(BuildContext context, String info) {
    print("onLiveRoomJoinError info = $info");
    Loading.dismiss(context);
  }

  @override
  void onLiveRoomJoined(BuildContext context, Room room) {
    Loading.dismiss(context);
    _gotoAudience(room);
  }

  void _goToConfig() {
    Navigator.pushNamed(context, RouterManager.LIVE_CONFIG);
  }

  void _gotoAudience(Room room) {
    Navigator.pushNamed(
      context,
      RouterManager.LIVE_AUDIENCE,
      arguments: room.toJSON(),
    );
  }

  bool _isLoading = false;

  RoomList _list;
}
