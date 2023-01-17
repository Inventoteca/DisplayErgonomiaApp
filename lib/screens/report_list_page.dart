//import 'dart:async';
// ignore_for_file: deprecated_member_use, unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/material.dart';
//import '/screens/profile_page.dart';
import '/screens/NavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:convert';
import 'package:path_provider/path_provider.dart';
//import 'package:client_information/client_information.dart';
//import 'package:json_annotation/json_annotation.dart';

late User _currentUser;

late SharedPreferences _prefs;
late List<dynamic> panelDataList = List.empty(growable: true);

class ReportListPage extends StatefulWidget {
  final User user;
  final SharedPreferences prefs;

  const ReportListPage({required this.user, required this.prefs});

  @override
  _ReportListPageState createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
    _prefs = widget.prefs;
    _loadConfig();
    super.initState();
    debugPrint('UID ${_currentUser.uid}');
  }

  //@override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(
          user: _currentUser,
          prefs: _prefs,
        ),
        appBar: AppBar(
          title: Text('Reportes'),
        ),
        body: projectWidget());
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
                    child: Text('${panelDataList.elementAt(index)}'),
                    //child: Text('$index'),
                    onPressed: () => {
                      downloadReport()
                      /*if (panelDataList.elementAt(index)['type'] == 'ergo')
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
                        }*/
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

// -------------------------------- _loadConfig
  Future<void> downloadReport() async {
    debugPrint('Download');
    //First you get the documents folder location on the device...
    Directory appDocDir = await getApplicationDocumentsDirectory();
    debugPrint('$appDocDir');
    //Here you'll specify the file it should be saved as
    // ignore: unused_local_variable
    File downloadToFile = File('${appDocDir.path}/Reporte.pdf');
    //Here you'll specify the file it should download from Cloud Storage
    //String fileToDownload = 'uploads/uploaded-pdf.pdf';

    final dirs = FirebaseStorage.instance
        .ref()
        .child('smart/')
        .child('users/')
        .child('${_currentUser.email}')
        .child('/data')
        .child('/panels.json');
    //.writeToFile(downloadToFile);

    //Now you can try to download the specified file, and write it to the downloadToFile.
    try {
      //var archi = await dirs;

      final io.Directory systemTempDir = io.Directory.systemTemp;
      final io.File tempFile =
          io.File('${systemTempDir.path}/temp-${dirs.name}');
      if (tempFile.existsSync()) await tempFile.delete();

      await dirs.writeToFile(tempFile);
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print('Download error: $e');
    }
  }

// -------------------------------- _loadConfig
  Future _loadConfig() async {
    final List<dynamic> listTemp = await _downloadFile();
    setState(() {
      panelDataList = listTemp;
      debugPrint('$panelDataList');
    });
  }

  Future<List<dynamic>> _downloadFile() async {
// Create a Reference to the file
    //File file;
    //String fileName = '${_currentUser.email}';

    /* final ref = FirebaseStorage.instance
        .ref()
        .child('smart/')
        .child('users/')
        .child('${_currentUser.email}')
        .child('/panels.json');*/

    final dirs = FirebaseStorage.instance
        .ref()
        .child('smart/')
        .child('users/')
        .child('${_currentUser.email}')
        .child('/data')
        .listAll();

    // UploadTask uploadTask = ref.putFile(file);

    try {
      // var tempList = await ref.listAll();
      final listResult = await dirs;
      listResult.items.forEach((dirs) {
        debugPrint('$dirs');
      });
      //tempList.items.forEach((ref) {
      //  print('Found file: $ref');
      //  return json.decode(tempList.toString());
      //});
      return listResult.items;
      //return List.empty();

      //final io.Directory systemTempDir = io.Directory.systemTemp;
      //final io.File tempFile =
      //    io.File('${systemTempDir.path}/temp-${ref.name}');
      //if (tempFile.existsSync()) await tempFile.delete();

      //await ref.writeToFile(tempFile);

      // return json.decode(tempFile.readAsStringSync()) as List;

    } on FirebaseException catch (e) {
      debugPrint('${e.code}: ${e.message}');
      return List.empty();
    }
  }
}
