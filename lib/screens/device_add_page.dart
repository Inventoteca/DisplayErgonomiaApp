// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:loggerx/loggerx.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:smart_industry/screens/device_list_page.dart';
import 'dart:convert';

class AddDevice extends StatefulWidget {
  //const AddDevice({super.key});
  final User user;
  const AddDevice({required this.user});

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  late User _currentUser;
  final info = NetworkInfo();
  final String _connectionStatus = 'Unknown';
  bool _isLoading = false;
  late String _ssid;
  late String _bssid;
  late String _password;
  late String _msg = 'Mensaje';
  late String _data;
  bool _isObscure = true;
  late List<Tag> panelDataList;
  final data =
      '[ {"id": "ABCDEF", "tipo": "ERGO", "nombre":"Inventoteca", "mod":true}, {"id": "123456", "tipo": "CRUZ", "nombre": "Demo", "mod":false}]';

  //-----  final NetworkInfo _networkInfo = NetworkInfo();
  final provisioner = Provisioner.espTouchV2();
  final TextEditingController _bssidFilter = new TextEditingController();
  final TextEditingController _ssidFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();

  // ---------------------- Init State
  void initState() {
    _ssidFilter.addListener(_ssidListen);
    _passwordFilter.addListener(_passwordListen);
    _bssidFilter.addListener(_bssidListen);
    _isLoading = false;
    super.initState();
    _currentUser = widget.user;
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

    _initNetworkInfo();
    _ReadResponse();
  }

  // ---------------------------ssidListen
  void _ssidListen() {
    if (_ssidFilter.text.isEmpty) {
      _ssid = "";
    } else {
      _ssid = _ssidFilter.text;
      log.info(_ssid);
      developer.log(_ssid);
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
        //provisioner.stop();
        setState(() {
          _isLoading = false;
          _msg = "Fail to configure Device";
        });
      }
    }
  }

  Future<void> _ReadResponse() async {
    provisioner.listen((response) async {
      log.info("Wait for response");
      String bssidResp = '$response';
      log.info('Device: ${bssidResp.split("=")[1]}');

      var data = jsonDecode(
          '[ {"id": "${bssidResp.split("=")[1]}", "tipo": "NEO", "nombre":"Nuevo", "mod":true}]');

      var dataList = jsonDecode(_currentUser.photoURL.toString());
      //log.info(data);
      if (dataList != null) {
        var tagObjsJson = jsonDecode(_currentUser.photoURL.toString()) as List;

        List<Tag> tagObjs =
            tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();

        tagObjs.add(data);
        dataList = jsonEncode(tagObjs);
        log.info(dataList);

        //await _currentUser.updatePhotoURL(dataList.stringify());
        //await _currentUser.updatePhotoURL(dataList);
        //panelDataList = tagObjs;
        //debugPrint('Panel: $panelDataList');
      } //else {
      //debugPrint('No hay panels');
      //panelDataList = List.empty();

      provisioner.stop();
      setState(() {
        _isLoading = false;
        _msg = "Device Configured OK";
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => devicelist(
            user: _currentUser,
          ),
        ),
      );
    });
  }

  // --------------------------sendConfig
  Future<void> _sendConfig() async {
    //await _initNetworkInfo();

    //_ReadResponse();

    //const Duration kLongTimeout = Duration(seconds: 1);
    setState(() {
      _isLoading = true;
    });
    //.whenComplete(() => debugPrint('Enviado'));

    provisioner.start(ProvisioningRequest.fromStrings(
        ssid: _ssid,
        bssid: _bssid,
        password: _password,
        reservedData: '${_currentUser.email}'));

    developer.log('Sending');
    developer.log(_ssid);
    developer.log(_password);

    //await Future.delayed(const Duration(seconds: 60));
    //setState(() {
    //provisioner.stop();
    //if (_isLoading) {
    //  _msg = "Config Fail";
    //  _isLoading = false;
    //}
    //});

    //countSeconds(60);

    //try {
    //const Duration kLongTimeout = Duration(seconds: 10);
    //await provisioner.start(ProvisioningRequest.fromStrings(
    //    ssid: _ssid,
    //    bssid: _bssid,
    //    password: _password,
    //    reservedData: '${_currentUser.email}'));
    //.timeout(kLongTimeout);
    //provisioner.stop();
    //} on PlatformException catch (e) {
    //  log.info("Failed to configure: '${e.message}'.");
    // }
  }

  // ----------------------------IinitNetworkInfo
  Future<void> _initNetworkInfo() async {
    //developer.log('InitNetwork');

    String ssid = "";
    String bssid = "";
    String msg_ssid = "";

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
        msg_ssid = '${ssid.split('"')[1]}';
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
          _ssidFilter.text = msg_ssid;
          _bssidFilter.text = bssid;
          _msg = "WiFi Details OK";
          developer.log(_ssidFilter.text);
        });
      } else {
        developer.log('Location Service is not enabled');
        setState(() {
          _msg = "Location Service is not enabled";
        });
      }
    }
  }

  // ------------------------------------ widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurando Dispositivo"),
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

class Tag {
  String idpanel;
  String tipo;
  String nombre;
  bool mod;

  Tag(this.idpanel, this.tipo, this.nombre, this.mod);

  factory Tag.fromJson(dynamic json) {
    return Tag(json['id'] as String, json['tipo'] as String,
        json['nombre'] as String, json['mod'] as bool);
  }

  @override
  String toString() {
    return '{ ${this.idpanel}, ${this.tipo} , ${this.nombre} , ${this.mod} }';
  }
}
