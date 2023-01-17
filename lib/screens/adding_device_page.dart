// ignore_for_file: prefer_const_constructors, unused_element

//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:network_info_plus/network_info_plus.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:smart_industry/screens/device_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

late SharedPreferences _prefs;
late List<dynamic> panelDataList = List.empty(growable: true);
late ProvisioningRequest _request;
final provisioner = Provisioner.espTouchV2();

class AddingDevice extends StatefulWidget {
  //const AddDevice({super.key});
  final User user;
  final SharedPreferences prefs;
  final ProvisioningRequest request;
  const AddingDevice(
      {required this.user, required this.prefs, required this.request});

  @override
  State<AddingDevice> createState() => _AddingDeviceState();
}

class _AddingDeviceState extends State<AddingDevice> {
  late User _currentUser;
  final info = NetworkInfo();
  //final String _connectionStatus = 'Unknown';
  bool _isLoading = false;
  late String _msg = 'Mensaje';
  //late String _data;

  //-----  final NetworkInfo _networkInfo = NetworkInfo();

  //late Provisioner provisioner = new Provisioner.espTouchV2();

  // ---------------------- Init State
  void initState() {
    _isLoading = false;
    _currentUser = widget.user;
    _prefs = widget.prefs;
    _request = widget.request;
    _sendConfig();
    super.initState();
  }

  @override
  void dispose() {
    //Wakelock.disable();
    //onDisConnected();
    provisioner.stop();
    super.dispose();
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

  Future<void> readResponse() async {
    /* provisioner.listen((response) async {
      String bssidResp = '$response';
      var data =
          '{"id":"${bssidResp.split("=")[1]}","type":"ergo","name":"Nuevo","mod":true}';
      // _panelADD(data);
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
    });*/
  }

  // --------------------------sendConfig
  void _sendConfig() async {
    if (mounted) {
      provisioner.listen((response) {
        print("Device ${response.bssidText} connected to WiFi!");
        setState(() {
          _isLoading = false;
          _msg = "Device Configured OK";
          String bssidResp = '$response';
          String idResponse = bssidResp.split("=")[1];
          idResponse = idResponse.toUpperCase();
          //var data =
          //    '{"id":"${bssidResp.split("=")[1]}","type":"ergo","name":"Nuevo","mod":true}';
          var data =
              '{"id":"$idResponse","type":"ergo","name":"Nuevo","mod":true}';

          _panelADD(data);
        });
        provisioner.stop();
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await provisioner.start(_request);

      // await provisioner.start(ProvisioningRequest.fromStrings(
      // ssid: 'InventotecaGuest',
      //   bssid: 'd2:32:e5:3e:4b:df',
      //   password: 'InventoInvitado',
      // ));

      /*await provisioner.start(ProvisioningRequest.fromStrings(
        ssid: 'Inventoteca_2G',
        bssid: 'cc:32:e5:3e:4b:df',
        password: 'science_7425',
        //reservedData: 'info@inventoteca.com', // fail here
      ));*/

      // If you are going to use this library in Flutter
      // this is good place to show some Dialog and wait for exit
      //
      // Or simply you can delay with Future.delayed function
      await Future.delayed(Duration(seconds: 90));
    } catch (e) {
      print(e);
    }

    //await Future.delayed(const Duration(seconds: 60));
    //countSeconds(60);

    //readResponse();

    if (mounted) {
      setState(() {
        if (_isLoading) {
          _msg = "Config Fail";
          _isLoading = false;
        }
        provisioner.stop();
      });
      //Navigator.of(context).pushReplacement(
      //  MaterialPageRoute(
      //    builder: (context) => DeviceList(
      //      user: user,
      //      prefs: _prefs,
      //    ),
      //  ),
      //);

    }
  }

  //------------------------------------------------------------- _panelADD
  Future<void> _panelADD(var cmd) async {
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
  }

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

  // ------------------------------------ widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscando"),
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
                          ],
                        ),
                      )
                    ],
                  ))),
    );
  }
}
