import 'package:flutter_test/flutter_test.dart';
import 'package:rongcloud_rtc_plugin/agent/rcrtc_engine.dart';

void main() {

  group("Test RCRTCEngine Interface", () {
    test("test init ", () async {
      await RCRTCEngine.getInstance().init(null);
      expect(RCRTCEngine.getInstance().unInit(), true);
    });

  });
}
