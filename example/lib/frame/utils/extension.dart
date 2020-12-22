import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/screenutil.dart';

void init(BuildContext context) {
  ScreenUtil.init(context);
}

extension NumExtension on num {
  get dp {
    return ScreenUtil().scaleWidth < ScreenUtil().scaleHeight ? ScreenUtil().setWidth(this) : ScreenUtil().setHeight(this);
  }

  @Deprecated('Use dp instead')
  get width {
    if (this != null)
      return ScreenUtil().setWidth(this);
    else
      return null;
  }

  @Deprecated('Use dp instead')
  get height {
    if (this != null)
      return ScreenUtil().setHeight(this);
    else
      return null;
  }

  get sp {
    if (this != null)
      return ScreenUtil().setSp(this, allowFontScalingSelf: false);
    else
      return null;
  }

  get spWithSystemScaling {
    if (this != null)
      return ScreenUtil().setSp(this, allowFontScalingSelf: true);
    else
      return null;
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
