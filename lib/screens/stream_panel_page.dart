import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:smart_industry/screens/config_panel_page.dart';
//import 'package:smart_industry/screens/charts_panel_page.dart';
//import 'package:mqtt_client/mqtt_client.dart';
//import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smart_industry/screens/chat_page.dart';
import 'package:smart_industry/screens/report_list_page.dart';
import 'package:smart_industry/widgets/config_panelCruz_widget.dart';
import 'package:smart_industry/widgets/config_panelPro_widget.dart';
import 'package:smart_industry/widgets/panelPro_widget.dart';
//import '/utils/mqtt_client.dart';
import '../widgets/panelCruz_widget.dart';
import '/widgets/panelErgo_widget.dart';
import '/screens/NavBar.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flip_card/flip_card.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';
import '/res/custom_colors.dart';
import '/widgets/config_panelErgo_widget.dart';

//MqttConnectionState? connectionState;
StreamSubscription? subscription;
late User _currentUser;
late String _panelID;
//late MqttServerClient client;
late String _name;
late String _type;
//late TooltipBehavior _tooltipBehavior;
late bool isCardView = true;
late CardSide _panelSide = CardSide.BACK;

//late String t = '0';
//late String h = '0';
//late String uv = '0.0';
//late String db = '0';
//late String lux = '0';
//late String ppm = '0';
//late String pt7 = '';

class StreamPanelPage extends StatefulWidget {
  final User user;
  //final SharedPreferences prefs;
  final String id;
  final String name;
  final String type;
  final CardSide side;

  const StreamPanelPage(
      {required this.user,
      /*required this.prefs,*/
      required this.id,
      required this.type,
      required this.name,
      required this.side});

  @override
  _StreamPanelPageState createState() => _StreamPanelPageState();
}

class _StreamPanelPageState extends State<StreamPanelPage> {
  late int count;
  //ChartSeriesController? _chartSeriesController;

  void initState() {
    _currentUser = widget.user;
    _panelID = widget.id;
    _name = widget.name;
    _type = widget.type;
    _panelSide = widget.side;
    debugPrint('$_name');
    //_tooltipBehavior = TooltipBehavior(enable: true);
    // _updateDataSource();
    super.initState();
    Wakelock.enable();
  }

  @override
  void dispose() {
    //chartData!.clear();
    //_chartSeriesController = null;
    Wakelock.disable();
    //readData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.panelBackground,
      drawer: NavBar(
        user: _currentUser,
      ),
      body: SingleChildScrollView(
        child: Center(
          heightFactor: 1.2,
          child: Hero(
            tag: '$_panelID',
            child: FlipCard(
              direction: FlipDirection.HORIZONTAL,
              side: _panelSide,
              speed: 1000,
              front: Column(
                children: [
                  if (_type == 'ergo')
                    SizedBox(
                      width: 350,
                      height: 700,
                      child: PanelErgo(
                        name: '$_name',
                        user: _currentUser,
                        id: _panelID,
                      ),
                    ),
                  if (_type == 'pro')
                    SizedBox(
                      width: 350,
                      height: 700,
                      child: PanelPro(
                        name: '$_name',
                        user: _currentUser,
                        //id: _panelID,
                      ),
                    ),
                  if (_type == 'cruz')
                    SizedBox(
                      width: 350,
                      height: 700,
                      child: panelCruz(
                        name: '$_name',
                        user: _currentUser,
                        id: _panelID,
                      ),
                    ),
                ],
              ),
              back: Column(
                children: [
                  if (_type == 'ergo')
                    SizedBox(
                      width: 350,
                      height: 700,
                      child: ConfigPanelErgo(
                        name: '$_name',
                        user: _currentUser,
                        id: _panelID,
                      ),
                    ),
                  if (_type == 'pro')
                    SizedBox(
                      width: 350,
                      height: 700,
                      child: ConfigPanelPro(
                        name: '$_name',
                        user: _currentUser,
                        id: _panelID,
                      ),
                    ),
                  if (_type == 'cruz')
                    SizedBox(
                      width: 350,
                      height: 700,
                      child: ConfigPanelCruz(
                        name: '$_name',
                        user: _currentUser,
                        id: _panelID,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        //marginBottom: 10, //margin bottom
        icon: Icons.more_horiz, //icon on Floating action button
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
          /* SpeedDialChild(
            //speed dial child
            child: Icon(Icons.settings),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Configuraciones',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ConfigPanelPro(
                    user: _currentUser,
                    name: _name,
                    //prefs: _prefs,
                    // id: _panelID,
                  ),
                ),
              );
            },
            //onLongPress: () => print('FIRST CHILD LONG PRESS'),
          ),*/
          SpeedDialChild(
            child: Icon(Icons.picture_as_pdf_rounded),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Reportes',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportListPage(
                    user: _currentUser,
                    //prefs: _prefs,
                  ),
                ),
              );
            },
            //onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),

          /*SpeedDialChild(
            child: Icon(Icons.add_alert),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Alertas',
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
                  builder: (context) => ChatScreen(
                      //user: _currentUser,
                      //prefs: _prefs,
                      //id: _panelID,
                      //name: _name,
                      ),
                ),
              );
            },
            //onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),*/
          //add more menu item children here
        ],
      ),
    );
  }
}
