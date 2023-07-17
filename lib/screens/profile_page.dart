import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/login_page.dart';
//import '/utils/fire_auth.dart';
//import '/screens/panel_page.dart';
import '/screens/NavBar.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '/res/custom_colors.dart';
import '/utils/authentication.dart';

//late SharedPreferences _prefs;
late User _currentUser;

class ProfilePage extends StatefulWidget {
  final User user;
  //final SharedPreferences prefs;

  const ProfilePage({
    required this.user,
    /*required this.prefs*/
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //bool _isSendingVerification = false;
  bool _isSigningOut = false;

  final _focusName = FocusNode();

  @override
  void initState() {
    _currentUser = widget.user;
    // _prefs = widget.prefs;
    //_user = widget.user;
    super.initState();
    debugPrint('UID ${_currentUser.uid}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
      },
      child: Scaffold(
        drawer: NavBar(
          user: _currentUser,
          //prefs: _prefs,
        ),
        appBar: AppBar(
          title: Text('Cuenta'),
        ),
        body: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(20),
          elevation: 10,
          color: CustomColors.panel,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(),
              _currentUser.photoURL != null
                  ? ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Image.network(
                          _currentUser.photoURL!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: CustomColors.firebaseGrey,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 16.0),
              Text(
                '${_currentUser.displayName}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 16.0),
              Text(
                '${_currentUser.email}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 16.0),
              _isSigningOut
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isSigningOut = true;
                        });
                        await FirebaseAuth.instance.signOut();
                        await Authentication.signOut(context: context);
                        setState(() {
                          _isSigningOut = false;
                        });
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: Text('Cerrar Cesión'),
                      style: ElevatedButton.styleFrom(
                        //
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
