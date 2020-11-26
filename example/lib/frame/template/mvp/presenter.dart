import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'model.dart';
import 'view.dart';

abstract class IPresenter<V extends IView> {
  void attachView(V view, BuildContext context);

  void detachView();
}

abstract class AbstractPresenter<V extends IView, M extends IModel> implements IPresenter {
  V _view;
  M _model;

  V get view => _view;

  M get model => _model;

  @override
  void attachView(IView view, BuildContext context) {
    _view = view;
    _model = createModel();
    init(context);
  }

  @override
  void detachView() {
    if (_view != null) {
      _view = null;
    }
    if (_model != null) {
      _model.dispose();
      _model = null;
    }
  }

  @protected
  IModel createModel();

  @protected
  Future<dynamic> init(BuildContext context);
}
