import 'package:flutter/material.dart';

class VideoSession {
  String userId;
  Widget view;
  int viewId;
  double width;
  double height;

  void updateSize(double width,double height) {
    this.width = width;
    this.height = height;
  }
}