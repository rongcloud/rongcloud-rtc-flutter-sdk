// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:rongcloud_rtc_plugin/rongcloud_rtc_plugin.dart';
//
// class StreamConfig {
//   static const int AudioVideo = 0;
//   static const int Audio = 1;
//   static const int Video = 2;
//
//   List<bool> _stream = [false, false, false];
//
//   set audioVideo(bool value) {
//     _stream[AudioVideo] = value;
//     _stream[Audio] = value;
//     _stream[Video] = value;
//   }
//
//   bool get audioVideo => _stream[AudioVideo];
//
//   set audio(bool value) {
//     _stream[Audio] = value;
//     _stream[Audio] == _stream[Video] ? _stream[AudioVideo] = value : _stream[AudioVideo] = false;
//   }
//
//   get audio => _stream[Audio];
//
//   set video(bool value) {
//     _stream[Video] = value;
//     _stream[Audio] == _stream[Video] ? _stream[AudioVideo] = value : _stream[AudioVideo] = false;
//   }
//
//   get video => _stream[Video];
// }
//
// class FunctionConfig {
//   RCRTCVideoResolution resolutionIndex = RCRTCVideoResolution.RESOLUTION_720_1280;
//   bool speakerEnable = true;
// }
//
// class VideoSettingsPanel extends StatefulWidget {
//   final StreamConfig streamConfig;
//   final FunctionConfig functionConfig;
//   final ValueChanged<int> onStreamChanged;
//   final ValueChanged<RCRTCVideoResolution> onResolutionChanged;
//   final ValueChanged<bool> onSpeakerChanged;
//
//   VideoSettingsPanel({
//     this.streamConfig,
//     this.functionConfig,
//     this.onStreamChanged,
//     this.onResolutionChanged,
//     this.onSpeakerChanged,
//   });
//
//   @override
//   State<StatefulWidget> createState() => _VideoSettingsPanel();
// }
//
// class _VideoSettingsPanel extends State<VideoSettingsPanel> with SingleTickerProviderStateMixin {
//   TabController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(height: ScreenUtil().setHeight(10)),
//         SizedBox(
//           height: ScreenUtil().setHeight(28),
//           child: TabBarView(
//             controller: _controller,
//             children: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ToggleButtons(
//                     borderRadius: BorderRadius.circular(ScreenUtil().setWidth(30)),
//                     isSelected: widget.streamConfig._stream,
//                     children: <Widget>[
//                       Text('AV'),
//                       Text('Audio'),
//                       Text('Video'),
//                     ],
//                     onPressed: (index) {
//                       setState(() {
//                         switch (index) {
//                           case StreamConfig.AudioVideo:
//                             widget.streamConfig.audioVideo = !widget.streamConfig.audioVideo;
//                             break;
//                           case StreamConfig.Audio:
//                             widget.streamConfig.audio = !widget.streamConfig.audio;
//                             break;
//                           case StreamConfig.Video:
//                             widget.streamConfig.video = !widget.streamConfig.video;
//                             break;
//                           default:
//                             assert(false);
//                         }
//                       });
//                       widget.onStreamChanged(index);
//                     },
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
//                       borderRadius: BorderRadius.all(Radius.circular(20)),
//                     ),
//                     padding: const EdgeInsets.only(left: 10),
//                     child: DropdownButton(
//                       value: widget.functionConfig.resolutionIndex,
//                       underline: Container(),
//                       items: [
//                         DropdownMenuItem(
//                           child: Text('240x320'),
//                           value: RCRTCVideoResolution.RESOLUTION_240_320,
//                         ),
//                         DropdownMenuItem(
//                           child: Text('480x640'),
//                           value: RCRTCVideoResolution.RESOLUTION_480_640,
//                         ),
//                         DropdownMenuItem(
//                           child: Text('720x1280'),
//                           value: RCRTCVideoResolution.RESOLUTION_720_1280,
//                         ),
//                       ],
//                       onChanged: (value) {
//                         widget.onResolutionChanged(value);
//                         setState(() {
//                           widget.functionConfig.resolutionIndex = value;
//                         });
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Text("Speaker:"),
//                         Checkbox(
//                           value: widget.functionConfig.speakerEnable,
//                           activeColor: Colors.red,
//                           onChanged: (value) {
//                             setState(() {
//                               widget.functionConfig.speakerEnable = value;
//                             });
//                             widget.onSpeakerChanged(value);
//                           },
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: ScreenUtil().setWidth(40),
//           child: TabBar(
//             isScrollable: true,
//             labelPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
//             controller: _controller,
//             indicator: const BoxDecoration(),
//             labelColor: Colors.black,
//             unselectedLabelColor: Colors.grey,
//             tabs: [
//               Tab(text: 'Stream'),
//               Tab(text: 'Function'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class VideoCoreButtonPanel extends StatefulWidget {
//   final VoidCallback onSettingsPressed;
//   final VoidCallback onHangUpPressed;
//   final VoidCallback onSwitchCameraPressed;
//
//   VideoCoreButtonPanel({
//     this.onSettingsPressed,
//     this.onHangUpPressed,
//     this.onSwitchCameraPressed,
//   });
//
//   @override
//   State<StatefulWidget> createState() => _VideoCoreButtonPanel();
// }
//
// class _VideoCoreButtonPanel extends State<VideoCoreButtonPanel> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: ScreenUtil().setHeight(90),
//       color: Colors.black,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           FlatButton(
//             color: Colors.grey,
//             child: Icon(Icons.settings),
//             padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
//             shape: CircleBorder(),
//             onPressed: () {
//               if (widget.onSettingsPressed != null) widget.onSettingsPressed();
//             },
//           ),
//           SizedBox(width: ScreenUtil().setWidth(25)),
//           FlatButton(
//             color: Colors.red,
//             child: Icon(Icons.call_end, size: ScreenUtil().setWidth(35)),
//             padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
//             shape: CircleBorder(),
//             onPressed: () {
//               if (widget.onHangUpPressed != null) widget.onHangUpPressed();
//             },
//           ),
//           SizedBox(width: ScreenUtil().setWidth(25)),
//           FlatButton(
//             color: Colors.grey,
//             child: Icon(Icons.switch_camera),
//             padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
//             shape: CircleBorder(),
//             onPressed: () {
//               if (widget.onSwitchCameraPressed != null) widget.onSwitchCameraPressed();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class VideoMinorView extends SizedBox {
//   final RCRTCVideoView videoView;
//
//   VideoMinorView(this.videoView)
//       : super(
//           key: UniqueKey(),
//           width: ScreenUtil().setWidth(90),
//           height: ScreenUtil().setHeight(120),
//           child: videoView,
//         );
// }
//
// class VideoMinorViewList extends StatelessWidget {
//   final List<Widget> minorViewList;
//
//   VideoMinorViewList(this.minorViewList);
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: minorViewList.length,
//       itemBuilder: (context, index) => minorViewList[index],
//     );
//   }
// }
