import 'package:flutter/widgets.dart';

import 'model.dart';
import 'view.dart';

abstract class IPresenter<V extends IView> {
  void attachView(V view, BuildContext context);

  void detachView();
}

abstract class AbstractPresenter<V extends IView, M extends IModel> implements IPresenter {
  late V _view;
  late M _model;

  V get view => _view;

  M get model => _model;

  @override
  void attachView(IView view, BuildContext context) {
    _view = view as V;
    _model = createModel() as M;
    init(context);
  }

  @override
  void detachView() {
    _model.dispose();
  }

  @protected
  IModel createModel();

  @protected
  Future<dynamic> init(BuildContext context);
}
