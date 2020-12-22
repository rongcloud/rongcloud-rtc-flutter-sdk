import 'dart:ui';

import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../colors.dart';

class BottomSheetStyleSliderTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

extension StringExtension on String {
  Widget toBottomSheetStyleSlider({
    @required double current,
    double min = 0,
    @required double max,
    void Function(double value) onChanged,
  }) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 15.dp),
          child: Text(
            this,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(ContextHolder.currentContext).copyWith(
              activeTrackColor: ColorConfig.bottomSheetSliderActiveColor,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: Colors.white,
              trackHeight: 2.dp,
              trackShape: BottomSheetStyleSliderTrackShape(),
              overlayColor: Colors.transparent,
            ),
            child: Slider(
              value: current,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget toConfigStyleSwitcher({
    @required bool value,
    bool padding = true,
    void Function() onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: padding
            ? EdgeInsets.symmetric(
                horizontal: 20.dp,
                vertical: 12.dp,
              )
            : EdgeInsets.zero,
        child: Row(
          children: [
            Text(
              this,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                decoration: TextDecoration.none,
              ),
            ),
            Spacer(),
            (value ? 'switcher_on' : 'switcher_off').imagePNG,
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget toConfigStyleSetter({
    @required String value,
    bool forward = false,
    void Function() onTap,
  }) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            this,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              decoration: TextDecoration.none,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              color: forward ? Colors.white.withOpacity(0.7) : Colors.white,
              fontSize: 15.sp,
              decoration: TextDecoration.none,
            ),
          ),
          forward
              ? Padding(
                  padding: EdgeInsets.only(left: 4.dp),
                  child: Opacity(
                    opacity: 0.7,
                    child: 'pop_page_navigator_forward'.png.image,
                  ),
                )
              : Container(),
        ],
      ),
    ).toButton(
      onPressed: onTap,
    );
  }

  Widget toLabelButton({
    Color color,
    void Function() onPressed,
  }) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 5.dp,
          horizontal: 17.dp,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2.dp),
            border: Border.all(
              color: color,
              width: 1.dp,
              style: BorderStyle.solid,
            )),
        child: Text(
          this,
          softWrap: true,
          style: TextStyle(
            color: color,
            fontSize: 15.sp,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      onTap: onPressed,
    );
  }

  Widget toRedLabelButton({
    void Function() onPressed,
  }) {
    return toLabelButton(
      color: Colors.redAccent,
      onPressed: onPressed,
    );
  }

  Widget toBlueLabelButton({
    void Function() onPressed,
  }) {
    return toLabelButton(
      color: Colors.lightBlue,
      onPressed: onPressed,
    );
  }

  String get png {
    assert(!this.startsWith('assets') && !this.endsWith('.png'), '$this is a image assets path already.');
    return 'assets/images/$this.png';
  }

  String get jpg {
    assert(!this.startsWith('assets') && !this.endsWith('.jpg'), '$this is a image assets path already.');
    return 'assets/images/$this.jpg';
  }

  Image get image {
    assert(this.startsWith('assets') && (this.endsWith('.png') || this.endsWith('.jpg')), '$this is not a image assets path.');
    return Image.asset(this);
  }

  Image get fullImage {
    assert(this.startsWith('assets') && (this.endsWith('.png') || this.endsWith('.jpg')), '$this is not a image assets path.');
    return Image.asset(
      this,
      fit: BoxFit.fill,
    );
  }

  AssetImage get assetImage {
    assert(this.startsWith('assets') && (this.endsWith('.png') || this.endsWith('.jpg')), '$this is not a image assets path.');
    return AssetImage(this);
  }

  Image get imagePNG {
    return this.png.image;
  }

  Widget toPNGButton({
    void Function() onPressed,
  }) {
    return this.imagePNG.toButton(onPressed: onPressed);
  }
}

extension WidgetExtension on Widget {
  Widget toButton({
    void Function() onPressed,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: this,
      onTap: onPressed,
    );
  }
}

Widget selectedRadio() {
  return 'radio_selected'.imagePNG;
}

Widget unselectedRadio() {
  return 'radio_unselected'.imagePNG;
}

Widget bottomSheetStyleButton({
  @required String icon,
  @required String title,
  void Function() onPressed,
}) {
  return TextButton(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon.png.image,
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ),
    onPressed: onPressed,
  );
}
