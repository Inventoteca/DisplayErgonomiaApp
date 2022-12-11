import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import '/screens/profile_page.dart';
import '/screens/device_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;

class NavBar extends StatefulWidget {
  final User user;
  final SharedPreferences prefs;

  const NavBar({required this.user, required this.prefs});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late User _currentUser;

  void initState() {
    _currentUser = widget.user;
    _prefs = widget.prefs;
    super.initState();
    debugPrint('UID ${_currentUser.displayName}');
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
                child: Image.network(
                  'https://static.wixstatic.com/media/1f433e_ae1479d6202f4695b47c5469b98eec67~mv2.png/v1/fill/w_268,h_208,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/Smart%20industry.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Dispositivos'),
            onTap: () => {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DeviceList(
                    user: _currentUser,
                    prefs: _prefs,
                  ),
                ),
              ),
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Alertas'),
            onTap: () => null,
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
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Reportes'),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ajustes'),
              onTap: () => {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          user: _currentUser,
                          prefs: _prefs,
                        ),
                      ),
                    ),
                  }),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Nosotros'),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Tiket de Servicio'),
            onTap: () => null,
          ),
        ],
      ),
    );
  }
}
