// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_industry/widgets/panelPro_widget.dart';
//import 'package:smart_industry/utils/mqtt_client.dart';
import '../widgets/panelCruz_widget.dart';
import '/widgets/panelErgo_widget.dart';
import '/utils/qr_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/utils/validator.dart';
import 'wifi_config_page.dart';
//import '/res/custom_icons.dart';
//import 'package:shared_preferences/shared_preferences.dart';

late List<dynamic> panelDataList = List.empty(growable: true);
late User _currentUser;
late bool _demo = false;
late String _code = '{"id":"demo","type":"demo"}';
//late SharedPreferences _prefs;

late var _parsed = jsonDecode('{}');
late var nameTextController = TextEditingController();

class QRDeviceAdd extends StatefulWidget {
  final User user;
  final bool demo;
  // final SharedPreferences prefs;

  const QRDeviceAdd({
    Key? key,
    required this.user,
    required this.demo,
  }) : super(key: key);

  @override
  State<QRDeviceAdd> createState() => _QRDeviceAddState();
}

class _QRDeviceAddState extends State<QRDeviceAdd> {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  //final _focusName = FocusNode();

  void initState() {
    //_loadConfig();
    _currentUser = widget.user;
    _demo = widget.demo;
    //_prefs = widget.prefs;

    super.initState();
  }

  @override
  void dispose() {
    //onDisConnected();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_demo == false)
      return Scaffold(
        appBar: AppBar(
          title: const Text("Escanear código QR"),
        ),
        body: Stack(
          children: [
            MobileScanner(
                allowDuplicates: false,
                controller: cameraController,
                onDetect: (barcode, args) {
                  //final String? code = barcode.rawValue;
                  _foundBarcode(barcode, args);
                  //debugPrint('Barcode found! $code');
                }),
            QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
          ],
        ),
        //QRScannerOverlay(overlayColour: null,),
      );
    else
      setState(() {
        _parsed = jsonDecode(_code);
      });
    return Scaffold(
      //appBar: AppBar(
      //title: const Text("Probar Panel Demo"),
      //),
      body: Stack(
        children: [
          FoundCodeScreen(value: _code, screenClosed: _screenWasClosed)
        ],
      ),
    );
  }

  void _foundBarcode(Barcode barcode, MobileScannerArguments? args) {
    /// open screen
    var parsed = jsonDecode('{}');
    if (!_screenOpened) {
      final String code = barcode.rawValue ?? "---";
      try {
        parsed = jsonDecode(code);

        if (parsed['id'] != null) {
          debugPrint('Barcode found! $parsed');
          setState(() {
            _parsed = parsed;
          });
          //_panelADD(code);
          //var data =
          //      '{"id":"$parsed","type":"ergo","name":"Nuevo","mod":true}';
          _screenOpened = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FoundCodeScreen(screenClosed: _screenWasClosed, value: code),
            ),
          );
        }
      } catch (e) {
        // final parsed = {};

      }
    }
  }

  void _screenWasClosed() {
    _screenOpened = false;
  }
}

class FoundCodeScreen extends StatefulWidget {
  final String value;
  final Function() screenClosed;
  const FoundCodeScreen({
    Key? key,
    required this.value,
    required this.screenClosed,
  }) : super(key: key);

  @override
  State<FoundCodeScreen> createState() => _FoundCodeScreenState();
}

