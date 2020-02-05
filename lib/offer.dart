import 'dart:convert';
import 'dart:typed_data';

import 'package:chirp_flutter/chirp_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:flutter_webrtc_chirp/offer_bloc.dart';
import 'package:flutter_webrtc_chirp/prepare_connection.dart';
import 'package:permission/permission.dart';
import 'package:provider/provider.dart';

import 'before_connect.dart';
import 'key.dart';

class Offer extends StatefulWidget {
  final Function changeMode;

  Offer({Key key, @required this.changeMode}) : super(key: key);

  @override
  _OfferState createState() => _OfferState();
}

class _OfferState extends State<Offer> {
  RTCPeerConnection peerConnection;
  RTCSessionDescription _data;
  OfferBloc offerBloc;
  String _sessionId = "abc123";

  // use key.dart
  String _appKey = CHIRP_APP_KEY;
  String _appSecret = CHIRP_APP_SECRET;
  String _appConfig = CHIRP_APP_CONFIG;

  Future<void> _initChirp() async => await ChirpSDK.init(_appKey, _appSecret);
  Future<void> _configChirp() async => await ChirpSDK.setConfig(_appConfig);
  Future<void> _sendChirp(Uint8List data) async => ChirpSDK.send(data);
  Future<void> _startAudioProcessing() async => await ChirpSDK.start();

  Future<void> _requestPermissions() async {
    Permission.getPermissionsStatus([PermissionName.Microphone]);
    Permission.requestPermissions([PermissionName.Microphone]);
  }

  _createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      print("get");
    };
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initChirp();
    _configChirp();
    _startAudioProcessing();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    offerBloc =  OfferBloc();
    return Center(
      child:  MultiProvider(
        providers: [
          Provider<OfferBloc>(
            create: (context) => offerBloc,
          ),
        ],
        child: Column(
          children: <Widget>[
            FlatButton(
              onPressed: () {
                widget.changeMode(MODE.none);
              },
              child: Text("戻る"),
            ),
            Text("send self SDP"),
            Expanded(
              child: Center(
                child: FlatButton(
                  color: Colors.blueAccent,
                  onPressed: () {
                    PrepareConnection().createSelfInfo().then((value) {
                      peerConnection = value;
                      PrepareConnection().createOffer(value).then((data) {
                        peerConnection.setLocalDescription(data);
                        _data = data;
                        print(data.sdp);
                        offerBloc.getSDPBlocSink.add(data);
                      });
                    });
                  },
                  child: Text("get SDP"),
                ),
              ),
            ),
            StreamBuilder<RTCSessionDescription>(
              stream: offerBloc.getSDPBlocStream,
              builder: (context, snapshot) {
                if(!snapshot.hasData) return Container();
                List<Widget> item = [];
                int cnt = 1;
                snapshot.data.sdp.split(" ").forEach((str) {
                  item.add(
                      RaisedButton(
                        child: Text(
                            'SEND SDP $cnt',
                            style: TextStyle(fontFamily: 'MarkPro')
                        ),
                        color: Colors.deepOrangeAccent,
                        onPressed: () {
                          print(str);

                          var payload = new Uint8List.fromList(str.codeUnits);
                          _sendChirp(payload);
                        },
                      ),
                  );
                  cnt++;
                });
                item.add(
                  RaisedButton(
                    child: Text(
                        'SEND TYPE',
                        style: TextStyle(fontFamily: 'MarkPro')
                    ),
                    color: Colors.deepOrangeAccent,
                    onPressed: () {
                      print(snapshot.data.type);

                      var payload = new Uint8List.fromList(snapshot.data.type.codeUnits);
                      _sendChirp(payload);
                    },
                  ),
                );
                return SingleChildScrollView(
                  child: Column(
                    children: item,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}