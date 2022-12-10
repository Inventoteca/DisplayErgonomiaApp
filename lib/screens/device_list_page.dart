import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_industry/screens/NavBar.dart';
import 'package:smart_industry/screens/panelList_page.dart';
import 'package:smart_industry/screens/panel_page.dart';
import 'package:smart_industry/screens/device_add_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import '../.mqtt_client.dart';
String clientID = '';
String broker = 'inventoteca.com';
int port = 1883;
MqttConnectionState? connectionState;
StreamSubscription? subscription;
late User _currentUser;
late SharedPreferences _prefs;
late List<dynamic> panelDataList = List.empty();
String data =
    '[ {"id": "3C:71:BF:FC:BF:94", "type": "ergo", "name":"Inventoteca", "mod":true}, {"id": "123456", "type": "cruz", "name": "Demo", "mod":false}]';

class DeviceList extends StatefulWidget {
  //const webSocket({Key? key}) : super(key: key);
  final User user;
  final SharedPreferences prefs;

  const DeviceList({required this.user, required this.prefs});

  //@override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  MqttServerClient? client;

  //late bool connected;
  //late User _currentUser;
  late SharedPreferences prefs;

  void initState() {
    _currentUser = widget.user;
    _prefs = widget.prefs;

    // final data =
    //     '[ {"id": "3C:71:BF:FC:BF:94", "type": "ergo", "name":"Inventoteca", "mod":true}, {"id": "123456", "type": "cruz", "name": "Demo", "mod":false}]';

    //  _currentUser.updatePhotoURL(data); //Uncoment for Test only

    _loadPanels();
    _loadConfig();
    //_getId();
    super.initState();

    //connected = false; //initially connection status is "NO" so its FALSE

    //final prefBroker = _prefs.getString('broker') ?? 'inventoteca.com';
    // final prefPort = _prefs.getInt('port') ?? 1883;
    // final prefMqttClient = _prefs.getString('mqttClient') ?? 'genericID';

    //client = MqttServerClient('$prefBroker', '$prefMqttClient');

    // var tagObjsJson = jsonDecode(_currentUser.photoURL.toString())['panels'];
    //   ? jsonDecode(_currentUser.photoURL.toString())['panels'] as List
    //    : List.empty();
    //var tagObjsJson = _currentUser.photoURL;

    //List<Tag> tagObjs =
    //  tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();
    //debugPrint('Paneles: $tagObjsJson');
    //debugPrint('Paneles: ${_currentUser.photoURL}');
  }

  //@override
  //void dispose() {
  //  debugPrint('dispose disconect');
  //  onDisConnected();
  //  super.dispose();
  //}

  //------------------------------------------------------------- _loadPanels
  void _loadPanels() {
    //var dataList = jsonDecode(data);
    //var dataList = jsonDecode(_currentUser.photoURL.toString());
    List<dynamic> jsonDataList = jsonDecode(_currentUser.photoURL.toString());

    if (jsonDataList.isNotEmpty) {
      var tagObjsJson = jsonDecode(_currentUser.photoURL.toString()) as List;

      // List<Tag> tagObjs =
      //    tagObjsJson.map((tagJson) => Tag.fromJson(tagJson)).toList();

      panelDataList = tagObjsJson;
    } else {
      debugPrint('No hay panels');
      panelDataList = List.empty();

      /*if (panelDataList.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AddDevice(
              user: _currentUser,
            ),
          ),
        );
      }*/
    }
    debugPrint('Load Panels: $panelDataList');
  }

  //------------------------------------------------------------- _panelDEL
  Future<void> _panelDEL(var cmd) async {
    Map<String, dynamic> data = jsonDecode(cmd);
    //  var data = jsonDecode(
    //      '{"id": "123fds", "tipo": "NEO", "nombre":"Nuevo", "mod":true}');

    var dataList = jsonDecode(_currentUser.photoURL.toString());
    bool delpanel = false;

    List<dynamic> jsonDataList = dataList as List;

    jsonDataList.forEach((element) {
      //debugPrint('${element['id']}');
      if ('${element['id']}' == '${data['id']}') {
        delpanel = true;
      } //else {
      //newpanel = true;
      //}
    });

    if (delpanel) {
      jsonDataList.removeWhere((element) => element["id"] == "${data['id']}");
      debugPrint('Removed panel ${data['id']}');
      debugPrint('Panel: ${jsonEncode(jsonDataList)}');
      await _currentUser.updatePhotoURL(jsonEncode(jsonDataList));
    } else {
      debugPrint('Panel not on list');
    }
  }

