import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '/screens/profile_page.dart';
import '/screens/register_page.dart';
import 'device_list_page.dart';
//import '/screens/panel_page.dart';
//import '/screens/panelList_page.dart';
import '/utils/fire_auth.dart';
import '/utils/validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:device_info/device_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';

//late User _currentUser;
//late User user;
late SharedPreferences _prefs;
late String broker = '';
late int port = 0;
late String mqttClient = '';
//late User _currentUser;

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

  bool _isProcessing = false;

  void initState() {
    //_currentUser = user;
    _loadConfig();
    super.initState();
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
          ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
    };
  }

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );

    User? user = FirebaseAuth.instance.currentUser;

    //if (user != null) {
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //     builder: (context) => DeviceList(
    //       user: user,
    //       prefs: _prefs,
    //     ),
    //   ),
    // );
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
        //appBar: AppBar(
        //  title: Text('Smart Industry'),
        //),
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'lib/images/SmartIndustry.png',
                      fit: BoxFit.contain,
                    ),

                    //child: Image.asset('images/logoVertical'),
                    //  child: Image.file(
                    //    file:'images/LogoVertical.png',
                    //    fit: BoxFit.cover,),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _emailTextController,
                            focusNode: _focusEmail,
                            validator: (value) => Validator.validateEmail(
                              email: value,
                            ),
                            decoration: InputDecoration(
                              hintText: "Correo",
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            controller: _passwordTextController,
                            focusNode: _focusPassword,
                            obscureText: true,
                            validator: (value) => Validator.validatePassword(
                              password: value,
                            ),
                            decoration: InputDecoration(
                              hintText: "Contraseña",
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
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

                                            User? user = await FireAuth
                                                .signInUsingEmailPassword(
                                              email: _emailTextController.text,
                                              password:
                                                  _passwordTextController.text,
                                            );

                                            setState(() {
                                              _isProcessing = false;
                                            });

                                            if (user != null) {
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfilePage(
                                                    user: user,
                                                    prefs: _prefs,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: Text(
                                          'Entrar',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterPage(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Registrarse',
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

  // -------------------------------- _getId
  Future _getId() async {
    //var deviceInfo = DeviceInfoPlugin();
    String clientID = '';
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    //Map<String, dynamic> _deviceData = <String, dynamic>{};
    var deviceData = <String, dynamic>{};
    if (Platform.isIOS) {
      // import 'dart:io'
      //var iosDeviceInfo = await deviceInfo.iosInfo;
      //clientID = iosDeviceInfo.identifierForVendor; // unique ID on iOS
      deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      clientID = deviceData['identifierForVendor'];
      final splitted = clientID.split('-');
      clientID = '${splitted[4]}';
      //debugPrint(clientID);
    } else if (Platform.isAndroid) {
      //var androidDeviceInfo = await deviceInfo.androidInfo;
      //clientID = androidDeviceInfo.androidId; // unique ID on Android
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      clientID = deviceData['id'];
    }
    return clientID;
  }

  // -------------------------------- _loadConfig
  Future _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final prefBroker = prefs.getString('broker') ?? 'inventoteca.com';
    final prefPort = prefs.getInt('port') ?? 1883;
    //final prefMqttClient = prefs.getString('mqttClient') ?? await _getId();
    final prefMqttClient = await _getId();
    debugPrint(prefMqttClient);
    final rootTopic = prefs.getString('rootTopic') ?? 'smart/';
    setState(() {
      mqttClient = prefMqttClient;
      broker = prefBroker;
      port = prefPort;

      _prefs = prefs;

      prefs.setString('broker', prefBroker);
      prefs.setString('mqttClient', mqttClient);
      prefs.setInt('port', port);
      prefs.setString('rootTopic', rootTopic);

      //debugPrint('$mqttClient');
    });
    //client = MqttServerClient('test.mosquitto.org', '');
    //client = MqttServerClient(broker, mqttClient);
    //connect('topicoapp', 'msg app');
  }
}
