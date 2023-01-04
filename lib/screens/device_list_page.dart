//import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smart_industry/screens/NavBar.dart';
import 'package:smart_industry/screens/panelList_page.dart';
import 'package:smart_industry/screens/panel_page.dart';
import 'package:smart_industry/screens/device_add_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io' as io;
//import 'package:device_info/device_info.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

MqttConnectionState? connectionState;
StreamSubscription? subscription;
late User _currentUser;
late SharedPreferences _prefs;
late List<dynamic> panelDataList = List.empty(growable: true);

class DeviceList extends StatefulWidget {
  //const webSocket({Key? key}) : super(key: key);
  final User user;
  final SharedPreferences prefs;

  const DeviceList({required this.user, required this.prefs});

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  MqttServerClient? client;

  late bool connected;
  //late User _currentUser;
  late SharedPreferences prefs;

  void initState() {
    _currentUser = widget.user;
    _prefs = widget.prefs;
    _loadConfig();
    super.initState();
  }

  //@override
  //void dispose() {
  //  debugPrint('dispose disconect');
  //  onDisConnected();
  //  super.dispose();
  //}

  //------------------------------------------------------------- _panelDEL
  Future<void> _panelDEL(var cmd) async {
    Map<String, dynamic> data = jsonDecode(cmd);
    //  var data = jsonDecode(
    //      '{"id": "123fds", "tipo": "NEO", "nombre":"Nuevo", "mod":true}');

    if (data.isNotEmpty) {
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
  }

  //------------------------------------------------------------- _panelADD
  Future<void> _panelADD(var cmd) async {
    //debugPrint('Adding List');
    //if (jsonDecode(cmd) != null)
    {
      Map<String, dynamic> data;
      data = jsonDecode(cmd);

      if (panelDataList.isEmpty) {
        setState(() {
          panelDataList = List.empty(growable: true);
        });
      }
      if (data.isNotEmpty) {
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
      body: projectWidget(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    AddDevice(user: _currentUser, prefs: _prefs),
                //builder: (context) => MyAppli(),
              ),
            );
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add)),
    );
  }

  Widget projectWidget() {
    return FutureBuilder<List<dynamic>>(
        future: _downloadFile(),
        builder: (context, AsyncSnapshot<List<dynamic>> projectSnap) {
          if (!projectSnap.hasData) {
            // while data is loading:
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
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
                      if (panelDataList.elementAt(index)['type'] == 'ergo')
                        {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PanelPage(
                                user: _currentUser,
                                id: panelDataList.elementAt(index)['id'],
                                prefs: _prefs,
                              ),
                            ),
                          ),
                        }
                      else if (panelDataList.elementAt(index)['type'] == 'cruz')
                        {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PanelListPage(
                                user: _currentUser,
                                prefs: _prefs,
                              ),
                            ),
                          ),
                        }
                      else // if (panelDataList.elementAt(index).tipo == 'cruz')
                        {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PanelListPage(
                                user: _currentUser,
                                prefs: _prefs,
                              ),
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
                });
          }
        });
  }

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

    /*final dirs = FirebaseStorage.instance
        .ref()
        .child('smart/')
        .child('users/')
        .child('${_currentUser.email}')
        .child('/data')
        .listAll();*/

    // UploadTask uploadTask = ref.putFile(file);

    //try {
    // var tempList = await ref.listAll();
    //ListResult listResult = await dirs;
    //listResult.items.forEach((dirs) {
    //  print('Found file: $dirs');
    //});
    //tempList.items.forEach((ref) {
    //  print('Found file: $ref');
    //  return json.decode(tempList.toString());
    //});
    //return List.empty();
    //final io.Directory systemTempDir = io.Directory.systemTemp;
    //final io.File tempFile =
    //    io.File('${systemTempDir.path}/temp-${ref.name}');
    //if (tempFile.existsSync()) await tempFile.delete();

    //await ref.writeToFile(tempFile);

    // return json.decode(tempFile.readAsStringSync()) as List;

    // } on FirebaseException catch (e) {
    //   debugPrint('${e.code}: ${e.message}');
    //   return List.empty();
    //}
    try {
      final listResult = await ref.listAll();
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

  // -------------------------------- _loadConfig
  Future _loadConfig() async {
    debugPrint('List ${_prefs.getString('mqttClient')}');

    final port = _prefs.getInt('port');
    client = MqttServerClient.withPort('${_prefs.getString('broker')}',
        '${_prefs.getString('mqttClient')}', port!);
    //client = MqttServerClient.withPort(
    //   '${_prefs.getString('broker')}', 'iosclient', port!);

    connect('prefBroker', '${_prefs.getString('mqttClient')}');
    //connect('prefBroker', 'iosclient');

    // _loadPanels();
    final List<dynamic> listTemp = await _downloadFile();
    setState(() {
      panelDataList = listTemp;
      debugPrint('$panelDataList');
    });
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
    client?.publishMessage(
        '${_prefs.getString('rootTopic')}' +
            'users/' +
            '${_currentUser.email}' +
            '/app',
        MqttQos.atLeastOnce,
        builder.payload!);

    builder.clear();
  }

// --------------------------------- onConnected
  void connect(String? top, String? left) async {
    print('mqtt conection list');
    final connMessage = MqttConnectMessage()
        //.keepAliveFor(10)
        //.withWillTopic('inv/' + '$_currentUser.email' + '/app')
        .withWillTopic('${_prefs.getString('rootTopic')}' +
            'users/' +
            '${_currentUser.email}' +
            '/app')
        .withWillMessage('$left,$top')
        .startClean()
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

    final topic1 = '${_prefs.getString('rootTopic')}' +
        'users/' +
        '${_currentUser.email}' +
        '/#'; // Wildcard topic
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

      debugPrint("[MQTT client] ${event[0].topic}: $message");

      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'users/' +
              '${_currentUser.email}' +
              '/add') ==
          0) {
        _panelADD(message);
      } else if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'users/' +
              '${_currentUser.email}' +
              '/del') ==
          0) {
        _panelDEL(message);
      }
    } else {
      debugPrint('device list not mounted');
      onDisConnected();
    }
  }
}
