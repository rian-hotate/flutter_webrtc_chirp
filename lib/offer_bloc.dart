import 'dart:async';

import 'package:flutter_webrtc/webrtc.dart';

class OfferBloc {
  StreamController _getSDPBloc = StreamController<RTCSessionDescription>();

  Stream<RTCSessionDescription> get getSDPBlocStream => _getSDPBloc.stream;

  StreamSink<RTCSessionDescription> get getSDPBlocSink => _getSDPBloc.sink;

  void dispose() {
    _getSDPBloc.close();
  }
}