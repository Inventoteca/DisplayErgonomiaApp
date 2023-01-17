import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/device_list_page.dart';
import '/utils/fire_auth.dart';
import '/utils/validator.dart';
//import 'package:device_info/device_info.dart';
import 'dart:io';

late SharedPreferences _prefs;
String _errorMsg = '';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  bool _isObscure = true;
  //final SharedPreferences prefs;

  bool _isProcessing = false;

  @override
  void initState() {
    // implement initState
    _loadConfig();
    super.initState();
  }

  // -------------------------------- _loadConfig
  Future _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final prefBroker = prefs.getString('broker') ?? 'inventoteca.com';
    final prefPort = prefs.getInt('port') ?? 1883;
    final prefMqttClient = prefs.getString('mqttClient') ?? await _getId();
    final rootTopic = prefs.getString('rootTopic') ?? 'smart/';
    setState(() {
      // mqttClient = prefMqttClient;
      // broker = prefBroker;
      // port = prefPort;

      prefs.setString('broker', prefBroker);
      prefs.setString('mqttClient', prefMqttClient);
      prefs.setInt('port', prefPort);
      prefs.setString('rootTopic', rootTopic);

      _prefs = prefs;

      //debugPrint('$mqttClient');
    });
    //client = MqttServerClient('test.mosquitto.org', '');
    //client = MqttServerClient(broker, mqttClient);
    //connect('topicoapp', 'msg app');
  }

  // -------------------------------- _getId
  Future _getId() async {
    // var deviceInfo = DeviceInfoPlugin();
    String clientID = '';
    if (Platform.isIOS) {
      // import 'dart:io'
      // var iosDeviceInfo = await deviceInfo.iosInfo;
      // clientID = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      //var androidDeviceInfo = await deviceInfo.androidInfo;
      //clientID = androidDeviceInfo.androidId; // unique ID on Android
    }
    return clientID;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Registro'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _registerFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nameTextController,
                        focusNode: _focusName,
                        validator: (value) => Validator.validateName(
                          name: value,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nombre',
                          hintText: "Introduce tu Nombre",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Correo',
                          hintText: "Introduce un correo válido",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: _isObscure,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Contraseña',
                          hintText: "Debe contener al menos 6 caracteres",
                          suffixIcon: IconButton(
                              icon: Icon(_isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              }),
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.0),
                      _isProcessing
                          ? CircularProgressIndicator()
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        _isProcessing = true;
                                      });

                                      if (_registerFormKey.currentState!
                                          .validate()) {
                                        User? user = await FireAuth
                                            .registerUsingEmailPassword(
                                          name: _nameTextController.text,
                                          email: _emailTextController.text,
                                          password:
                                              _passwordTextController.text,
                                        );

                                        user?.updateDisplayName(
                                            _nameTextController.text);

                                        setState(() {
                                          //_prefs.setString('DisplayNAme',
                                          //   _nameTextController.text);
                                          _isProcessing = false;
                                        });

                                        if (user != null) {
                                          //var _prefs;
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) => DeviceList(
                                                user: user,
                                                prefs: _prefs,
                                              ),
                                            ),
                                            ModalRoute.withName('/'),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      'Registrar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showError(BuildContext context, String errorMsg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMsg),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
