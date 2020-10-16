import 'package:flutter/widgets.dart';

import 'presenter.dart';

abstract class IView {}

abstract class AbstractView extends StatefulWidget {}

abstract class AbstractViewState<P extends IPresenter, V extends AbstractView> extends State<V> implements IView {
  bool _first = true;

  P _presenter;

  P get presenter => _presenter;

  P createPresenter();

  @override
  Widget build(BuildContext context) {
    if (_first) {
      _first = false;
      _presenter = createPresenter();
      _presenter?.attachView(this, context);
    }
    return buildWidget(context);
  }

  Widget buildWidget(BuildContext context);

  @override
  void dispose() {
    _presenter?.detachView();
    _presenter = null;
    super.dispose();
  }
}
