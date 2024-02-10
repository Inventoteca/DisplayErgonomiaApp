import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '/screens/register_page.dart';
import 'device_list_page.dart';
import '/utils/fire_auth.dart';
import '/utils/validator.dart';
import '/firebase_options.dart';
import '/widgets/google_sign_in_button.dart';
import '/res/custom_colors.dart';
import '/utils/authentication.dart';
//import 'package:firebase_app_check/firebase_app_check.dart';
//import 'package:flutter/foundation.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  bool _isProcessing = true;
  bool _isObscure = true;
  String _errorMessage = '';

  void initState() {
    // _initializeFirebase();
    _isProcessing = false;
    super.initState();
  }

  // Initialize Firebase
  Future<FirebaseApp> _initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();

    User? user = FirebaseAuth.instance.currentUser;
    //final Firestore _db = Firestore.instance;

    //updateUserData(user!);

    FirebaseApp firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    /* await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: 'recaptcha-v3-site-key',
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. debug provider
      // 2. safety net provider
      // 3. play integrity provider
      androidProvider: AndroidProvider.debug,
    );*/

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DeviceList(
            user: user,
            // prefs: _prefs,
          ),
        ),
      );
    } //else {

    //}

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(
                child: Column(
                  //mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 35,
                    ),
                    if (_errorMessage
                        .isNotEmpty) // Display error message if it's not empty
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      margin: EdgeInsets.all(25),
                      elevation: 10,
                      color: CustomColors.panel,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 0, bottom: 15),
                        child: Column(
                          //mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: /*<Widget>*/ [
                            Image.asset(
                              'lib/images/SmartIndustry.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                            ),

                            Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  TextFormField(
                                    controller: _emailTextController,
                                    focusNode: _focusEmail,
                                    validator: (value) =>
                                        Validator.validateEmail(
                                      email: value,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Correo',
                                      hintText: "Introduce tu correo",
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  TextFormField(
                                    controller: _passwordTextController,
                                    obscureText: _isObscure,
                                    focusNode: _focusPassword,
                                    validator: (value) =>
                                        Validator.validatePassword(
                                      password: value,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Contraseña',
                                      hintText: "Introduce tu contraseña",
                                      suffixIcon: IconButton(
                                          icon: Icon(_isObscure
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              _isObscure = !_isObscure;
                                            });
                                          }),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  _isProcessing
                                      ? CircularProgressIndicator()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  _focusEmail.unfocus();
                                                  _focusPassword.unfocus();

                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    setState(() {
                                                      _isProcessing = true;
                                                    });

                                                    try {
                                                      final user = await FireAuth
                                                          .signInUsingEmailPassword(
                                                        email:
                                                            _emailTextController
                                                                .text,
                                                        password:
                                                            _passwordTextController
                                                                .text,
                                                      );

                                                      setState(() {
                                                        _isProcessing = false;
                                                      });

                                                      debugPrint('TRYING');

                                                      if (user != null) {
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    DeviceList(
                                                              user: user,
                                                              // prefs: _prefs,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      debugPrint('Alsmost');
                                                    } on FirebaseAuthException catch (e) {
                                                      debugPrint(
                                                          'Error message: $e');
                                                    }
                                                  }
                                                },
                                                child: Text(
                                                  'Entrar',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                          ],
                                        )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 35,
                            ),
                            FutureBuilder(
                              future: Authentication.initializeFirebase(
                                  context: context),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error initializing Firebase');
                                } else if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return GoogleSignInButton(
                                      //user: user,
                                      //prefs: _prefs,

                                      );
                                }
                                return CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    CustomColors.firebaseOrange,
                                  ),
                                );
                              },
                            ),

                            /*FutureBuilder(
                              future: Authentication.initializeFirebase(
                                  context: context),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error initializing Firebase');
                                } else if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return AppleSignInButton(
                                      //user: user,
                                      //prefs: _prefs,

                                      );
                                }
                                return CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    CustomColors.firebaseOrange,
                                  ),
                                );
                              },
                            ),*/

                            //SizedBox(
                            //  height: 30,
                            //),

                            //Text('Registrarse'),
                            //Expanded(
                            /*child: */
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Registrarse',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            //),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
