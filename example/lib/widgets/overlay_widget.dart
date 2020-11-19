import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OverlayWidget extends StatefulWidget {
  Widget page;
  Size size;
  Icon icon;
  Text text;

  OverlayWidget(this.page, this.size, {Key key, this.icon, this.text}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OverlayWidgetState();
}


class _OverlayWidgetState extends State<OverlayWidget> {

  bool isShowing = false;
  OverlayEntry _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: widget.size, // button width and height
      child: ClipOval(
        child: Material(
          color: Colors.transparent, // button color
          child: InkWell(
            splashColor: Colors.green, // splash color
            onTap: () {
              if (isShowing) {
                hide();
              } else {
                show(context);
              }
              isShowing = !isShowing;
            }, // button pressed
            child: Center(
              child: widget.icon != null
                  ? widget.icon
                  : widget.text != null
                  ? widget.text
                  : Icon(Icons.add), // text,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    hide();
    super.dispose();
  }

  void show(BuildContext context) {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    _overlayEntry = new OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          child: widget.page,
        ));
    Overlay.of(context).insert(_overlayEntry);
  }

  void hide() {
    _overlayEntry.remove();
  }
}
