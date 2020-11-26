import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/screenutil.dart';

void init(BuildContext context) {
  ScreenUtil.init(context);
}

extension NumExtension on num {
  get width {
    if (this != null)
      return ScreenUtil().setWidth(this);
    else
      return null;
  }

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
