//import 'dart:async';
// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '/screens/profile_page.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
//import 'package:segment_display/segment_display.dart';
import 'package:device_info/device_info.dart';
import '/screens/NavBar.dart';
//import 'package:client_information/client_information.dart';
//import 'package:json_annotation/json_annotation.dart';

String broker = 'inventoteca.com';
int port = 1883;
//String username         = 'fcg.._seu_user_no_brokerrix';
//String passwd           = '0qVi...seu_pass_no_nroker';
String clientID = 'androidabcd1';
String pt1 = '';
String pt2 = '';
String pt3 = '';
String pt4 = '';
String pt5 = '';
String pt6 = '';
String pt7 = '';
late Color _pt1Color = Colors.black;
late Color _pt2Color = Colors.black;
late Color _pt3Color = Colors.black;
late Color _pt4Color = Colors.black;
late Color _pt5Color = Colors.black;
late Color _pt6Color = Colors.black;
late Color _pt7Color = Colors.black;
const topicID = 'inv/random'; // Not a wildcard topic

MqttConnectionState? connectionState;

StreamSubscription? subscription;

class PanelPage extends StatefulWidget {
  final User user;

  const PanelPage({required this.user});

  @override
  _PanelPageState createState() => _PanelPageState();
}

class _PanelPageState extends State<PanelPage> {
  MqttServerClient? client = MqttServerClient(broker, clientID)
    ..port = port
    ..keepAlivePeriod = 20;
  //  ..onSubscribed = onSubscribed;
  //..onConnected = onConnected;

  //bool _isSigningOut = false;

  late User _currentUser;
  Map<String, IconData> iconsdata = {
    'temp': Icons.thermostat_rounded,
    'hum': Icons.water_drop,
    'uv': Icons.sunny,
    'db': Icons.campaign,
    'lux': Icons.light_rounded,
    'ppm': Icons.local_florist,
    //),
  };

  final _sensorUnits = <String>[
    '°C',
    '%',
    'UV',
    'dB',
    'Lux',
    'PPM',
  ];
  final _sensorList = <String>[
    '°C',
    '%',
    'UV',
    'dB',
    'Lux',
    'PPM',
  ];

  //final _listOfIcons = List<num>.of(_icons);
  //final tiles = _sensorList;
  //final divided = tiles.isNotEmpty
  //    ? ListTile.divideTiles(
  //        context: context,
  //        tiles: tiles,
  //      ).toList()
  //    : <Widget>[];

  //@override
  void initState() {
    _currentUser = widget.user;
    //connect(broker, _currentUser.uid);
    _getId();
    debugPrint('CID $clientID');
    connect(broker, clientID);
    super.initState();
    debugPrint('UID ${_currentUser.uid}');
  }

  //@override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(user: _currentUser),
        appBar: AppBar(
          title: Text('Panel'),
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _sensorList.length,
            itemBuilder: (context, int index) {
              return Container(
                height: 80,
                //color: Colors.red,
                child: Center(
                  //child: Icon(iconsdata.values.elementAt(0)),
                  child: Text(
                    '${_sensorList.elementAt(index)}',
                    //'text',
                    //index.toString(),
                    style: TextStyle(fontSize: 60.0),
                  ),
                ),
              );
            }));

    // iconsdata.values.elementAt(0),

    //_sensorList.elementAt(0),

    //SevenSegmentDisplay(
    //  value: pt1,
    //  size: 5.0,
    //  backgroundColor: Colors.transparent,
    //  segmentStyle: HexSegmentStyle(
    //    enabledColor: _pt1Color,
    //    disabledColor: Colors.transparent,
    //  ),
    //),

    /*          SizedBox(height: 16.0),
            Text(
              '$pt7',
              style: TextStyle(fontSize: 10, color: Colors.blueGrey),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                onPublish('Hola');
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
    );*/
  }

  Future _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      clientID = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      clientID = androidDeviceInfo.androidId; // unique ID on Android
    }
  }

//--------------------------------- onSubscribe
  void onSubscribe(String topic) {
    if (connectionState == MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client?.subscribe(topic, MqttQos.exactlyOnce);
    }
  }

// -------------------------------- onDisconected
  void onDisConnected() {
    print('Disconnected');
  }

// -------------------------------- onPublish
  void onPublish(String message) {
    print('send msg: $message');

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client?.publishMessage('inv/' + _currentUser.uid + '/app',
        MqttQos.atLeastOnce, builder.payload!);
    builder.clear();
  }

// --------------------------------- onConnected

  void connect(String? top, String? left) async {
    print('mqtt conection');
    final connMessage = MqttConnectMessage()
        //.keepAliveFor(60)
        .withWillTopic('inv/' + _currentUser.uid + '/app')
        .withWillMessage('$left,$top')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client?.connectionMessage = connMessage;
    try {
      await client?.connect();
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }

    final topic1 = 'inv/' + _currentUser.uid + '/#'; // Wildcard topic
    client?.subscribe(topic1, MqttQos.atMostOnce);
    subscription = client?.updates?.listen(onMessage);
    onSubscribe(topic1);
  }

// ---------------------------------------------------------- onMsg
  void onMessage(List<MqttReceivedMessage> event) {
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
    //print(client.connectionState);
    //print("[MQTT client] message with topic: ${event[0].topic}");
    debugPrint("[MQTT client] ${event[0].topic}: $message");

    if (event[0].topic.compareTo('inv/' + _currentUser.uid + '/temperatura') ==
        0)
      setState(() {
        _sensorList[0] = message;
        _pt1Color = Colors.red;
      });
    else if (event[0].topic.compareTo('inv/' + _currentUser.uid + '/humedad') ==
        0)
      setState(() {
        _sensorList[1] = message;
        _pt2Color = Colors.white;
      });
    else if (event[0].topic == 'inv/' + _currentUser.uid + '/uv')
      setState(() {
        _sensorList[2] = message;
        _pt3Color = Colors.white;
      });
    else if (event[0].topic == 'inv/' + _currentUser.uid + '/ruido')
      setState(() {
        _sensorList[3] = message;
        _pt4Color = Colors.white;
      });
    else if (event[0].topic == 'inv/' + _currentUser.uid + '/lux')
      setState(() {
        _sensorList[4] = message;
        _pt5Color = Colors.red;
      });
    else if (event[0].topic == 'inv/' + _currentUser.uid + '/aire')
      setState(() {
        _sensorList[5] = message;
        _pt6Color = Colors.white;
      });
    else {
      setState(() {
        _sensorList[6] = message;
        _pt7Color = Colors.grey;
      });
    }
  }
}
