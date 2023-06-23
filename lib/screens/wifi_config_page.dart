import 'dart:async';
import 'dart:io' as io;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:json_rpc_2/error_code.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '/screens/send_wifi_page.dart';
//import 'package:smart_industry/screens/device_list_page.dart';
import 'device_list_page.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:mqtt_client/mqtt_client.dart';
//import 'package:mqtt_client/mqtt_server_client.dart';
//import '/screens/panel_page.dart';
//import '/utils/mqtt_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late List<dynamic> _panelDataList = List.empty(growable: true);
var _doc;
//StreamSubscription<EventSnapshot>? _subscription;
//MqttConnectionState? connectionState;
//StreamSubscription? subscription;
late User _currentUser;
late String _panelID;
late String _name;
late String _type;
//late MqttServerClient client;
late bool _isDemo;
late bool _isConnected;
late dynamic newValue;

class WifiConfig extends StatefulWidget {
  //const AddDevice({super.key});
  final User user;
  //final SharedPreferences prefs;
  final String id;
  final String name;
  final String type;
  final bool demo;

  const WifiConfig(
      {required this.user,
      required this.type,
      required this.id,
      required this.name,
      required this.demo});

  @override
  State<WifiConfig> createState() => _WifiConfigState();
}

class _WifiConfigState extends State<WifiConfig> {
  //final String _connectionStatus = 'Unknown';
  bool _isLoading = true;
  late String _ssid;
  late String _bssid;
  late String _password;
  late String _msg = '';
  bool _isObscure = true;

  //-----  final NetworkInfo _networkInfo = NetworkInfo();
  final info = NetworkInfo();
  final provisioner = new Provisioner.espTouchV2();

  final TextEditingController _bssidFilter = new TextEditingController();
  final TextEditingController _ssidFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();

  // ---------------------- Init State
  void initState() {
    _ssidFilter.addListener(_ssidListen);
    _passwordFilter.addListener(_passwordListen);
    _bssidFilter.addListener(_bssidListen);
    _isLoading = true;
    _currentUser = widget.user;
    _panelID = widget.id;
    _name = widget.name;
    _type = widget.type;
    debugPrint(_panelID);
    _isDemo = widget.demo;
    _isConnected = false;
    //_prefs = widget.prefs;
    _loadConfig();

    readResponse();
    super.initState();
  }

  @override
  void dispose() {
    //onDisconnected();
    provisioner.stop();
    super.dispose();
  }

  // ---------------------------ssidListen
  void _ssidListen() {
    if (_ssidFilter.text.isEmpty) {
      _ssid = "";
    } else {
      //setState(() {
      _ssid = _ssidFilter.text;
      debugPrint(_ssid);
      //});
      //log.info(_ssid);
      //developer.log(_ssid);
    }
  }

  // ------------------------ bssidListen
  void _bssidListen() {
    if (_bssidFilter.text.isEmpty) {
      _bssid = "";
    } else {
      _bssid = _bssidFilter.text;
    }
  }

  // --------------------------- paswordLsiten
  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  void countSeconds(int s) {
    for (var i = 1; i <= s; i++) {
      Future.delayed(Duration(seconds: i), () => debugPrint('$i'));
      if (i == s) {
        provisioner.stop();
        setState(() {
          _isLoading = false;
          _msg = "Fail to configure Device";
        });
      }
    }
  }

  Future<void> readResponse() async {
    provisioner.listen((response) async {
      provisioner.stop();
      setState(() {
        _isLoading = false;
        _msg = "Device Configured OK";
      });
    });
  }

  // ----------------------------IinitNetworkInfo
  Future<void> _initNetworkInfo() async {
    String ssid = "";
    String bssid = "";
    String msgSsid = "";

    PermissionWithService locationPermission = Permission.locationWhenInUse;
    var permissionStatus = await locationPermission.status;
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await locationPermission.request();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await locationPermission.request();
      }
    }
    if (permissionStatus == PermissionStatus.granted) {
      bool isLocationServiceOn =
          await locationPermission.serviceStatus.isEnabled;
      if (isLocationServiceOn) {
        final info = NetworkInfo();
        ssid = await info.getWifiName() as String;
        bssid = await info.getWifiBSSID() as String;
        msgSsid = '${ssid.split('"')[1]}';
        msgSsid = msgSsid.toString();

        setState(() {
          //_ssidFilter.text = ssid.split('"')[1];

          _ssidFilter.text = msgSsid;
          _bssidFilter.text = bssid;
          _msg = "WiFi Details OK";

          //developer.log(_ssidFilter.text);
        });
      } else {
        //developer.log('Location Service is not enabled');
        setState(() {
          _msg = "Location Service is not enabled";
        });
      }
    }
  }

  //------------------------------------------------------------- _panelADD
  /*Future<void> _panelADD(var cmd) async {
    if (mounted) {
      //panelDataList =
      await downloadFile('${_currentUser.email}');
      debugPrint('Adding List');
      //if (jsonDecode(cmd) != null)
      {
        Map<String, dynamic> data;
        data = jsonDecode(cmd);

        if (_panelDataList.isEmpty) {
          //setState(() {
          //_panelDataList = List.empty(growable: true);
          //});
          //_panelDataList = {};
        }
        if ((data.isNotEmpty)) {
          bool newpanel = true;

          List<dynamic> jsonDataList = _panelDataList as List;

          jsonDataList.forEach((element) {
            debugPrint('${element['id']}');
            if ('${element['id']}' == '${data['id']}') {
              newpanel = false;
            }
          });

          if (newpanel) {
            jsonDataList.add(data);
            debugPrint('New panel');
            debugPrint('Panel: ${jsonEncode(jsonDataList)}');

            // await uploadString(jsonEncode(jsonDataList));
            //final datapanels = jsonDataList;

            //await _currentUser.updatePhotoURL(jsonEncode(jsonDataList));
            // await uploadString(jsonEncode(jsonDataList));
            final db = FirebaseFirestore.instance;
            // Create a new user with a first and last name

            /*final panels = <String, dynamic>{
              "id": data['id'],
              "type": data['type'],
              "name": data['name'],
              //"born": 1912
            };*/