  //------------------------------------------------------------- _panelADD
  Future<void> _panelADD(var cmd) async {
    Map<String, dynamic> data = jsonDecode(cmd);
    //  var data = jsonDecode(
    //      '{"id": "123fds", "tipo": "NEO", "nombre":"Nuevo", "mod":true}');

    var dataList = jsonDecode(_currentUser.photoURL.toString());
    bool newpanel = true;

    List<dynamic> jsonDataList = dataList as List;

    jsonDataList.forEach((element) {
      debugPrint('${element['id']}');
      if ('${element['id']}' == '${data['id']}') {
        newpanel = false;
      } //else {
      //newpanel = true;
      //}
    });

    if (newpanel) {
      jsonDataList.add(data);
      debugPrint('New panel');
      debugPrint('Panel: ${jsonEncode(jsonDataList)}');
      await _currentUser.updatePhotoURL(jsonEncode(jsonDataList));
    } else {
      debugPrint('Panel already on list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(
        user: _currentUser,
        prefs: _prefs,
      ),
      appBar: AppBar(
        title: Text('Dispositivos'),
      ),
      body: ListView.builder(
          itemCount: panelDataList.length,
          itemBuilder: (context, int index) {
            return ElevatedButton(
              //child: Text('${panelDataList.elementAt(index)}'),
              child: Text('${panelDataList.elementAt(index)['name']}'),
              onPressed: () => {
                //debugPrint('PanelPage'),
                //PanelPage(
                //  user: _currentUser,
                //)
                if (panelDataList.elementAt(index)['type'].compareTo("ergo") ==
                    0)
                  {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PanelPage(
                          user: _currentUser,
                          id: panelDataList.elementAt(index)['name'],
                          prefs: _prefs,
                        ),
                      ),
                    ),
                  }
                else if (panelDataList.elementAt(index)['type'] == 'cruz')
                  {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PanelListPage(user: _currentUser),
                      ),
                    ),
                  }
                else // if (panelDataList.elementAt(index).tipo == 'cruz')
                  {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PanelListPage(user: _currentUser),
                      ),
                    ),
                  }
              },
              //color: Colors.red,
              //child: Center(
              //child: Icon(iconsdata.values.elementAt(0)),
              // child: Text(
              // '${panelDataList.elementAt(index)}',
              //'text',
              //index.toString(),
              // style: TextStyle(fontSize: 10.0),
            );
          }),
      floatingActionButton: FloatingActionButton.large(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddDevice(user: _currentUser),
                //builder: (context) => MyAppli(),
              ),
            );
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add)),
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
    debugPrint('MID $clientID');
    client = MqttServerClient(broker, clientID);
    connect(broker, clientID);
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
      client?.subscribe(topic, MqttQos.atLeastOnce);
      //client?.subscribe(topic, MqttQos.atMostOnce);
    }
  }

// -------------------------------- onDisconected
  void onDisConnected() {
    debugPrint('User Disconnected');
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
    print('mqtt conection list');
    final connMessage = MqttConnectMessage()
        //.keepAliveFor(10)
        //.withWillTopic('inv/' + '$_currentUser.email' + '/app')
        .withWillTopic('inv/' + '${_currentUser.email}' + '/app')
        .withWillMessage('$left,$top')
        //.startClean()
        .withClientIdentifier('$left')
        //.withWillRetain()
        .withWillQos(MqttQos.exactlyOnce);
    client?.connectionMessage = connMessage;
    try {
      await client!.connect();
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }

    final topic1 = 'inv/' + '${_currentUser.email}' + '/#'; // Wildcard topic
    //client?.subscribe(topic1, MqttQos.atMostOnce);
    //onSubscribe(topic1);
    client?.subscribe(topic1, MqttQos.exactlyOnce);
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

      //debugPrint("[MQTT client] ${event[0].topic}: $message");

      if (event[0].topic.compareTo('inv/' + '${_currentUser.email}' + '/add') ==
          0) {
        _panelADD(message);
      } else if (event[0]
              .topic
              .compareTo('inv/' + '${_currentUser.email}' + '/del') ==
          0) {
        _panelDEL(message);
      }
    } else {
      debugPrint('not mounted');
      onDisConnected();
    }
  }
}

class Tag {
  String idpanel;
  String tipo;
  String nombre;
  bool mod;

  Tag(this.idpanel, this.tipo, this.nombre, this.mod);

  factory Tag.fromJson(dynamic json) {
    return Tag(json['id'] as String, json['type'] as String,
        json['name'] as String, json['mod'] as bool);
  }

  @override
  String toString() {
    return '{ ${this.idpanel}, ${this.tipo} , ${this.nombre} , ${this.mod} }';
  }
}