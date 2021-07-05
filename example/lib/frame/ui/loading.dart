import 'package:flutter/material.dart';

class Loading {
  @protected
  Loading(this._retain, this._entry);

  static void show(BuildContext context) {
    Loading? loading = _cache[context];
    if (loading == null) {
      loading = Loading(0, _buildLoading(context));
    }
    loading._retain++;
    _cache[context] = loading;
  }

  static OverlayEntry _buildLoading(BuildContext context) {
    OverlayEntry entry = OverlayEntry(builder: (context) {
      return WillPopScope(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withAlpha(150),
          alignment: Alignment.center,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                Divider(
                  height: 10,
                ),
                Text(
                  '加载中',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () {
          return Future.value(false);
        },
      );
    });

    Overlay.of(context)?.insert(entry);

    return entry;
  }

  static void dismiss(BuildContext context) {
    Loading? loading = _cache[context];
    if (loading != null) {
      loading._retain--;
      if (loading._retain <= 0) {
        loading._entry.remove();
        _cache[context] = null;
      }
    }
  }

  static Map<BuildContext, Loading?> _cache = Map();

  int _retain = 0;

  OverlayEntry _entry;
}
