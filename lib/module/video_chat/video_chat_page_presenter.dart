import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/frame/template/mvp/presenter.dart';
import 'package:FlutterRTC/frame/template/mvp/view.dart';
import 'package:FlutterRTC/module/video_chat/video_chat_page_contract.dart';
import 'package:FlutterRTC/module/video_chat/video_chat_page_mode.dart';
import 'package:flutter/src/widgets/framework.dart';

class VideoChatPagePresenter extends AbstractPresenter<View, Model> implements Presenter {
  @override
  void attachView(IView view, BuildContext context) {
    super.attachView(view, context);
  }

  @override
  void detachView() {
    super.detachView();
  }

  @override
  IModel createModel() {
    return VideoChatPageModel();
  }

  @override
  void init(BuildContext context) {

  }

}