import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_industry/screens/NavBar.dart';
//import 'package:smart_industry/screens/.esp_touch.dart';
import 'package:smart_industry/screens/panelList_page.dart';
import 'package:smart_industry/screens/panel_page.dart';
import 'package:smart_industry/screens/device_add_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class DeviceList extends StatefulWidget {
  //const webSocket({Key? key}) : super(key: key);
  final User user;
  final String id = "";
  const DeviceList({required this.user});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  late User _currentUser;
  late List<Tag> panelDataList;

  late bool connected; //boolean value to track if WebSocket is connected
  //final data =
  //  '[ {"id": "3C:71:BF:FC:BF:94", "type": "ergo", "name":"Inventoteca", "mod":true}, {"id": "123456", "type": "cruz", "name": "Demo", "mod":false}]';

  final data = '[]';

  void initState() {
    _currentUser = widget.user;
    connected = false; //initially connection status is "NO" so its FALSE

    // _currentUser.updatePhotoURL(data); //Uncoment for Test only
    var dataList = jsonDecode(_currentUser.photoURL.toString());

    if (dataList != null) {
      var tagObjsJson = jsonDecode(_currentUser.photoURL.toString()) as List;

      List<Tag> tagObjs =
          tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();

      panelDataList = tagObjs;
      debugPrint('Panel: $panelDataList');
    } else {
      debugPrint('No hay panels');
      panelDataList = List.empty();

      /*if (panelDataList.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AddDevice(
              user: _currentUser,
            ),
          ),
        );
      }*/

      super.initState();
    }

    // var tagObjsJson = jsonDecode(_currentUser.photoURL.toString())['panels'];
    //   ? jsonDecode(_currentUser.photoURL.toString())['panels'] as List
    //    : List.empty();
    //var tagObjsJson = _currentUser.photoURL;

    //List<Tag> tagObjs =
    //  tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();
    //debugPrint('Paneles: $tagObjsJson');
    //debugPrint('Paneles: ${_currentUser.photoURL}');
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
            return ElevatedButton(
              //child: Text('${panelDataList.elementAt(index)}'),
              child: Text('${panelDataList.elementAt(index).nombre}'),
              onPressed: () => {
                //debugPrint('PanelPage'),
                //PanelPage(
                //  user: _currentUser,
                //)
                if (panelDataList.elementAt(index).tipo.compareTo("ergo") == 0)
                  {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PanelPage(
                            user: _currentUser,
                            id: panelDataList.elementAt(index).nombre),
                      ),
                    ),
                  }
                else if (panelDataList.elementAt(index).tipo == 'cruz')
                  {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PanelListPage(user: _currentUser),
                      ),
                    ),
                  }
                else // if (panelDataList.elementAt(index).tipo == 'cruz')
                  {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PanelListPage(user: _currentUser),
                      ),
                    ),
                  }
              },
              //color: Colors.red,
              //child: Center(
              //child: Icon(iconsdata.values.elementAt(0)),
              // child: Text(
              // '${panelDataList.elementAt(index)}',
              //'text',
              //index.toString(),
              // style: TextStyle(fontSize: 10.0),
            );
          }),
      floatingActionButton: FloatingActionButton.large(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddDevice(user: _currentUser),
                //builder: (context) => MyAppli(),
              ),
            );
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add)),
    );
  }
}

class Tag {
  String idpanel;
  String tipo;
  String nombre;
  bool mod;

  Tag(this.idpanel, this.tipo, this.nombre, this.mod);

  factory Tag.fromJson(dynamic json) {
    return Tag(json['id'] as String, json['type'] as String,
        json['name'] as String, json['mod'] as bool);
  }

  @override
  String toString() {
    return '{ ${this.idpanel}, ${this.tipo} , ${this.nombre} , ${this.mod} }';
  }
}
