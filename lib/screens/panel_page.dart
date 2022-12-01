//import 'dart:async';
// ignore_for_file: deprecated_member_use, unused_element

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
String clientID = '';
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

  const PanelPage({required this.user, required String id});

  //@override
  _PanelPageState createState() => _PanelPageState();
}

class _PanelPageState extends State<PanelPage> {
  MqttServerClient? client;

  //bool _isSigningOut = false;

  late User _currentUser;
  //final _icons = <String>[];
  void initState() {
    _currentUser = widget.user;
    _getId();
    super.initState();
  }

  @override
  void dispose() {
    //timer.cancel();
    onDisConnected();
    super.dispose();
  }

  //@override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(user: _currentUser),
      appBar: AppBar(
        title: Text('Panel'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --------- temperatura
            Text.rich(
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

            //SevenSegmentDisplay(
            //  value: pt1,
            //  size: 5.0,
            //  backgroundColor: Colors.transparent,
            //  segmentStyle: HexSegmentStyle(
            //    enabledColor: _pt1Color,
            //    disabledColor: Colors.transparent,
            //  ),
            //),

            SizedBox(height: 16.0),
            // --------- humedad
            Text.rich(
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
            SizedBox(height: 16.0),
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
    );
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
    debugPrint('CID $clientID');
    client = MqttServerClient(broker, clientID);
    connect(broker, clientID);
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
    debugPrint('Disconnected');
    client?.disconnect();
  }

// -------------------------------- onPublish
  void onPublish(String message) {
    print('send msg: $message');

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    //client?.publishMessage('inv/' + _currentUser.uid + '/app',
    //    MqttQos.atLeastOnce, builder.payload!);
    client?.publishMessage('inv/' + '3C:71:BF:FC:BF:94' + '/app',
        MqttQos.atLeastOnce, builder.payload!);

    builder.clear();
  }

// --------------------------------- onConnected

  void connect(String? top, String? left) async {
    print('mqtt conection');
    final connMessage = MqttConnectMessage()
        .keepAliveFor(10)
        .withWillTopic('inv/' + '$_currentUser.email' + '/app')
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

    final topic1 = 'inv/' + '3C:71:BF:FC:BF:94' + '/#'; // Wildcard topic
    //client?.subscribe(topic1, MqttQos.atMostOnce);
    //onSubscribe(topic1);
    client?.subscribe(topic1, MqttQos.atLeastOnce);
    subscription = client?.updates?.listen(onMessage);
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

      if (event[0].topic.compareTo('inv/' + '3C:71:BF:FC:BF:94' + '/t') == 0)
        setState(() {
          pt1 = message;
          _pt1Color = Colors.red;
        });
      else if (event[0].topic.compareTo('inv/' + '3C:71:BF:FC:BF:94' + '/h') ==
          0)
        setState(() {
          pt2 = message;
          _pt2Color = Colors.white;
        });
      else if (event[0].topic == 'inv/' + '3C:71:BF:FC:BF:94' + '/uv')
        setState(() {
          pt3 = message;
          _pt3Color = Colors.white;
        });
      else if (event[0].topic == 'inv/' + '3C:71:BF:FC:BF:94' + '/db')
        setState(() {
          pt4 = message;
          _pt4Color = Colors.white;
        });
      else if (event[0].topic == 'inv/' + '3C:71:BF:FC:BF:94' + '/lux')
        setState(() {
          pt5 = message;
          _pt5Color = Colors.red;
        });
      else if (event[0].topic == 'inv/' + '3C:71:BF:FC:BF:94' + '/ppm')
        setState(() {
          pt6 = message;
          _pt6Color = Colors.white;
        });
      else {
        setState(() {
          pt7 = message;
          _pt7Color = Colors.grey;
        });
      }
    } else {
      onDisConnected();
    }
  }
}
