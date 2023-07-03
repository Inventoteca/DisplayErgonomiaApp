//import 'dart:async';
// ignore_for_file: deprecated_member_use, unused_element


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:smart_industry/screens/report_files_page.dart';
//import '/screens/profile_page.dart';
import '/screens/NavBar.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'dart:convert';
import 'package:path_provider/path_provider.dart';
//import 'package:client_information/client_information.dart';
//import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/services.dart' show rootBundle;

late User _currentUser;
late List<Map<String, dynamic>> jsonList = [];
late Future<ListResult> futureDirs;
late String panelName;

//late SharedPreferences _prefs;
late List<dynamic> panelDataList = List.empty(growable: true);

class ReportListPage extends StatefulWidget {
  final User user;
  //final SharedPreferences prefs;

  const ReportListPage({
    required this.user,
    /*required this.prefs*/
  });

  @override
  _ReportListPageState createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
    futureDirs = FirebaseStorage.instance
        .ref()
        .child('smart/')
        .child('users/')
        .child('${_currentUser.email}')
        .child('/data')
        .listAll();
    super.initState();
    debugPrint('UID ${_currentUser.uid}');
  }

  //@override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(
          user: _currentUser,
          //prefs: _prefs,
        ),
        appBar: AppBar(
          title: Text('Reportes'),
        ),
        body: projectWidget2() // projectWidget()
        );
  }

  Widget projectWidget2() {
    return FutureBuilder<ListResult>(
      future: futureDirs,
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          final dirs = snapshot.data!.prefixes;
          return ListView.builder(
              itemCount: dirs.length,
              itemBuilder: ((context, index) {
                final dir = dirs[index];

                return ExpansionTile(
                  title: Text(dir.name),
                  children: <Widget>[
                    FutureBuilder<ListResult>(
                      future: /*futureFiles(dir.name)*/
                          FirebaseStorage.instance
                              .ref()
                              .child('smart/')
                              .child('users/')
                              .child('${_currentUser.email}')
                              .child('/data/')
                              .child(dir.name)
                              .listAll(),
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          final files = snapshot.data!.items;
                          return ListView.builder(
                              itemCount: files.length,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: ((context, index) {
                                final file = files[index];
                                return ListTile(
                                  title: Text(file.name),
                                  trailing: IconButton(
                                    icon: Icon(Icons.download),
                                    onPressed: () async {
                                      final url = await file.getDownloadURL();
                                      final filename = file.name;
                                      final bytes = await readBytes(url);
                                      final dir =
                                          await getExternalStorageDirectory();
                                      final filePath = '${dir!.path}/$filename';
                                      await File(filePath).writeAsBytes(bytes);
                                    },
                                  ),
                                );
                              }));
                        } else
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                      }),
                    ),
                  ],
                );
              }));
        } else
          return const Center(
            child: CircularProgressIndicator(),
          );
      }),
    );
  }

  Future<Uint8List> readBytes(String url) async {
    final completer = Completer<Uint8List>();
    rootBundle.load(url).then((data) {
      completer.complete(data.buffer.asUint8List());
    }).catchError((e) {
      completer.completeError(e);
    });
    return completer.future;
  }
}
