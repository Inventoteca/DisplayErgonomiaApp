// ignore_for_file: unused_element

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:smart_industry/screens/panelList_page.dart';
import '/screens/profile_page.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
//import 'package:segment_display/segment_display.dart';
//import 'package:device_info/device_info.dart';
import '/screens/NavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

MqttConnectionState? connectionState;
StreamSubscription? subscription;
late User _currentUser;
late SharedPreferences _prefs;
late String _panelID;

String pt1 = '';
String pt2 = '';
String pt3 = '';
String pt4 = '';
String pt5 = '';
String pt6 = '';
String pt7 = '';
// ignore:
late Color _pt1Color = Colors.black;
late Color _pt2Color = Colors.black;
late Color _pt3Color = Colors.black;
late Color _pt4Color = Colors.black;
late Color _pt5Color = Colors.black;
late Color _pt6Color = Colors.black;
late Color _pt7Color = Colors.black;
Map<String, dynamic> _jsonDataList = {};

class ConfigPanelPage extends StatefulWidget {
  final User user;
  final SharedPreferences prefs;
  final String id;

  const ConfigPanelPage(
      {required this.user, required this.prefs, required this.id});

  //@override
  _ConfigPanelPageState createState() => _ConfigPanelPageState();
}

class _ConfigPanelPageState extends State<ConfigPanelPage> {
  MqttServerClient? client;

  //bool _isSigningOut = false;

  //late User _currentUser;
  late SharedPreferences prefs;

  //final _icons = <String>[];
  void initState() {
    _currentUser = widget.user;
    _prefs = widget.prefs;
    _panelID = widget.id;
    debugPrint(_panelID);
    _loadConfig();
    super.initState();
  }

  @override
  void dispose() {
    onDisConnected();
    super.dispose();
  }

