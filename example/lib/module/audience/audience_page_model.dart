import 'package:rc_rtc_flutter_example/data/constants.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/model.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'audience_page_contract.dart';

class AudiencePageModel extends AbstractModel implements Model {
  @override
  void subscribe(
    AVStreamType type,
    Callback success,
    Callback audio,
    Callback video,
    StateCallback error,
  ) async {
    List<RCRTCInputStream> streams = await RCRTCEngine.getInstance().getRoom()!.getLiveStreams();

    int code = await RCRTCEngine.getInstance().getRoom()!.localUser.unsubscribeStreams(streams);
    print("unsubscribe code = $code");

    await _subscribe(streams, type, audio, video);

    success(null);

    RCRTCEngine.getInstance().getRoom()!.onPublishLiveStreams = (streams) async {
      await _subscribe(streams, type, audio, video);
    };

    RCRTCEngine.getInstance().getRoom()!.onUnPublishLiveStreams = (streams) async {
      int code = await RCRTCEngine.getInstance().getRoom()!.localUser.unsubscribeStreams(streams);
      var audios = streams.whereType<RCRTCAudioInputStream>();
      if (audios.isNotEmpty) audio(null);
      var videos = streams.whereType<RCRTCVideoInputStream>();
      if (videos.isNotEmpty) video(null);
      print("unsubscribe code = $code");
    };
  }

  Future<void> _subscribe(
    var streams,
    final AVStreamType type,
    final Callback audio,
    final Callback video,
  ) async {
    List<RCRTCInputStream> subs = [];
    var audios = streams.whereType<RCRTCAudioInputStream>();
    bool containAudioStream = type == AVStreamType.audio_video || type == AVStreamType.audio_video_tiny || type == AVStreamType.audio;
    if (audios.isNotEmpty && containAudioStream) {
      audio(audios.first);
      subs.add(audios.first);
    }
    var videos = streams.whereType<RCRTCVideoInputStream>();
    bool containVideoStream = type == AVStreamType.audio_video || type == AVStreamType.audio_video_tiny || type == AVStreamType.video_tiny || type == AVStreamType.video;
    if (videos.isNotEmpty && containVideoStream) {
      video(videos.first);
      subs.add(videos.first);
    }
    int code = await RCRTCEngine.getInstance().getRoom()!.localUser.subscribeStreams(subs, tiny: type == AVStreamType.audio_video_tiny || type == AVStreamType.video_tiny);
    print("subscribe code = $code");
  }

  @override
  Future<bool> changeSpeaker(bool enable) async {
    await RCRTCEngine.getInstance().enableSpeaker(enable);
    return enable;
  }

  @override
  void exit() async {
    await RCRTCEngine.getInstance().leaveRoom();
    RCRTCEngine.getInstance().unRegisterStatusReportListener();
    await RCRTCEngine.getInstance().unInit();
  }
}
