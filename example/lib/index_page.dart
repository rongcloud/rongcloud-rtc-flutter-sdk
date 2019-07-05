import 'package:flutter/material.dart';

import 'call_page.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _IndexPageState();
  }
}

class _IndexPageState extends State<IndexPage> {

  final _textController = TextEditingController();
  bool _validateError = false;

  onJoinRTCRoom() async {
    setState(() {
      _textController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });

    if (_textController.text.isNotEmpty) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => new CallPage(
                    roomId: _textController.text,
                  )));
    }
  }


  @override
  void dispose() {
    // dispose input controller
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        title: Text("RongCloud RTC"),
      ),
      body: Center(
        child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 400,
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[]),
                  Row(children: <Widget>[
                    Expanded(
                        child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                          errorText: _validateError
                              ? "RoomId is illegal"
                              : null,
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(width: 1)),
                          hintText: 'RoomId'),
                    ))
                  ]),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onJoinRTCRoom(),
                              child: Text("Join"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                      )
                    )
                ],
              )
              ),
      ),
    );
  }
}