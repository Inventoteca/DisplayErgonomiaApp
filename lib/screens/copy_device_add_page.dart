// ignore_for_file: prefer_const_constructors

import 'dart:io' as io;
//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';
//import 'package:esptouch_smartconfig/esptouch_smartconfig.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
//import 'package:flutter/services.dart';
//import 'package:loggerx/loggerx.dart';
import 'package:network_info_plus/network_info_plus.dart';
//import 'dart:developer' as developer;
//import 'package:flutter/services.dart';
//import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:smart_industry/screens/device_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

late SharedPreferences _prefs;
late List<dynamic> panelDataList = List.empty(growable: true);
// ignore: unused_element
late ProvisioningRequest _request;

class AddDevice extends StatefulWidget {
  //const AddDevice({super.key});
  final User user;
  final SharedPreferences prefs;
  const AddDevice({required this.user, required this.prefs});

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  late User _currentUser;
  final info = NetworkInfo();
  //final String _connectionStatus = 'Unknown';
  bool _isLoading = false;
  late String _ssid;
  late String _bssid;
  late String _password;
  late String _msg = 'Mensaje';
  //late String _data;
  bool _isObscure = true;
  //late List<Tag> panelDataList;

  //final data =
  //    '[ {"id": "ABCDEF", "tipo": "ERGO", "nombre":"Inventoteca", "mod":true}, {"id": "123456", "tipo": "CRUZ", "nombre": "Demo", "mod":false}]';

  //-----  final NetworkInfo _networkInfo = NetworkInfo();
  final provisioner = new Provisioner.espTouchV2();

  //late Provisioner provisioner = new Provisioner.espTouchV2();

  //EsptouchSmartconfig
  final TextEditingController _bssidFilter = new TextEditingController();
  final TextEditingController _ssidFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();

  // ---------------------- Init State
  void initState() {
    _ssidFilter.addListener(_ssidListen);
    _passwordFilter.addListener(_passwordListen);
    _bssidFilter.addListener(_bssidListen);
    _isLoading = false;
    _currentUser = widget.user;
    _prefs = widget.prefs;
    _initNetworkInfo();
    _loadConfig();
    readResponse();
    super.initState();

    //var dataList = jsonDecode(_currentUser.photoURL.toString());

    //if (dataList != null) {
    //  var tagObjsJson = jsonDecode(_currentUser.photoURL.toString()) as List;

    //  List<Tag> tagObjs =
    //      tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();

    //  panelDataList = tagObjs;
    //  debugPrint('Panel: $panelDataList');
    //} else {
    //  debugPrint('No hay panels');
    //  panelDataList = List.empty();
    //}
  }

