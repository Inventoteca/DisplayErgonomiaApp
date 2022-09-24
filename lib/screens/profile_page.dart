import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/login_page.dart';
import '/utils/fire_auth.dart';
import '/utils/validator.dart';
//import '/screens/panel_page.dart';
import '/screens/NavBar.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;

  late User _currentUser;
  final _nameTextController = TextEditingController();
  final _focusName = FocusNode();

  @override
  void initState() {
    _currentUser = widget.user;
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
        drawer: NavBar(user: _currentUser),
        appBar: AppBar(
          title: Text('Perfil'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nombre: ${_currentUser.displayName}',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              TextFormField(
                controller: _nameTextController,
                focusNode: _focusName,
                validator: (value) => Validator.validateName(
                  name: value,
                ),
                decoration: InputDecoration(
                  hintText: "Nombre",
                  errorBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              //Text(
              //  'ID: ${_currentUser.uid}',
              //  style: Theme.of(context).textTheme.bodyText1,
              //),
              SizedBox(height: 16.0),
              Text(
                'email: ${_currentUser.email}',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await _currentUser.updatePhotoURL(_nameTextController.text);
                },
                child: Text('Actualizar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              _currentUser.emailVerified
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
              SizedBox(height: 16.0),
              _isSendingVerification
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
