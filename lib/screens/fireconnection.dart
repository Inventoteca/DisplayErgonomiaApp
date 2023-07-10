import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'device_list_page.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

late List<dynamic> _panelDataList = List.empty(growable: true);
var _doc;
late User _currentUser;
late String _panelID;
late String _name;
late String _type;
//late MqttServerClient client;
late bool _isDemo;
late bool _isConnected;
late dynamic newValue;

class FireConnection extends StatefulWidget {
  final User user;
  //final SharedPreferences prefs;
  final String id;
  final String name;
  final String type;
  final bool demo;

  const FireConnection(
      {required this.user,
      required this.type,
      required this.id,
      required this.name,
      required this.demo});

  @override
  State<FireConnection> createState() => _FireConnetionState();
  //State<StatefulWidget> createState() {
  // TODO: implement createState
  // throw UnimplementedError();
  //}
}

class _FireConnetionState extends State<FireConnection> {
  bool _isLoading = true;
  late String _ssid;
  late String _bssid;
  late String _password;
  late String _msg = '';
  bool _isObscure = true;

  //@override
  void initState() {
    super.initState();
    //_isLoading = true;
    _currentUser = widget.user;
    _panelID = widget.id;
    _name = widget.name;
    _type = widget.type;
    debugPrint("aqui esta el error");
    debugPrint(_panelID);
    _isDemo = widget.demo;
    _isConnected = false;

    _loadConfig();
  }

  Future<List<dynamic>> downloadFile(String _docFile) async {
    //debugPrint('Downloading');
    _panelDataList = List.empty();

    final db = FirebaseFirestore.instance;
    try {
      //debugPrint('Try');
      _doc = await db.collection("users").doc(_docFile).get();
      debugPrint('Get');
      var panels = _doc.data();
      debugPrint('$panels');

      List<dynamic> data = panels["panels"];

      _panelDataList = data;
      debugPrint('$_panelDataList');

      return _panelDataList;
    } on FirebaseException catch (e) {
      debugPrint('${e.code}: ${e.message}');
      return _panelDataList;
    }
  }

  //------------------------------------------------------------- _panelDEL
  Future<void> _updatePanel(var cmd) async {
    if (mounted) {
      final db = FirebaseFirestore.instance;

      Map<String, dynamic> data = jsonDecode(cmd);
      try {
        db
            .collection("users")
            .doc('${_currentUser.email}')
            .collection('devices')
            .doc('${data['id']}')
            .set(data);
      } on FirebaseAuthException catch (e) {
        debugPrint('$e');
      }
    }
  }

  // -------------------------------- _loadConfig
  Future _loadConfig() async {
    var encode = {'id': _panelID, 'type': _type, 'name': _name};

    debugPrint('$encode');

    await _updatePanel(jsonEncode(encode));

    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$_panelID/');
    //await ref.child('actual/ping').set(false);

    if (_isDemo) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DeviceList(
            user: _currentUser,
            //id: _panelID,
            // prefs: _prefs,
          ),
        ),
      );
      return;
    }
    ref.child('conifg').onValue.listen((event) {
      newValue = event.snapshot.value;
      Future.delayed(const Duration(seconds: 5));
      // Imprimir el valor en la consola
      //print('Nuevo valor: $newValue');
      //debugPrint("${newValue["ping"]}");

      if (newValue["registered"]) {
        if (mounted) {
          setState(() {
            debugPrint("aqui se repite?");
            _isConnected = true;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DeviceList(
                user: _currentUser,
                //id: _panelID,
                // prefs: _prefs,
              ),
            ),
          );
          return;
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        //appBar: AppBar(
        //  title: const Text("Demo"),
        //),
        );

    // throw UnimplementedError();
  }
}
