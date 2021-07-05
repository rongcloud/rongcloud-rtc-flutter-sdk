import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void init(BuildContext context) {
  ScreenUtil.init(
    BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
      maxHeight: MediaQuery.of(context).size.height,
    ),
    designSize: Size(375, 667),
    orientation: Orientation.portrait,
  );
}

extension NumExtension on num {
  get dp {
    return ScreenUtil().scaleWidth < ScreenUtil().scaleHeight ? ScreenUtil().setWidth(this) : ScreenUtil().setHeight(this);
  }

  @Deprecated('Use dp instead')
  get width {
    return ScreenUtil().setWidth(this);
  }

  @Deprecated('Use dp instead')
  get height {
    return ScreenUtil().setHeight(this);
  }

  get sp {
    return ScreenUtil().setSp(this);
  }

  get spWithSystemScaling {
    return ScreenUtil().setSp(this);
  }
}

extension StringExtension on String {
  num get toInt {
    final regexp = RegExp(r'[^0-9]');
    return int.parse(this.replaceAll(regexp, ''));
  }

  num get toDouble {
    final regexp = RegExp(r'[^0-9.]');
    return double.parse(this.replaceAll(regexp, ''));
  }
}
