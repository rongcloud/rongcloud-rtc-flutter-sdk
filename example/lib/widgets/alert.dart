import 'package:FlutterRTC/colors.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';

class Alert {
  static void showAlert({
    String title,
    String message,
    String left,
    void Function() onPressedLeft,
    String right,
    void Function() onPressedRight,
  }) {
    List<Widget> buttons = List();
    if (left != null)
      buttons.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              left,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          onTap: onPressedLeft,
        ),
      );
    if (right != null)
      buttons.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              right,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          onTap: onPressedRight,
        ),
      );

    if (buttons.length > 1) {
      buttons.insert(1, Spacer());
      buttons.insert(
        1,
        VerticalDivider(
          width: 1.dp,
          color: ColorConfig.alertDividerColor.withOpacity(0.1),
        ),
      );
      buttons.insert(1, Spacer());
    }

    buttons.insert(0, Spacer());
    buttons.add(Spacer());

    List<Widget> columns = List();
    if (title != null)
      columns.add(
        Padding(
          padding: EdgeInsets.only(
            top: 20.dp,
            right: 20.dp,
            left: 20.dp,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
    if (message != null)
      columns.add(
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10.dp),
          constraints: BoxConstraints(
            minHeight: 96.dp,
          ),
          child: Text(
            message,
            softWrap: true,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );

    columns.add(
      Divider(
        height: 1.dp,
        color: ColorConfig.alertDividerColor.withOpacity(0.1),
      ),
    );

    columns.add(
      Container(
        height: 48.dp,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons,
        ),
      ),
    );

    showDialog(
      context: ContextHolder.currentContext,
      child: WillPopScope(
        child: Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.dp),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: ColorConfig.alertBackgroundColor,
              borderRadius: BorderRadius.circular(12.dp),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: columns,
            ),
          ),
        ),
        onWillPop: () {
          return Future.value(false);
        },
      ),
    );
  }
}
