//import 'dart:js_util';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';

//import '/screens/panel_page.dart';

final String broker = 'inventoteca.com';
final int port = 1883;
final String mqttClient = 'app_' + generateRandomString(5);

MqttConnectionState? connectionState;
StreamSubscription? subscription;
late SharedPreferences prefs;
late MqttServerClient client;
late String _panelID;
late var rootTopic;
late var _pt1 = ' 0';
//Function callback;

Future<MqttServerClient> connect(String willTopic) async {
  //debugPrint('$_panelID + ' '+ $mqttClient');
  _panelID = willTopic;
  client = MqttServerClient.withPort(broker, mqttClient, port);
  client.logging(on: false);
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  // client.onUnsubscribed = onUnsubscribed as UnsubscribeCallback?;
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      //.withClientIdentifier("flutter_client")
      //.authenticateAs("test", "test")
      .withWillTopic(willTopic)
      .withWillMessage('0')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;
  try {
    debugPrint('Connecting');
    await client.connect();
  } catch (e) {
    debugPrint('Exception: $e');
    client.disconnect();
  }

  if (client.connectionStatus?.state == MqttConnectionState.connected) {
    debugPrint('Smart Industry Server connected');

    /*client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttMessage message = c[0].payload;
      var payload;
      // payload =
      //    MqttPublishPayload.bytesToStringAsString(message.payload.message);

      debugPrint('Received message:$payload from topic: ${c[0].topic}>');
    });*/

    /*client.published!.listen((MqttPublishMessage message) {
      debugPrint('published');
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      debugPrint(
          'Published message: $payload to topic: ${message.variableHeader?.topicName}');
    });*/
  } else {
    debugPrint(
        'EMQX client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
    exit(-1);
  }

  return client;
}

void onConnected() {
  debugPrint('Connected');
}

void onDisconnected() {
  debugPrint('Disconnected');
}

// -------------------------------- onDisconected
void onDisConnected() {
  debugPrint('Panel Disconnected');

  client.disconnect();
}

// -------------------------------- onPublish
void onPublish(String message, String topic) {
  //debugPrint('send msg: $message');

  final builder = MqttClientPayloadBuilder();
  builder.addString(message);

  //client?.publishMessage('inv/' + _currentUser.uid + '/app',
  //    MqttQos.atLeastOnce, builder.payload!);

  client.publishMessage('$topic', MqttQos.atLeastOnce, builder.payload!);

  builder.clear();
}

void onSubscribed(String topic) {
  debugPrint('Subscribed topic: $topic');
}

//--------------------------------- onSubscribe
void onSubscribe(String topic) {
  if (connectionState == MqttConnectionState.connected) {
    // debugPrint('[MQTT client] Subscribing to ${topic.trim()}');
    client.subscribe(topic, MqttQos.exactlyOnce);
    //client?.subscribe(topic, MqttQos.atMostOnce);
  }
}

void onSubscribeFail(String topic) {
  print('Failed to subscribe topic: $topic');
}

void onUnsubscribed(String topic) {
  print('Unsubscribed topic: $topic');
}

void pong() {
  print('Ping response client callback invoked');
}

String generateRandomString(int len) {
  var r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