class _FoundCodeScreenState extends State<FoundCodeScreen> {
  final nameTextController = TextEditingController();
  final focusName = FocusNode();
  final registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Configurando dispositivo"),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              widget.screenClosed();
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_outlined,
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Form(
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Padding(padding: EdgeInsets.all(20)),
              //SizedBox(height: 45.0),

              //SizedBox(height: 20.0),
              if (_parsed["type"] != null)
                if (_parsed["type"] == 'cruz')
                  Card(
                    elevation: 10,
                    margin: EdgeInsets.all(30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Cruz de Seguridad",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: nameTextController,
                            focusNode: focusName,
                            validator: (value) => Validator.validateName(
                              name: value,
                            ),
                            decoration: InputDecoration(
                              labelText: //Text(
                                  'Nombre',
                              //style: TextStyle(
                              //  fontSize: 10,
                              //),
                              // ),

                              //hintStyle: ,
                              //hintText: Text('Introduce un nombre para tu dispositivo'),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 3, color: Colors.orange),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 3, color: Colors.orange),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 3, color: Colors.orange),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              //labelText: 'Nombre',
                              //hintText: "Introduce un nombre para tu dispositivo",

                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                              "Con este panel puedes registrar los días sin accidentes y otras incidencias en el mes." /*widget.value*/,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              )),
                          SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                //if (_registerFormKey.currentState!
                                //.validate()) {
                                var name = nameTextController.text;
                                //debugPrint(widget.value['id']);
                                var decode = jsonDecode(widget.value);
                                //debugPrint('${decode['id']}');

                                String _id = decode['id'];
                                String type = decode['type'];

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => WifiConfig(
                                      user: _currentUser,
                                      id: _id,
                                      name: name,
                                      type: type,
                                      demo: false,
                                    ),
                                  ),
                                );
                              },
                              child: Text("Continuar"))
                        ],
                      ),

                      /*
                      Text(
                        widget.value,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),*/
                    ),
                  ),
              if (_parsed["type"] == 'ergo')
                Card(
                  elevation: 10,
                  margin: EdgeInsets.all(30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("Ergonomía Ambiental" /*widget.value*/,
                            style: TextStyle(
                              fontSize: 20,
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: nameTextController,
                          focusNode: focusName,
                          validator: (value) => Validator.validateName(
                            name: value,
                          ),
                          decoration: InputDecoration(
                            labelText: //Text(
                                'Nombre',
                            //style: TextStyle(
                            //  fontSize: 10,
                            //),
                            // ),

                            //hintStyle: ,
                            //hintText: Text('Introduce un nombre para tu dispositivo'),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 3, color: Colors.orange),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 3, color: Colors.orange),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 3, color: Colors.orange),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            //labelText: 'Nombre',
                            //hintText: "Introduce un nombre para tu dispositivo",

                            errorBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                            "Con este panel puedes leer Temperarura, Humedad relativa, luz ambiental y ultravioleta, así como el ruido y las párticulas de CO en el ambiente." /*widget.value*/,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        //Text(
                        //    "Ahora vamos a configurar su conexión a Internet." /*widget.value*/,
                        //    style: TextStyle(
                        //      fontSize: 16,
                        //    )),
                        SizedBox(
                          height: 20,
                        ),
                        Icon(
                          Icons.thermostat,
                          size: 50,
                        ),
                        Icon(
                          Icons.local_florist_rounded,
                          size: 50,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              //if (_registerFormKey.currentState!
                              //.validate()) {
                              var name = nameTextController.text;
                              //debugPrint(widget.value['id']);
                              var decode = jsonDecode(widget.value);
                              //debugPrint('${decode['id']}');

                              String _id = decode['id'];
                              String type = decode['type'];

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => WifiConfig(
                                    user: _currentUser,
                                    id: _id,
                                    name: name,
                                    type: type,
                                    demo: false,
                                  ),
                                ),
                              );
                            },
                            child: Text("Continuar"))
                      ],
                    ),
                  ),
                ),
              if (_parsed["type"] == 'demo')
                new Container(
                  child: Column(
                    children: [
                      Text(
                        "Seleccione un tipo de  panel a probar" /*widget.value*/,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => WifiConfig(
                                user: _currentUser,
                                id: '01',
                                name: 'Panel Ergo',
                                type: 'ergo',
                                demo: true,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 180,
                          height: 330,
                          child: PanelErgo(
                              user: _currentUser,
                              name: 'Ergonomía Ambiental',
                              id: '01'),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => WifiConfig(
                                user: _currentUser,
                                id: '03',
                                name: 'Panel Cruz',
                                type: 'cruz',
                                demo: true,
                              ),
                            ),
                          );
                        },
                        child: panelCruz(
                            // panelErgo(
                            user: _currentUser,
                            name: 'Cruz de seguridad'),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => WifiConfig(
                                user: _currentUser,
                                id: '02',
                                name: 'Panel Productividad',
                                type: 'pro',
                                demo: true,
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 180,
                          height: 330,
                          child: PanelPro(
                              // panelErgo(
                              user: _currentUser,
                              name: 'Productividad'),
                        ),
                      ),
                    ],
                  ),
                ),
            ]),
          ),
        )));
  }
}
