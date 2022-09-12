//import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '/screens/profile_page.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:json_annotation/json_annotation.dart';

String broker = 'inventoteca.com';
int port = 1883;
//String username         = 'fcg.._seu_user_no_brokerrix';
//String passwd           = '0qVi...seu_pass_no_nroker';
String clientID = 'androidabcd1';
String pt1 = 'nuevo';
const topic = 'inv'; // Not a wildcard topic

MqttConnectionState? connectionState;

StreamSubscription? subscription;

class PanelPage extends StatefulWidget {
  final User user;

  const PanelPage({required this.user});

  @override
  _PanelPageState createState() => _PanelPageState();
}

class _PanelPageState extends State<PanelPage> {
  void onSubscribe(String topic) {
    if (connectionState == MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client?.subscribe(topic, MqttQos.exactlyOnce);
    }
  }

  //void _subscribeToTopic(String topic) {
  //  if (connectionState == mqtt.MqttConnectionState.connected) {
  //    print('[MQTT client] Subscribing to ${topic.trim()}');
  //    client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
  //  }
  //}

  MqttServerClient? client = MqttServerClient(broker, clientID)
    ..port = port
    ..keepAlivePeriod = 20;
  //  ..onSubscribed = onSubscribed;
  //..onConnected = onConnected;

  bool _isSigningOut = false;

  late User _currentUser;

  //@override
  void initState() {
    _currentUser = widget.user;
    connect(broker, clientID);
    super.initState();
    print('UID ${_currentUser.uid}');
  }

  //@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$pt1',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                onPublish('Mensaje');
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

// -------------------------------- onDisconected
  void onDisConnected() {
    print('Disconnected');
  }

// -------------------------------- onPublish
  void onPublish(String message) {
    print('send msg: $message');

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client?.publishMessage('app', MqttQos.atLeastOnce, builder.payload!);
    builder.clear();
  }

// --------------------------------- onConnected
  //void onConnected() {
  //print('Connected');

  //try {
  //  client?.subscribe(topic!, MqttQos.atLeastOnce);
  //  client?.updates!.listen((dynamic t) {
  //    final MqttPublishMessage recMess = t[0].payload;
  //    final message =
  //        MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);

  //    print('message id : ${recMess.variableHeader?.messageIdentifier}');
  //    print('message : $message');
  //int id = model!.message.length + 1;
  //model!
  //    .addMessage(Messages(id: isMe ? 0 : id, msg: message, time: 'now'));
  //  });
  //} catch (e) {
  //  print(e.toString());
  //}
  // }

  void connect(String? top, String? left) async {
    print('mqtt conection');
    final connMessage = MqttConnectMessage()
        //.keepAliveFor(60)
        .withWillTopic('app')
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

    client?.subscribe(topic, MqttQos.atMostOnce);
    client?.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      pt1 = pt;
      print(pt1);
      subscription = client?.updates?.listen(onMessage);
      onSubscribe(topic);
      //onConnected();
    });
  }

// ---------------------------------------------------------- onMsg
  void onMessage(List<MqttReceivedMessage> event) {
    print(event.length);
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final String message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    //print(client.connectionState);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: ${message}");
    setState(() {
      pt1 = message;
    });
  }
}
