import 'package:FlutterRTC/data/codes.dart';
import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/data/data.dart';
import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/widgets/texture_view.dart';
import 'package:flutter/widgets.dart';

import 'meeting_page_contract.dart';
import 'meeting_page_model.dart';

class MeetingPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  IModel createModel() {
    return MeetingPageModel();
  }

  @override
  Future<void> init(BuildContext context) async {
    subscribe();
  }

  @override
  void subscribe() {
    model?.subscribe(
      (view) {
        this.view?.onUserJoined(view);
      },
      (uid, audio) {
        this.view?.onUserAudioStreamChanged(uid, audio);
      },
      (uid, stream) {
        this.view?.onUserVideoStreamChanged(uid, stream);
      },
      (uid) {
        this.view?.onUserLeaved(uid);
      },
    );
  }

  void publish(Config config) async {
    StatusCode code = await model?.publish(
      config,
      (view) {
        this.view?.onUserJoined(view);
      },
      (uid, audio) {
        view?.onUserAudioStreamChanged(uid, audio);
      },
      (uid, stream) {
        view?.onUserVideoStreamChanged(uid, stream);
      },
    );
    if (code.status == Status.ok) {
      view?.onPublished();
    } else {
      view?.onPublishError(code.message);
    }
  }

  @override
  Future<bool> switchCamera() {
    return model?.switchCamera();
  }

  @override
  void changeAudioStreamState(Config config) {
    model?.changeAudioStreamState(config, (uid, audio) {
      view?.onUserAudioStreamChanged(uid, audio);
    });
  }

  @override
  void changeVideoStreamState(Config config) {
    model?.changeVideoStreamState(config, (uid, stream) {
      view?.onUserVideoStreamChanged(uid, stream);
    });
  }

  @override
  void changeRemoteAudioStreamState(UserView view) {
    model?.changeRemoteAudioStreamState(view, (uid, audio) {
      this.view?.onUserAudioStreamChanged(uid, audio);
    });
  }

  @override
  void changeRemoteVideoStreamState(UserView view) {
    model?.changeRemoteVideoStreamState(view, (uid, stream) {
      this.view?.onUserVideoStreamChanged(uid, stream);
    });
  }

  @override
  void unsubscribeRemoteAudioStreams(List<UserView> views) {
    model?.unsubscribeRemoteAudioStreams(views);
  }

  @override
  void subscribeRemoteAudioStreams(List<UserView> views) {
    model?.unsubscribeRemoteAudioStreams(views);
  }

  @override
  void unsubscribeRemoteVideoStreams(List<UserView> views) {
    model?.unsubscribeRemoteVideoStreams(views);
  }

  @override
  void subscribeRemoteVideoStreams(List<UserView> views) {
    model?.unsubscribeRemoteVideoStreams(views);
  }

  @override
  void changeAudioStreamConfig(Config config) {
    model?.changeAudioStreamConfig(config);
  }

  @override
  void changeVideoStreamConfig(Config config) {
    model?.changeVideoStreamConfig(config);
  }

  @override
  Future<StatusCode> exit() {
    return model?.exit();
  }
}
