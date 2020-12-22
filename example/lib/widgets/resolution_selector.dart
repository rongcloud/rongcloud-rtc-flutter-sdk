import 'package:FlutterRTC/data/constants.dart';
import 'package:FlutterRTC/frame/utils/extension.dart';
import 'package:FlutterRTC/widgets/buttons.dart';
import 'package:flutter/material.dart';

class ResolutionSelector extends StatelessWidget {
  ResolutionSelector({
    @required this.title,
    @required this.resolution,
    @required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 10.dp,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  resolution == Resolution.SD ? selectedRadio() : unselectedRadio(),
                  Padding(
                    padding: EdgeInsets.only(left: 5.dp),
                    child: Text(
                      '标清',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                onSelected(Resolution.SD);
              },
            ),
            Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  resolution == Resolution.HD ? selectedRadio() : unselectedRadio(),
                  Padding(
                    padding: EdgeInsets.only(left: 5.dp),
                    child: Text(
                      '高清',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                onSelected(Resolution.HD);
              },
            ),
            Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  resolution == Resolution.FHD ? selectedRadio() : unselectedRadio(),
                  Padding(
                    padding: EdgeInsets.only(left: 5.dp),
                    child: Text(
                      '超清',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                onSelected(Resolution.FHD);
              },
            ),
          ],
        ),
      ],
    );
  }

  final String title;
  final Resolution resolution;
  final Function(Resolution resolution) onSelected;
}
