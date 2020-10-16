import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

abstract class IModel {
  void dispose();
}

abstract class AbstractModel implements IModel {
  CancelToken _tag;

  CancelToken get tag => _tag;

  AbstractModel() {
    _tag = CancelToken();
  }

  @mustCallSuper
  @override
  void dispose() {
    _tag.cancel();
  }
}
