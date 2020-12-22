import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/frame/ui/loading.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/buttons.dart';
import 'audio_live_list_contract.dart';
import 'audio_live_list_presenter.dart';

class AudioLiveList extends AbstractView {
  @override
  _AudioLiveListState createState() => _AudioLiveListState();
}

class _AudioLiveListState extends AbstractViewState<Presenter, AudioLiveList> implements View {
  // ignore: unused_field
  bool _isLoading = false;
  RoomList _roomList;

  @override
  createPresenter() {
    return AudioLiveListPresenter();
  }

  @override
  onLiveRoomListSuccess(RoomList list) {
    setState(() {
      _isLoading = false;
      _roomList = list;
    });
  }

  @override
  onLiveRoomListFailure(String error) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  joinRoomFailure(BuildContext context, String error) {
    print("onLiveRoomJoinError info = $error");
    Loading.dismiss(context);
  }

  @override
  joinRoomSuccess(BuildContext context, Room room) {
    Loading.dismiss(context);
    _gotoAudioLive(room);
  }

  void _gotoAudioLive(Room room) {
    Navigator.pushNamed(
      context,
      RouterManager.AUDIO_LIVE_AUDIENCE,
      arguments: room.toJSON(),
    );
  }

  Future<void> _refreshLiveRoomList() async {
    _isLoading = true;
    presenter?.getAudioLiveRoomList(true);
  }

  Future<void> _requestJoinLiveRoom(
    BuildContext context,
    Room room,
  ) async {
    Loading.show(context);
    presenter?.joinAudioLiveRoom(context, room);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF102032),
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFFF102032),
        title: Text(
          "音频互动直播",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        leading: 'navigator_back'.toPNGButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshLiveRoomList(),
        child: Stack(
          children: [
            Offstage(
              offstage: (_roomList?.list == null || _roomList.list.length > 0) ? true : false,
              child: _loadEmptyList(),
            ),
            _audioLiveListView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: 'create_room'.png.image,
        onPressed: () {
          Navigator.pushNamed(context, RouterManager.AUDIO_LIVE_CREATE);
        },
      ),
    );
  }

  Widget _loadEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          "video_live_list_empty".png.image,
          Text(
            "当前暂无内容呦~",
            style: TextStyle(fontSize: 14.sp, color: Color(0xFF73859D)),
          )
        ],
      ),
    );
  }

  Widget _audioLiveListView() {
    return ListView.builder(
      padding: EdgeInsets.all(20.dp),
      itemCount: _roomList?.list?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            _buildAudioLiveCell(
              _roomList?.list[index].user.avatar,
              '${_roomList?.list[index].id}',
              '${_roomList?.list[index].user.name}',
              () => _requestJoinLiveRoom(context, _roomList?.list[index]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.dp),
            )
          ],
        );
      },
    );
  }

  Widget _buildAudioLiveCell(
    String imgUrl,
    String title,
    String subTitle,
    void onTap(),
  ) {
    return GestureDetector(
      child: Container(
        height: 96.dp,
        padding: EdgeInsets.all(15.dp),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFF2E4D74), width: 1.dp),
          color: Color(0xFFF1B2E45),
          borderRadius: BorderRadius.circular(8.dp),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32.dp,
              backgroundImage: AssetImage(imgUrl),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.dp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 8.dp)),
                  Text(
                    subTitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xFFF73859D),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
