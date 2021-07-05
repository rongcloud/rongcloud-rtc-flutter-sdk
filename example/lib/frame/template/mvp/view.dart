import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'presenter.dart';

abstract class IView {}

abstract class AbstractView extends StatefulWidget {}

abstract class AbstractViewState<P extends IPresenter, V extends AbstractView> extends State<V> implements IView {
  bool _first = true;

  late P _presenter;

  P get presenter => _presenter;

  P createPresenter();

  @override
  Widget build(BuildContext context) {
    Size size = designSize();

    ScreenUtil.init(
      BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      designSize: size,
      orientation: Orientation.portrait,
    );

    _init(context);

    return buildWidget(context);
  }

  Future<void> _init(BuildContext context) async {
    if (!_first) return;
    _first = false;

    _presenter = createPresenter();
    _presenter.attachView(this, context);

    init(context);
  }

  Size designSize() {
    return const Size(375, 667);
  }

  void init(BuildContext context) {}

  Widget buildWidget(BuildContext context);

  @override
  void dispose() {
    _presenter.detachView();
    super.dispose();
  }
}
