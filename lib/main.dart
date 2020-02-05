import 'package:flutter/material.dart';
import 'package:flutter_webrtc_chirp/before_connect.dart';
import 'package:flutter_webrtc_chirp/prepare_connection.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebRTC Chirp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataChannelWidget(title: 'Flutter Demo Home Page'),
    );
  }
}

class DataChannelWidget extends StatefulWidget {
  DataChannelWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DataChannelWidgetState createState() => _DataChannelWidgetState();
}

class _DataChannelWidgetState extends State<DataChannelWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BeforeConnection(),
    );
  }
}
