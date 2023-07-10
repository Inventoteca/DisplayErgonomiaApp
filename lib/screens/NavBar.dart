//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_industry/screens/chat_page.dart';
//import 'package:smart_industry/screens/report_list_page.dart';
import '/screens/about_us_page.dart';
//import 'package:firebase_core/firebase_core.dart';
import '/screens/profile_page.dart';
//import '/screens/user_info_screen.dart';
//import '/screens/device_list_page.dart';
import 'device_list_page.dart';
import '/screens/report_list_page.dart';
//import 'package:shared_preferences/shared_preferences.dart';

//late SharedPreferences _prefs;

class NavBar extends StatefulWidget {
  final User user;
  // final SharedPreferences prefs;

  const NavBar({
    required this.user,
    /* required this.prefs*/
  });

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late User _currentUser;

  void initState() {
    _currentUser = widget.user;
    // _prefs = widget.prefs;
    super.initState();
    debugPrint('Name ${_currentUser.displayName}');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("${_currentUser.displayName}"),
            accountEmail: Text("${_currentUser.email}"),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'lib/images/SmartIndustry.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: AssetImage('lib/images/charts.jpg'),
                  colorFilter:
                      ColorFilter.mode(Colors.grey[800]!, BlendMode.modulate)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.devices),
            title: Text('Dispositivos'),
            onTap: () => {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DeviceList(
                    user: _currentUser,
                    //prefs: _prefs,
                  ),
                ),
              ),
            },
          ),
          /*ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Alertas'),
            onTap: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                      // user: _currentUser,
                      //prefs: _prefs,
                      ),
                ),
              ),
            },
            trailing: ClipOval(
              child: Container(
                color: Colors.red,
                width: 20,
                height: 20,
                child: Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),*/
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Reportes'),
            onTap: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportListPage(
                    user: _currentUser,
                    //prefs: _prefs,
                  ),
                ),
              ),
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Nosotros'),
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AboutUs(),
              ))
            },
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ajustes'),
              onTap: () => {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          user: _currentUser,
                          //prefs: _prefs,
                        ),
                      ),
                    ),
                  }),
          /*ListTile(
            leading: Icon(Icons.share),
            title: Text('Tiket de Servicio'),
            onTap: () => null,
          ),*/
        ],
      ),
    );
  }
}
