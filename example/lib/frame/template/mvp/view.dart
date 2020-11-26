import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    _init(context);
    return buildWidget(context);
  }

  Future<void> _init(BuildContext context) async {
    if (!_first) return;
    _first = false;

    Size size = designSize();
    ScreenUtil.init(context, width: size.width, height: size.height);

    _presenter = createPresenter();
    _presenter?.attachView(this, context);
    init(context);
  }

  Size designSize() {
    return const Size(640, 960);
  }

  void init(BuildContext context) {}

  Widget buildWidget(BuildContext context);

  @override
  void dispose() {
    _presenter?.detachView();
    _presenter = null;
    super.dispose();
  }
}
