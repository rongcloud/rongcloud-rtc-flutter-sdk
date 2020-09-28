import 'dart:convert';
import 'dart:io';
import 'package:FlutterRTC/frame/network/network.dart';
import 'package:FlutterRTC/frame/utils/local_storage.dart';
import 'package:FlutterRTC/global_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Platform.environment['DART_VM_OPTIONS'].contains('-DSILENT_OBSERVATORY=true');
  // Process.start('bash', ['-c', 'export', 'DART_VM_OPTIONS=-DSILENT_OBSERVATORY=true']).then((process) {
  //
  // });

  group("Test Utils", () {

    test("test LocalStorage", () async {
      await LocalStorage.init();
      LocalStorage.setString("test", "LocalStorage");
      expect(LocalStorage.getString("test"), "LocalStorage");
    });

    test("test Http", () async {
      CancelToken _tag;
      Map<String, dynamic> rooms;
      await Http.get(
        GlobalConfig.host + '/live_room',
        null,
        (error, data) {
          rooms = jsonDecode(data);
        },
        (error) {
          print("loadLiveRoomList error, error = $error");
        },
        _tag,
      );
      expect(rooms.values != null, true);
    });

  });

}
