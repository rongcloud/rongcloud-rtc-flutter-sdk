import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';

extension IconExtension on IconData {
  Widget get selected {
    return Container(
      width: 50.0.width,
      height: 50.0.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0.width),
        border: Border.all(
          color: Colors.grey,
          width: 3.0.width,
          style: BorderStyle.solid,
        ),
      ),
      child: Icon(
        this,
        size: 25.0.width,
        color: Colors.black87,
      ),
    );
  }

  Widget get unselected {
    return Container(
      width: 50.0.width,
      height: 50.0.width,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(25.0.width),
        border: Border.all(
          color: Colors.grey,
          width: 3.0.width,
          style: BorderStyle.solid,
        ),
      ),
      child: Icon(
        this,
        size: 25.0.width,
        color: Colors.white,
      ),
    );
  }

  Widget get red {
    return Container(
      width: 50.0.width,
      height: 50.0.width,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(25.0.width),
        border: Border.all(
          color: Colors.grey,
          width: 3.0.width,
          style: BorderStyle.solid,
        ),
      ),
      child: Icon(
        this,
        size: 25.0.width,
        color: Colors.white,
      ),
    );
  }

  Widget withBadge(String badge) {
    return Container(
      width: 50.0.width,
      height: 50.0.width,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: 50.0.width,
            height: 50.0.width,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(25.0.width),
              border: Border.all(
                color: Colors.grey,
                width: 3.0.width,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              this,
              size: 25.0.width,
              color: Colors.white,
            ),
          ),
          badge != null && badge.isNotEmpty
              ? Container(
                  width: 15.0.width,
                  height: 15.0.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(12.5.width),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 8.0.sp,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget get black54 {
    return Container(
      width: 36.0.width,
      height: 36.0.width,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(23.0.width),
      ),
      child: Icon(
        this,
        size: 20.0.width,
        color: Colors.white,
      ),
    );
  }
}

extension StringExtension on String {
  Widget get button {
    return Container(
      height: 35.0.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0.height),
        ),
        color: Colors.grey,
      ),
      child: Text(
        this,
        style: TextStyle(
          fontSize: 12.0.sp,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
