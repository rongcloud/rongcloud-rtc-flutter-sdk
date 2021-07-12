import 'package:rc_rtc_flutter_example/data/data.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/model.dart';
import 'package:rc_rtc_flutter_example/frame/template/mvp/presenter.dart';
import 'package:flutter/widgets.dart';
import 'package:rongcloud_rtc_plugin/rcrtc_error_code.dart';
import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';

import 'meeting_page_contract.dart';
import 'meeting_page_model.dart';

class MeetingPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return MeetingPageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Config config = Config.fromJson(arguments);

    view.onLocalViewCreated(await model.createLocalView());

    await changeVideoConfig(config.videoConfig);
    await changeMic(config.mic);
    await changeSpeaker(config.speaker);

    RCRTCVideoStreamConfig tinyConfig = RCRTCVideoStreamConfig(
      100,
      300,
      RCRTCFps.fps_15,
      RCRTCVideoResolution.RESOLUTION_180_320,
    );

    await changeTinyVideoConfig(tinyConfig);

    RCRTCRoom? room = RCRTCEngine.getInstance().getRoom();
    room?.remoteUserList.forEach((user) {
      view.onUserJoin(User.remote(user.id));
      var audios = user.streamList.whereType<RCRTCAudioInputStream>();
      if (audios.isNotEmpty) view.onUserAudioStatusChanged(user.id, true);
      var videos = user.streamList.whereType<RCRTCVideoInputStream>();
      if (videos.isNotEmpty) view.onUserVideoStatusChanged(user.id, true);
    });
    room?.onRemoteUserJoined = (user) {
      view.onUserJoin(User.remote(user.id));
    };
    room?.onRemoteUserOffline = (user) {
      view.onUserLeft(user.id);
    };
    room?.onRemoteUserLeft = (user) {
      view.onUserLeft(user.id);
    };
    room?.onRemoteUserPublishResource = (user, streams) {
      var audios = streams.whereType<RCRTCAudioInputStream>();
      if (audios.isNotEmpty) view.onUserAudioStatusChanged(user.id, true);
      var videos = streams.whereType<RCRTCVideoInputStream>();
      if (videos.isNotEmpty) view.onUserVideoStatusChanged(user.id, true);
    };
    room?.onRemoteUserUnPublishResource = (user, streams) {
      var audios = streams.whereType<RCRTCAudioInputStream>();
      if (audios.isNotEmpty) view.onUserAudioStatusChanged(user.id, false);
      var videos = streams.whereType<RCRTCVideoInputStream>();
      if (videos.isNotEmpty) view.onUserVideoStatusChanged(user.id, false);
    };
    room?.onRemoteUserDisableMicrophone = (user, stream, disable) {
      print("onRemoteUserDisableMicrophone disable = $disable");
    };
    room?.onRemoteUserDisableCamera = (user, stream, disable) {
      print("onRemoteUserDisableCamera disable = $disable");
    };
  }

  @override
  Future<void> setEncoderMirror(bool mirror) {
    return model.setEncoderMirror(mirror);
  }

  @override
  Future<bool> muteAudio(bool mute) {
    return model.muteAudio(mute);
  }

  @override
  Future<bool> muteVideo(bool mute) {
    return model.muteVideo(mute);
  }

  @override
  Future<bool> changeMic(bool open) {
    return model.changeMic(open);
  }

  @override
  Future<bool> changeCamera(bool open) {
    return model.changeCamera(open);
  }

  @override
  Future<bool> changeAudio(bool publish) {
    return model.changeAudio(publish);
  }

  @override
  Future<bool> changeVideo(bool publish) {
    return model.changeVideo(publish);
  }

  @override
  Future<bool> changeFrontCamera(bool front) {
    return model.changeFrontCamera(front);
  }

  @override
  Future<bool> changeSpeaker(bool open) {
    return model.changeSpeaker(open);
  }

  @override
  Future<void> changeVideoConfig(RCRTCVideoStreamConfig config) async {
    await model.changeVideoConfig(config);
  }

  @override
  Future<bool> changeTinyVideoConfig(RCRTCVideoStreamConfig config) {
    return model.changeTinyVideoConfig(config);
  }

  @override
  void switchToNormalStream(String id) {
    model.switchToNormalStream(id);
  }

  @override
  void switchToTinyStream(String id) {
    model.switchToTinyStream(id);
  }

  @override
  Future<RCRTCAudioInputStream?> changeRemoteAudioStatus(String id, bool subscribe) {
    return model.changeRemoteAudioStatus(id, subscribe);
  }

  @override
  Future<RCRTCVideoInputStream?> changeRemoteVideoStatus(String id, bool subscribe) {
    return model.changeRemoteVideoStatus(id, subscribe);
  }

  @override
  void exit() async {
    int code = await model.exit();
    if (code != RCRTCErrorCode.OK)
      view.onExitWithError(code);
    else
      view.onExit();
  }
}
