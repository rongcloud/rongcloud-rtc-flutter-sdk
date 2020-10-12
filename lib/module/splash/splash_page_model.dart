import 'package:FlutterRTC/frame/template/mvp/model.dart';
import 'package:FlutterRTC/module/splash/splash_page_contract.dart';
import 'package:FlutterRTC/frame/utils/local_storage.dart';

class SplashPageModel extends AbstractModel implements Model {
  @override
  void preload(Function() onPreloadSuccess, Function(String info) onPreloadError) {
    try {
      LocalStorage.init().catchError((e) {
        onPreloadError(e.toString());
      }).whenComplete(() => onPreloadSuccess());
    } on Exception catch (e) {
      onPreloadError(e.toString());
    }
  }
}
