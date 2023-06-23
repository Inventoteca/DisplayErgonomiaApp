import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:smart_industry/screens/NavBar.dart';
//import 'package:smart_industry/screens/config_panel_page.dart';
//import 'package:smart_industry/screens/panelList_page.dart';
//import 'package:smart_industry/screens/panel_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:smart_industry/screens/wifi_config_page.dart';
//import 'package:smart_industry/screens/panelList_page.dart';
import 'package:smart_industry/widgets/panelCruz_widget.dart';
//import '../res/custom_colors.dart';
//import '../widgets/config_panelPro_widget.dart';
import '../widgets/panelPro_widget.dart';
import '/widgets/panelErgo_widget.dart';
import '/screens/qr_device_add_page.dart';
//import '/screens/panel_page.dart';
import '/screens/stream_panel_page.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

late User _currentUser;

class DeviceList extends StatefulWidget {
  final User user;

  const DeviceList({required this.user});

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: NavBar(
        user: _currentUser,
        //prefs: _prefs,
      ),
      appBar: AppBar(
        title: Text('Dispositivos'),
      ),
      body: ProjectList(),
      floatingActionButton: SpeedDial(
        //marginBottom: 10, //margin bottom
        icon: Icons.add, //icon on Floating action button
        activeIcon: Icons.close, //icon when menu is expanded on button
        backgroundColor: Colors.deepOrangeAccent, //background color of button
        foregroundColor: Colors.white, //font color, icon color in button
        activeBackgroundColor:
            Colors.deepOrangeAccent, //background color when menu is expanded
        activeForegroundColor: Colors.white,
        // buttonSize: 56.0, //button size
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        // onOpen: () => print('OPENING DIAL'), // action when menu opens
        // onClose: () => print('DIAL CLOSED'), //action when menu closes

        elevation: 8.0, //shadow elevation of button
        shape: CircleBorder(), //shape of button

        children: [
          SpeedDialChild(
            //speed dial child
            child: Icon(Icons.description),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Demo',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        QRDeviceAdd(user: _currentUser, demo: true)),
              );
            },
            //onLongPress: () => print('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: Icon(Icons.qr_code_2_rounded),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'QR',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              //  onPublish(
              //      '0',
              //      '${_prefs.getString('rootTopic')}' +
              //          'panels/' +
              //          _panelID +
              //          '/app');
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) =>
                        QRDeviceAdd(user: _currentUser, demo: false)),
              );
            },
            //onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),
          /*SpeedDialChild(
            child: Icon(Icons.wifi),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'WiFi',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              //  onPublish(
              //      '0',
              //      '${_prefs.getString('rootTopic')}' +
              //          'panels/' +
              //          _panelID +
              //          '/app');
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => WifiConfig(
                      demo: false,
                      id: '',
                      name: 'WiFi',
                      type: '',
                      user: _currentUser)));
            },
            //onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),*/
          //add more menu item children here
        ],
      ),
    );
  }
}

class ExpansionTileList extends StatelessWidget {
  final List<DocumentSnapshot> documents;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ExpansionTileList({required this.documents});

  List<Widget> _getChildren() {
    List<Widget> children = [];
    documents.forEach((doc) {
      children.add(
        ProjectsExpansionTile(
          name: doc['name'],
          id: doc['id'],
          type: doc['type'],
          projectKey: doc.id,
          firestore: firestore,
        ),
      );
    });
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _getChildren(),
    );
  }
}

class ProjectList extends StatelessWidget {
  ProjectList();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('users')
          .doc('${_currentUser.email}')
          .collection('devices')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return CircularProgressIndicator(); //const Text('Loading...');
        //final int projectsCount = snapshot.data.documents.length;
        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return //Container();
            ExpansionTileList(
          documents: documents,
        );
      },
    );
  }
}

class ProjectsExpansionTile extends StatelessWidget {
  ProjectsExpansionTile(
      {required this.projectKey,
      required this.name,
      required this.firestore,
      required this.id,
      required this.type});

  final String projectKey;
  final String name;
  final String id;
  final String type;
  final FirebaseFirestore firestore;

  @override
  Widget build(BuildContext context) {
    PageStorageKey _projectKey = PageStorageKey('$projectKey');

    return Column(
      children: [
        // SizedBox(
        //   height: 40,
        // ),
        if (type == 'ergo')
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StreamPanelPage(
                    user: _currentUser,
                    id: id,
                    name: name,
                    type: 'ergo',
                    side: CardSide.FRONT,
                    //demo: true,
                  ),
                ),
              );
            },
            onLongPress: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StreamPanelPage(
                    user: _currentUser,
                    id: id,
                    name: name,
                    type: 'ergo',
                    side: CardSide.BACK,
                    //demo: true,
                  ),
                ),
              );
            },
            child: SizedBox(
              width: 180,
              height: 330,
              child: PanelErgo(
                user: _currentUser,
                name: name,
                id: id,
              ),
            ),
          ),
        if (type == 'cruz')
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StreamPanelPage(
                    user: _currentUser,
                    id: id,
                    name: name,
                    type: 'cruz',
                    side: CardSide.FRONT,
                    //demo: true,
                  ),
                ),
              );
            },
            child: SizedBox(
              width: 330,
              height: 330,
              child: Hero(
                tag: '$id',
                child: panelCruz(
                  user: _currentUser,
                  name: name,
                ),
              ),
            ),
          ),
        if (type == 'pro')
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StreamPanelPage(
                    user: _currentUser,
                    id: id,
                    name: name,
                    type: 'pro',
                    side: CardSide.FRONT,
                    //demo: true,
                  ),
                ),
              );
            },
            child: SizedBox(
              width: 180,
              height: 330,
              child: Hero(
                tag: '$id',
                child: PanelPro(
                  user: _currentUser,
                  name: name,
                ),
              ),
            ),
          ),
        /*ElevatedButton(
          onPressed: () {
            if (type == 'ergo') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PanelPage(user: _currentUser, id: id, name: name),
                ),
              );
            }
          },
          child: Text(
            name,
            style: TextStyle(fontSize: 28.0),
          ),
        ),*/
      ],
    );
    /*ExpansionTile(
          key: _projectKey,
          title: Text(
            name,
            style: TextStyle(fontSize: 28.0),
          ),
          children: <Widget>[
            /*StreamBuilder(
                stream: firestore
                    .collection('projects')
                    .doc(projectKey)
                    .collection('items')
                    .snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const Text('Loading...');
                  //final int surveysCount = snapshot.data.documents.length;
                  List<DocumentSnapshot> documents = snapshot.data!.docs;

                  List<Widget> surveysList = [];
                  documents.forEach((doc) {
                    PageStorageKey _surveyKey = new PageStorageKey('${doc.id}');

                    surveysList.add(ListTile(
                      key: _surveyKey,
                      title: Text(doc['ItemName']),
                    ));
                  });
                  return Column(children: surveysList);
                })*/
          ],
        ),*/
  }
}
