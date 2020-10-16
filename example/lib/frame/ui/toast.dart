import 'package:flutter/material.dart';

class Toast {
  static void show(BuildContext context, String message, {int duration}) {
    OverlayEntry entry = OverlayEntry(builder: (context) {
      return Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.7,
        ),
        alignment: Alignment.center,
        child: Center(
          child: Container(
            color: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      );
    });

    Overlay.of(context).insert(entry);
    Future.delayed(Duration(seconds: duration ?? 2)).then((value) {
      entry.remove();
    });
  }
}