  @override
  void dispose() {
    //Wakelock.disable();
    //onDisConnected();
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
      //log.info("Wait for response");
      //String bssidResp = '$response';
      //log.info('Device: ${bssidResp.split("=")[1]}');

      //var data = jsonDecode(
      //    '[ {"id": "${bssidResp.split("=")[1]}", "type": "unk", "name":"Nuevo", "mod":true}]');
      //var data =
      //    '{"id":"${bssidResp.split("=")[1]}","type":"ergo","name":"Nuevo","mod":true}';

      // _panelADD(data);

      //var dataList = jsonDecode(_currentUser.photoURL.toString());
      //debugPrint(data);
      //debugPrint(dataList);
      //if (dataList != null) {
      //  var tagObjsJson = jsonDecode(_currentUser.photoURL.toString()) as List;

      //  List<Tag> tagObjs =
      //      tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();

      //  tagObjs.add(data);
      //  dataList = jsonEncode(tagObjs);
      //  log.info(dataList);

      //await _currentUser.updatePhotoURL(dataList.stringify());
      //await _currentUser.updatePhotoURL(dataList);
      //panelDataList = tagObjs;
      //debugPrint('Panel: $panelDataList');
      //} //else {
      //debugPrint('No hay panels');
      //panelDataList = List.empty();

      provisioner.stop();
      setState(() {
        _isLoading = false;
        _msg = "Device Configured OK";
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DeviceList(
            user: _currentUser,
            prefs: _prefs,
          ),
        ),
      );
    });
  }

  // --------------------------sendConfig
  _sendConfig() async {
    setState(() {
      _isLoading = true;
      _request = ProvisioningRequest.fromStrings(
          ssid: _ssid,
          bssid: _bssid,
          password: _password,
          reservedData: '${_currentUser.email}');
    });
    // await Future.delayed(const Duration(seconds: 5));

    await Permission.location.request();

    debugPrint(_ssid);

    await provisioner.start(ProvisioningRequest.fromStrings(
        ssid: _ssid,
        bssid: _bssid,
        password: _password,
        reservedData: '${_currentUser.email}'));

    await Future.delayed(const Duration(seconds: 60));
    //countSeconds(60);

    //readResponse();

    if (mounted) {
      setState(() {
        if (_isLoading) {
          _msg = "Config Fail";
          _isLoading = false;
          provisioner.stop();
        }
      });
    }

    //

    /*try {
      const Duration kLongTimeout = Duration(seconds: 10);
      await provisioner
          .start(ProvisioningRequest.fromStrings(
              ssid: "Inventoteca_2G",
              bssid: _bssid,
              password: _password,
              reservedData: '${_currentUser.email}'))
          .timeout(kLongTimeout);
    } on PlatformException catch (e) {
      log.info("Failed to configure: '${e.message}'.");
      provisioner.stop();
    }*/
  }

  // ----------------------------IinitNetworkInfo
  Future<void> _initNetworkInfo() async {
    //developer.log('InitNetwork');

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
        //final splitted = ssid.split('"');
        // print(splitted[1]);
        // print(bssid);
        //developer.log('${ssid.split('"')[1]}');
        //developer.log(msg_ssid);
        //setState(() {
        //msg = "WiFi Details OK";
        //});

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
    debugPrint('Adding List');
    //if (jsonDecode(cmd) != null)
    {
      Map<String, dynamic> data;
      data = jsonDecode(cmd);
      //var dataList = jsonDecode(_currentUser.photoURL.toString());

      if (panelDataList.isEmpty) {
        //setState(() {
        panelDataList = List.empty(growable: true);
        //});

      }

      //  var data = jsonDecode(
      //      '{"id": "123fds", "tipo": "NEO", "nombre":"Nuevo", "mod":true}');

      if ((data.isNotEmpty)) {
        bool newpanel = true;

        List<dynamic> jsonDataList = panelDataList;

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

          //await _currentUser.updatePhotoURL(jsonEncode(jsonDataList));
          await uploadString(jsonEncode(jsonDataList));
          setState(() {
            panelDataList = jsonDataList;
          });
        } else {
          debugPrint('Panel already on list');
        }
      }
    }
  }*/

  /// A new string is uploaded to storage.
  UploadTask uploadString(String putStringText) {
    //const String putStringText = '[]';

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('smart/')
        .child('users/')
        .child('${_currentUser.email}')
        .child('/panels.json');

    // Start upload of putString
    return ref.putString(
      putStringText,
      //metadata: SettableMetadata(
      //  contentLanguage: 'en',
      //  customMetadata: <String, String>{'example': 'putString'},
      //),
    );
  }

  // -------------------------------- _loadConfig
  Future<void> _loadConfig() async {
    //debugPrint('UID ${_prefs.getString('mqttClient')}');
    //final port = _prefs.getInt('port');
    //client = MqttServerClient.withPort('${_prefs.getString('broker')}',
    //    '${_prefs.getString('mqttClient')}', port!);
    //client = MqttServerClient(broker, mqttClient);
    //connect('prefBroker', '${_prefs.getString('mqttClient')}');
    // _loadPanels();
    final List<dynamic> tempList = await _downloadFile();
    if (mounted) {
      setState(() {
        panelDataList = tempList;
      });
    }
  }

// ------------------------------------------ _downloadFile
  Future<List> _downloadFile() async {
// Create a Reference to the file
    //File file;
    //String fileName = '${_currentUser.email}';
    final ref = FirebaseStorage.instance
        .ref()
        .child('smart/')
        .child('users/')
        .child('${_currentUser.email}')
        .child('/panels.json');

    // UploadTask uploadTask = ref.putFile(file);

    try {
      final listResult = await ref.listAll();
      debugPrint('$listResult');
      final io.Directory systemTempDir = io.Directory.systemTemp;
      final io.File tempFile =
          io.File('${systemTempDir.path}/temp-${ref.name}');
      if (tempFile.existsSync()) await tempFile.delete();

      await ref.writeToFile(tempFile);

      //panelDataList = json.decode(tempFile.readAsStringSync()) as List;

      //debugPrint('$panelDataList');
      return json.decode(tempFile.readAsStringSync()) as List;
    } on FirebaseException catch (e) {
      debugPrint('${e.code}: ${e.message}');
      return List.empty();
    }
  }

  // ------------------------------------ widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añadir Dispositivo"),
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
              : Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(height: 10),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(_msg),
                            TextField(
                              controller: _ssidFilter,
                              decoration:
                                  InputDecoration(labelText: 'Red WiFi'),
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
                            ElevatedButton(
                                onPressed: _sendConfig, child: Text('Enviar'))
                          ],
                        ),
                      )
                    ],
                  ))),
    );
  }
}
