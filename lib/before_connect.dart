import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'answer.dart';
import 'offer.dart';

enum MODE { none, offer, answer }

class BeforeConnection extends StatefulWidget {

  @override
  _BeforeConnectionState createState() => _BeforeConnectionState();
}

class _BeforeConnectionState extends State<BeforeConnection> {
  MODE mode = MODE.none;

  void changeMode(MODE m) {
    setState(() {
      mode = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch(mode) {

      case MODE.none:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200,
                child: FlatButton(
                  color: Colors.blueAccent,
                  onPressed: () {
                    setState(() {
                      mode = MODE.offer;
                    });
                  },
                  child: Text("offer SDP"),
                ),
              ),
              SizedBox(
                height: 200,
              ),
              Container(
                width: 200,
                child: FlatButton(
                  color: Colors.blueAccent,
                  onPressed: () {
                    setState(() {
                      mode = MODE.answer;
                    });
                  },
                  child: Text("answer SDP"),
                ),
              ),
            ],
          ),
        );
        break;
      case MODE.offer:
        return Offer(changeMode: changeMode,);
        break;
      case MODE.answer:
        return Answer(changeMode: changeMode,);
        break;
    }
  }
}