// Add a new document with a generated ID
            try {
              db
                  .collection("users")
                  .doc('${_currentUser.email}')
                  //.collection('panels')
                  //.add(data);
                  .set(data); //.then(
              //(DocumentReference doc) =>
              //  print('DocumentSnapshot added with ID: ${doc.id}'));
            } on FirebaseAuthException catch (e) {
              debugPrint('$e');
            }

            if (mounted) {
              setState(() {
                // _panelDataList = jsonDataList;
              });
            }
          } else {
            debugPrint('Panel already on list');
            // _panelDEL(cmd);
            // jsonDataList.add(data);
          }
        }
      }
    }
  }*/

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
    //if (_configLoaded) {
    // return; // Salir temprano si la configuración ya se ha cargado
    //}

    //if (mounted) {

    var encode = {'id': _panelID, 'type': _type, 'name': _name};

    debugPrint('$encode');

    await _updatePanel(jsonEncode(encode));

    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$_panelID/');
    await ref.child('actual/ping').set(false);

    //await _panelADD(jsonEncode(encode));

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
    ref.child('actual').onValue.listen((event) {
      newValue = event.snapshot.value;
      Future.delayed(const Duration(seconds: 5));
      // Imprimir el valor en la consola
      //print('Nuevo valor: $newValue');
      //debugPrint("${newValue["ping"]}");

      if (newValue["ping"]) {
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
        //return;
      } else {
        //final topic1 = 'smart/' + 'panels/' + _panelID + '/app/#';
        //client = await connect(topic1);

        //client.subscribe(topic1, MqttQos.atLeastOnce);
        //subscription = client.updates?.listen(onMessage);
        //print(subscription);

        //onPublish('1', 'smart/' + 'panels/' + _panelID + '/app/conf');

        //await Future.delayed(const Duration(seconds: 60));
        //if (_msg == '')
        //{
        //  setState(() {
        //    _isLoading = false;
        //  });

        //if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _initNetworkInfo();
        //}

        // _configLoaded = true;
      }
    });

    // if (_isConnected) {
    //   return;
    //}
  }

  // ---------------------------------------------------------- onMsg
  // void onMessage(List<MqttReceivedMessage> event) {
  /* if (mounted) {
//print(event.length);

      //final topicFilter = MqttClientTopicFilter(
      //    'smart/' + 'panels/' + _panelID + '/sensors/#', client.updates);

      final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      //if (event[0].topic.compareTo(
      //        'smart/' + 'panels/' + _panelID + '/app/conf/response') ==
      //    0)
      //  {
      setState(() {
        _msg = message;
      });

      onPublish('0', 'smart/' + 'panels/' + _panelID + '/app');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DeviceList(
            user: _currentUser,
            //id: _panelID,
            // prefs: _prefs,
          ),
        ),
      );
      //}
    }*/
  //}

  // ------------------------------------ widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Compartir WiFi"),
        ),
        body: Center(
            child: _isLoading
                ? Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        margin: EdgeInsets.all(15),
                        elevation: 10,
                        color: Color.fromARGB(255, 216, 216, 216),
                        child: SizedBox(
                            width: 350,
                            height: 500,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(height: 10),
                                Container(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.wifi,
                                        size: 100,
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Text(
                                          "Conectar el panel a la siguinete Red WiFi" /*widget.value*/,
                                          style: TextStyle(
                                            fontSize: 20,
                                          )),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      TextField(
                                        controller: _ssidFilter,
                                        decoration: InputDecoration(
                                            labelText: 'Red WiFi'),
                                      ),
                                      TextField(
                                        controller: _passwordFilter,
                                        obscureText: _isObscure,
                                        decoration: InputDecoration(
                                            labelText: 'Contraseña',
                                            suffixIcon: IconButton(
                                                icon: Icon(_isObscure
                                                    ? Icons.visibility
                                                    : Icons.visibility_off),
                                                onPressed: () {
                                                  setState(() {
                                                    _isObscure = !_isObscure;
                                                  });
                                                })),
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddingDevice(
                                                // prefs: _prefs,
                                                user: _currentUser,
                                                request: ProvisioningRequest
                                                    .fromStrings(
                                                        ssid: _ssid,
                                                        bssid: _bssid,
                                                        password: _password
                                                        //reservedData: '${_currentUser.email}',
                                                        ),
                                                id: _panelID,
                                                name: _name,
                                                type: _type,
                                              ),
                                            ),
                                          );
                                        },

                                        child: Text(
                                          'Conectar',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        //onPressed: _sendConfig, child: Text('Enviar')
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ))),
                  ))));
  }
}

/*@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}*/
