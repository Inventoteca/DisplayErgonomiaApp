// ignore_for_file: prefer_const_constructors, unused_element

//import 'package:flutter/src/widgets/container.dart';
//import 'package:flutter/src/widgets/framework.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:network_info_plus/network_info_plus.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:smart_industry/screens/device_list_page.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:convert';
//import 'package:firebase_storage/firebase_storage.dart';
//import '/screens/device_list_page.dart';
import 'device_list_page.dart';
//import 'package:mqtt_client/mqtt_client.dart';
//import 'package:mqtt_client/mqtt_server_client.dart';
//import '/utils/mqtt_client.dart';

//late SharedPreferences _prefs;
late List<dynamic> panelDataList = List.empty(growable: true);
late ProvisioningRequest _request;
late Provisioner provisioner = Provisioner.espTouchV2();

//MqttConnectionState? connectionState;
//StreamSubscription? subscription;
late String _panelID;
late String _name;
late String _type;

class AddingDevice extends StatefulWidget {
  //const AddDevice({super.key});
  final User user;
  final String id;
  final String name;
  final String type;
  //final SharedPreferences prefs;
  final ProvisioningRequest request;
  const AddingDevice(
      {required this.user,
      required this.type,
      required this.id,
      required this.name,
      required this.request});

  @override
  State<AddingDevice> createState() => _AddingDeviceState();
}

class _AddingDeviceState extends State<AddingDevice> {
  late User _currentUser;
  final info = NetworkInfo();
  //final String _connectionStatus = 'Unknown';
  bool _isLoading = true;
  late String _msg = '';
  //late String _data;

  //-----  final NetworkInfo _networkInfo = NetworkInfo();

  //late Provisioner provisioner = new Provisioner.espTouchV2();

  // ---------------------- Init State
  void initState() {
    _isLoading = false;
    _currentUser = widget.user;
    _panelID = widget.id;
    _name = widget.name;
    _type = widget.type;
    _request = widget.request;
    //_loadConfig();
    _sendConfig();
    super.initState();
  }

  @override
  void dispose() {
    //Wakelock.disable();
    //  onDisConnected();
    // provisioner;
    provisioner.stop();
    super.dispose();
  }

  // ---------------------------------------------------------- onMsg
/*  void onMessage(List<MqttReceivedMessage> event) {
    if (mounted) {
      debugPrint('MQTT first');

      final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (event[0]
              .topic
              .compareTo('smart/' + 'panels/' + _panelID + '/conf/response') ==
          0) {
        setState(() {
          _msg = message;
        });

        debugPrint('MQTT topic exit');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DeviceList(
              user: _currentUser,
              //id: _panelID,
              // prefs: _prefs,
            ),
          ),
        );
      }
    }
  }*/

  // -------------------------------- _loadConfig
  //Future _loadConfig() async {
  //final topic1 = 'smart/' + 'panels/' + _panelID + '/#';
  //client = await connect(topic1);

  //client.subscribe(topic1, MqttQos.atLeastOnce);
  //subscription = client.updates?.listen(onMessage);

  //onPublish('1', 'smart/' + 'panels/' + _panelID + '/app/conf');

  //await Future.delayed(const Duration(seconds: 3));

  //if (mounted) {
  //  setState(() {
  ///    _isLoading = true;
  //  });
  //}
  //}

  // --------------------------sendConfig
  void _sendConfig() async {
    //final provisioner = Provisioner.espTouchV2();
    if (mounted) {
      provisioner.listen((response) {
        debugPrint("Device ${response.bssidText} connected to WiFi!");
        setState(() {
          _isLoading = false;
          _msg = "Dispositivo encontrado";
          String bssidResp = '$response';
          String idResponse = bssidResp.split("=")[1];
          idResponse = idResponse.toUpperCase();
          //var data =
          //    '{"id":"${bssidResp.split("=")[1]}","type":"ergo","name":"Nuevo","mod":true}';
          //var data =
          //    '{"id":"$idResponse","type":"ergo","name":"Nuevo","mod":true}';

          //_panelADD(data);
        });
        provisioner.stop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DeviceList(
              user: _currentUser,
              //id: _panelID,
              // prefs: _prefs,
            ),
          ),
        );
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await provisioner.start(_request);
      await Future.delayed(Duration(seconds: 60));
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        if (_isLoading) {
          _msg =
              "Error, vuelve a Intentarlo, revisa la contraseña y el nombre de la red";
          _isLoading = false;
        }
        provisioner.stop();
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DeviceList(
            user: _currentUser,
            //prefs: _prefs,
          ),
        ),
      );
    }
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