  //@override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        user: _currentUser,
        prefs: _prefs,
      ),
      appBar: AppBar(
        title: Text('Configuraciones'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --------- temperatura
            /*Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.thermostat_rounded,
                        color: Colors.white,
                        size: 60,
                      )),
                  TextSpan(
                      text: ' $pt1',
                      style: TextStyle(fontSize: 50, color: _pt1Color)),
                  TextSpan(
                      text: ' °C',
                      style: TextStyle(fontSize: 50, color: Colors.orange)),
                ],
              ),
            ),
            */

            //SevenSegmentDisplay(
            //  value: pt1,
            //  size: 5.0,
            //  backgroundColor: Colors.transparent,
            //  segmentStyle: HexSegmentStyle(
            //    enabledColor: _pt1Color,
            //    disabledColor: Colors.transparent,
            //  ),
            //),

            // SizedBox(height: 16.0),

            // --------- humedad
            /*  Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 60,
                      )),
                  TextSpan(
                      text: ' $pt2',
                      style: TextStyle(fontSize: 50, color: _pt2Color)),
                  TextSpan(
                      text: ' %',
                      style: TextStyle(fontSize: 50, color: Colors.orange)),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // --------- uv
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.sunny,
                        color: Colors.white,
                        size: 60,
                      )),
                  TextSpan(
                      text: '$pt3',
                      style: TextStyle(fontSize: 50, color: _pt3Color)),
                  TextSpan(
                      text: ' UV',
                      style: TextStyle(fontSize: 50, color: Colors.orange)),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // --------- db
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.campaign,
                        color: Colors.white,
                        size: 60,
                      )),
                  TextSpan(
                      text: '$pt4',
                      style: TextStyle(fontSize: 50, color: _pt4Color)),
                  TextSpan(
                      text: ' dB',
                      style: TextStyle(fontSize: 50, color: Colors.orange)),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // --------- lux
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.light_rounded,
                        color: Colors.white,
                        size: 60,
                      )),
                  TextSpan(
                      text: '$pt5',
                      style: TextStyle(fontSize: 50, color: _pt5Color)),
                  TextSpan(
                      text: ' Lux',
                      style: TextStyle(fontSize: 50, color: Colors.orange)),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            // --------- aire
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.local_florist,
                        color: Colors.white,
                        size: 60,
                      )),
                  TextSpan(
                      text: '$pt6',
                      style: TextStyle(fontSize: 50, color: _pt6Color)),
                  TextSpan(
                      text: ' PPM',
                      style: TextStyle(fontSize: 50, color: Colors.orange)),
                ],
              ),
            ),
            */
            SizedBox(height: 16.0),
            Text(
              '$pt7',
              style: TextStyle(fontSize: 20, color: Colors.blueGrey),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                onPublish(
                    '0',
                    '${_prefs.getString('rootTopic')}' +
                        'panels/' +
                        _panelID +
                        '/app');
              },
              child: Text('Enviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      user: _currentUser,
                      prefs: _prefs,
                    ),
                  ),
                );
              },
              child: Text('Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------- _loadConfig
  Future _loadConfig() async {
    debugPrint('UID ${_prefs.getString('mqttClient')}');
    client = MqttServerClient.withPort('${_prefs.getString('broker')}',
        '${_prefs.getString('mqttClient')}', 1883);
    //client = MqttServerClient(broker, mqttClient);
    connect('prefBroker', '${_prefs.getString('mqttClient')}');
    //MqttUtilities.asyncSleep(60);
  }

//--------------------------------- onSubscribe
  void onSubscribe(String topic) {
    if (connectionState == MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client?.subscribe(topic, MqttQos.exactlyOnce);
      //client?.subscribe(topic, MqttQos.atMostOnce);
    }
  }

// -------------------------------- onDisconected
  void onDisConnected() {
    debugPrint('Panel Disconnected');
    onPublish('0',
        '${_prefs.getString('rootTopic')}' + 'panels/' + _panelID + '/app');
    client?.disconnect();
  }

// -------------------------------- onPublish
  void onPublish(String message, String topic) {
    print('send msg: $message');

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    //client?.publishMessage('inv/' + _currentUser.uid + '/app',
    //    MqttQos.atLeastOnce, builder.payload!);
    client?.publishMessage('$topic', MqttQos.atLeastOnce, builder.payload!);

    builder.clear();
  }

// --------------------------------- onConnected
  void connect(String? top, String? left) async {
    print('mqtt conection panel');
    final connMessage = MqttConnectMessage()
        //.keepAliveFor(10)
        //.withWillTopic('inv/' + '$_currentUser.email' + '/app')
        .withWillTopic('${_prefs.getString('rootTopic')}' +
            'panels/' +
            '$_panelID' +
            '/app')
        .withWillMessage('0')
        .startClean()
        //.withWillRetain()
        .withWillQos(MqttQos.exactlyOnce);
    client?.connectionMessage = connMessage;
    try {
      await client?.connect();
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }

    final topic1 = '${_prefs.getString('rootTopic')}' +
        'panels/' +
        _panelID +
        '/#'; // Wildcard topic
    //client?.subscribe(topic1, MqttQos.atMostOnce);
    //onSubscribe(topic1);
    client?.subscribe(topic1, MqttQos.atLeastOnce);
    subscription = client?.updates?.listen(onMessage);

    onPublish('1',
        '${_prefs.getString('rootTopic')}' + 'panels/' + _panelID + '/app');
  }

// ---------------------------------------------------------- onMsg
  void onMessage(List<MqttReceivedMessage> event) {
    if (mounted) {
//print(event.length);

      //final topicFilter = MqttClientTopicFilter('inv/random', client?.updates);

      final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      //debugPrint('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
      //    'payload is <-- $message -->');

      //print("[MQTT client] message with topic: ${event[0].topic}");

      //debugPrint("[MQTT client] ${event[0].topic}: $message");

      //------------------ Temperature-----------------------
      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/t') ==
          0)
        setState(() {
          pt1 = message;
          if (int.parse(pt1) >= _jsonDataList['sensors']['t']['max']) {
            _pt1Color = Color(_jsonDataList['sensors']['t']['colMax']);
          } else if (int.parse(pt1) <= _jsonDataList['sensors']['t']['min']) {
            _pt1Color = Color(_jsonDataList['sensors']['t']['colMin']);
          } else {
            _pt1Color = Color(_jsonDataList['sensors']['t']['colDef']);
          }
        });

      //------------------ Humidity -----------------------
      else if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/h') ==
          0)
        setState(() {
          pt2 = message;
          if (int.parse(pt2) >= _jsonDataList['sensors']['h']['max']) {
            _pt2Color = Color(_jsonDataList['sensors']['h']['colMax']);
          } else if (int.parse(pt2) <= _jsonDataList['sensors']['h']['min']) {
            _pt2Color = Color(_jsonDataList['sensors']['h']['colMin']);
          } else {
            _pt2Color = Color(_jsonDataList['sensors']['h']['colDef']);
          }
        });
      else if (event[0].topic ==
          '${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/uv')
        setState(() {
          pt3 = message;
          if (double.parse(pt3) >= _jsonDataList['sensors']['uv']['max']) {
            _pt3Color = Color(_jsonDataList['sensors']['uv']['colMax']);
          } else if (double.parse(pt3) <=
              _jsonDataList['sensors']['uv']['min']) {
            _pt3Color = Color(_jsonDataList['sensors']['uv']['colMin']);
          } else {
            _pt3Color = Color(_jsonDataList['sensors']['uv']['colDef']);
          }
        });

      //------------------ Sound -----------------------
      else if (event[0].topic ==
          '${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/db')
        setState(() {
          pt4 = message;
          if (int.parse(pt4) >= _jsonDataList['sensors']['db']['max']) {
            //debugPrint('db maximo');
            _pt4Color = Color(_jsonDataList['sensors']['db']['colMax']);
          } else if (int.parse(pt4) <= _jsonDataList['sensors']['db']['min']) {
            //debugPrint(pt4);
            _pt4Color = Color(_jsonDataList['sensors']['db']['colMin']);
          } else {
            _pt4Color = Color(_jsonDataList['sensors']['db']['colDef']);
          }
        });

      //------------------ Ligth -----------------------
      else if (event[0].topic ==
          '${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/lux')
        setState(() {
          pt5 = message;
          if (int.parse(pt5) >= _jsonDataList['sensors']['lux']['max']) {
            _pt5Color = Color(_jsonDataList['sensors']['lux']['colMax']);
          } else if (int.parse(pt5) <= _jsonDataList['sensors']['lux']['min']) {
            _pt5Color = Color(_jsonDataList['sensors']['lux']['colMin']);
          } else {
            _pt5Color = Color(_jsonDataList['sensors']['lux']['colDef']);
          }
        });

      //------------------ Air Quality -----------------------
      else if (event[0].topic ==
          '${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/ppm')
        setState(() {
          pt6 = message;
          if (int.parse(pt6) >= _jsonDataList['sensors']['ppm']['max']) {
            _pt6Color = Color(_jsonDataList['sensors']['ppm']['colMax']);
          } else if (int.parse(pt6) <= _jsonDataList['sensors']['ppm']['min']) {
            _pt6Color = Color(_jsonDataList['sensors']['ppm']['colMin']);
          } else {
            _pt6Color = Color(_jsonDataList['sensors']['ppm']['colDef']);
          }
        });

      //------------------ Configs/Limits/Colors -----------------------
      else if (event[0].topic ==
          '${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/conf/response')
        setState(() {
          panelConfig(message);
        });

      //------------------ Unknown -----------------------
      else {
        setState(() {
          //debugPrint(message);
          //debugPrint("[MQTT client] ${event[0].topic}: $message");
          // pt7 = message;
          _pt7Color = Colors.grey;
        });
      }
    } else {
      onDisConnected();
    }
  }

  void panelConfig(String message) {
    pt7 = message;
    _pt7Color = Colors.grey;
    //debugPrint("[MQTT client]: $message");
    Map<String, dynamic> jsonDataList = jsonDecode(message.toString());
    _jsonDataList = jsonDataList;

    //debugPrint('Panel: ${_jsonDataList['sensors']['t']['colDef']}');
  }
}
