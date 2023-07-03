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
          title: Text('Perfil'),
        ),
        body: Center(
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
              /*_currentUser.emailVerified
                  ? Text(
                      'Email verificado',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.green),
                    )
                  : Text(
                      'Email NO verificado',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.red),
                    ),
              SizedBox(height: 16.0),*/

              /*_isSendingVerification
                  ? CircularProgressIndicator()
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isSendingVerification = true;
                            });
                            await _currentUser.sendEmailVerification();
                            setState(() {
                              _isSendingVerification = false;
                            });
                          },
                          child: Text('Verifcar email'),
                        ),
                        SizedBox(width: 8.0),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () async {
                            User? user =
                                await FireAuth.refreshUser(_currentUser);

                            if (user != null) {
                              setState(() {
                                _currentUser = user;
                              });
                            }
                          },
                        ),
                      ],
                    ),*/
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
                        // backgroundColor: Colors.red,
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
