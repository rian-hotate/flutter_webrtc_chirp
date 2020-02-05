import 'package:chirp_flutter/chirp_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:flutter_webrtc_chirp/prepare_connection.dart';
import 'package:permission/permission.dart';

import 'before_connect.dart';
import 'key.dart';

enum ANSWER_MODE { none, sdp, type }

class Answer extends StatefulWidget {
  final Function changeMode;

  const Answer({Key key, @required this.changeMode}) : super(key: key);

  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  ANSWER_MODE mode = ANSWER_MODE.none;

  RTCPeerConnection peerConnection;
  RTCSessionDescription _data;

  String _appKey = CHIRP_APP_KEY;
  String _appSecret = CHIRP_APP_SECRET;
  String _appConfig = CHIRP_APP_CONFIG;

  List<String> getSdp = [];
  String getType;

  String get remoteSdp => _getSdpString(getSdp);

  Future<void> _initChirp() async => await ChirpSDK.init(_appKey, _appSecret);

  Future<void> _configChirp() async => await ChirpSDK.setConfig(_appConfig);

  Future<void> _startAudioProcessing() async => await ChirpSDK.start();

  Future<void> _requestPermissions() async {
    Permission.getPermissionsStatus([PermissionName.Microphone]);
    Permission.requestPermissions([PermissionName.Microphone]);
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initChirp();
    _configChirp();
    _startAudioProcessing();

    PrepareConnection().createSelfInfo().then((value) {
      peerConnection = value;
      PrepareConnection().createAnswer(value).then((data) {
        peerConnection.setLocalDescription(data);
        _data = data;
      });
    });
  }

  String _getSdpString(List<String> list) {
    String sdp = list[0];
    list.forEach((str) {
      if (sdp != str) {
        sdp += " " + str;
      }
    });
    return sdp;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: () {
              widget.changeMode(MODE.none);
            },
            child: Text("戻る"),
          ),
          Text("get partner SDP length = ${getSdp.length}"),
          mode != ANSWER_MODE.none
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(),
          mode == ANSWER_MODE.none && getSdp.length < 8
              ? RaisedButton(
                  child: Text("get remote SDP"),
                  onPressed: () {
                    setState(() {
                      mode = ANSWER_MODE.sdp;
                    });
                    ChirpSDK.onReceived.listen((e) {
                      String identifier = new String.fromCharCodes(e.payload);
                      print(identifier);
                      getSdp.add(identifier);
                      setState(() {
                        mode = ANSWER_MODE.none;
                      });
                    });
                  },
                )
              : Container(),
          mode == ANSWER_MODE.none && getType == null
              ? RaisedButton(
                  child: Text("get remote TYPE"),
                  onPressed: () {
                    setState(() {
                      mode = ANSWER_MODE.type;
                    });
                    ChirpSDK.onReceived.listen((e) {
                      String identifier = new String.fromCharCodes(e.payload);
                      print(identifier);
                      getType = identifier;
                      setState(() {
                        mode = ANSWER_MODE.none;
                      });
                    });
                  },
                )
              : Container(),
          getSdp.length == 8 && getType != null
              ? RaisedButton(
                  child: Text("set up connection"),
                  onPressed: () {
                    print(remoteSdp);
                    peerConnection.setRemoteDescription(RTCSessionDescription(remoteSdp, getType)).then((_) {
                      peerConnection
                    });
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}
