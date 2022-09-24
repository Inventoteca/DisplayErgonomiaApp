import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_industry/screens/NavBar.dart';
import 'package:web_socket_channel/io.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class devicelist extends StatefulWidget {
  //const webSocket({Key? key}) : super(key: key);
  final User user;
  const devicelist({required this.user});

  @override
  State<devicelist> createState() => _devicelistState();
}

class _devicelistState extends State<devicelist> {
  late User _currentUser;
  late List<Tag> panelDataList;
  IOWebSocketChannel? channel;
  late bool connected; //boolean value to track if WebSocket is connected
  final data =
      '[ {"id_panel": "ABCDEF", "tipo": "ERGO"}, {"id_panel": "123456", "tipo": "CRUZ"}]';

  void initState() {
    _currentUser = widget.user;
    connected = false; //initially connection status is "NO" so its FALSE

    //_currentUser.updatePhotoURL(data);
    var dataList = jsonDecode(_currentUser.photoURL.toString());

    if (dataList != null) {
      //debugPrint('Paneles: $dataList');
      //panelDataList = dataList;
      var tagObjsJson =
          jsonDecode(_currentUser.photoURL.toString())['panels'] as List;

      List<Tag> tagObjs =
          tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();

      panelDataList = tagObjs;
      debugPrint('Paneles: $tagObjs ');
    } else {
      debugPrint('No hay panels');
    }

    // var tagObjsJson = jsonDecode(_currentUser.photoURL.toString())['panels'];
    //   ? jsonDecode(_currentUser.photoURL.toString())['panels'] as List
    //    : List.empty();
    //var tagObjsJson = _currentUser.photoURL;

    //List<Tag> tagObjs =
    //  tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();
    //debugPrint('Paneles: $tagObjsJson');
    //debugPrint('Paneles: ${_currentUser.photoURL}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(user: _currentUser),
        appBar: AppBar(
          title: Text('Dispositivos'),
        ),
        body: ListView.builder(
            itemCount: panelDataList.length,
            itemBuilder: (context, int index) {
              return Container(
                height: 80,
                //color: Colors.red,
                child: Center(
                  //child: Icon(iconsdata.values.elementAt(0)),
                  child: Text(
                    '${panelDataList.elementAt(index)}',
                    //'text',
                    //index.toString(),
                    style: TextStyle(fontSize: 10.0),
                  ),
                ),
              );
            }));
  }
}

class Tag {
  String idpanel;
  String tipo;

  Tag(this.idpanel, this.tipo);

  factory Tag.fromJson(dynamic json) {
    return Tag(json['id_panel'] as String, json['tipo'] as String);
  }

  @override
  String toString() {
    return '{ ${this.idpanel}, ${this.tipo} }';
  }
}
