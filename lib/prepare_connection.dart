import 'dart:convert';

import 'package:flutter_webrtc/webrtc.dart';

Map<String, dynamic> _iceServers = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
  ],
};

Map<String, dynamic> _config = {
  'mandatory': {},
  'optional': [
    {'DtlsSrtpKeyAgreement': true},
  ],
};

final Map<String, dynamic> _dc_constraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

class PrepareConnection {
  // peerConnection setting
  Future<RTCPeerConnection> createSelfInfo() async {
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);
    return pc;
  }

  // getSelfSDP
  Future<RTCSessionDescription> createOffer(RTCPeerConnection pc) async {
    RTCSessionDescription s = await pc
        .createOffer(_dc_constraints);
    return s;
  }

  Future<RTCSessionDescription> createAnswer(RTCPeerConnection pc) async {
    RTCSessionDescription s = await pc.createAnswer(_dc_constraints);
    return s;
  }
}