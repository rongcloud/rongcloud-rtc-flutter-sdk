import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SetResolutionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text(
          "选择分辨率",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0.sp,
            decoration: TextDecoration.none,
          ),
        ),
        iconTheme: IconThemeData.fallback(),
        backgroundColor: Colors.white,
      ),
      body: ListView.separated(
        shrinkWrap: true,
        itemCount: Resolutions.length,
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey.shade300,
            height: 1.0.sp,
          );
        },
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Container(
              height: 40.0.height,
              color: Colors.white,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(
                left: 20.0.width,
                right: 20.0.width,
              ),
              child: Text(
                "${Resolutions[index]}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0.sp,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            onTap: () => _onSelectIndex(context, index),
          );
        },
      ),
    );
  }

  void _onSelectIndex(BuildContext context, int index) {
    Navigator.pop(context, index);
  }
}
