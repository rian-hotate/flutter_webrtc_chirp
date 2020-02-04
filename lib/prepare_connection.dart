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
  Future<dynamic> createSelfInfo() async {
    // peerConnection setting
    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);

    // getSelfSDP
    RTCSessionDescription s = await pc
        .createOffer(_dc_constraints);
    print(s.sdp);
    return pc;
  }
}