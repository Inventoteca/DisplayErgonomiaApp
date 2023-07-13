import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../screens/device_list_page.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '/utils/validator.dart';
import 'dart:convert';

late User _currentUser;
late RangeValues _currentRangeValues = const RangeValues(15, 30);
late dynamic jsonValue;
late int diaHoy = 31;

var _user = {
  "name": "${_currentUser.displayName}",
  "Ts": '${DateTime.now().millisecondsSinceEpoch}',
  "email": "${_currentUser.email}",
};

class ConfigPanelCruz extends StatefulWidget {
  final User user;
  final String name;
  final String id;

  ConfigPanelCruz({
    Key? key,
    required this.user,
    required this.name,
    required this.id,
  }) : super(key: key);

  @override
  State<ConfigPanelCruz> createState() => _ConfigPanelCruzState();
}

class _ConfigPanelCruzState extends State<ConfigPanelCruz> {
  late String text;
  final TextEditingController textFieldController1 = TextEditingController();
  final TextEditingController textFieldController2 = TextEditingController();
  Color? selectedColor;

  int? selectedOption; // Variable para almacenar la opción seleccionada

  final List<String> options = [
    "Sin incidentes",
    "Casi accidentes",
    "No incapacitante",
    "Primer auxilio",
    "Accidente incapacitante",
  ];

  final List<int> ignoredIndices = [
    1,
    2,
    6,
    7,
    8,
    9,
    13,
    14,
    36,
    37,
    41,
    42,
    43,
    44,
    48,
    49
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    final panelID = widget.id;

    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');
    ref.child('actual/z_user').update(_user);
    debugPrint(panelID);
    debugPrint('conifg');
  }

  @override
  void dispose() {
    textFieldController1.dispose();
    textFieldController2.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var name = widget.name;
    final nameTextController = TextEditingController();
    nameTextController.text = name;
    final focusName = FocusNode();
    return Card(
      elevation: 10,
      color: CustomColors.panelBack,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Configuracion:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 35,
                ),
              ),
            ),
            TextFormField(
              maxLines: 1,
              style: TextStyle(fontSize: 20, color: CustomColors.firebaseAmber),
              controller: nameTextController,
              focusNode: focusName,
              validator: (value) => Validator.validateName(
                name: value,
              ),
              decoration: InputDecoration(
                hintStyle:
                    TextStyle(fontSize: 25, color: CustomColors.firebaseAmber),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _buildDayNumberGrid(diaHoy, ignoredIndices, Colors.green),
            _buildRow(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final name = nameTextController.text;
                    _updatePanelName(name);
                    debugPrint(name);

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => DeviceList(
                          user: _currentUser,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Actualizar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Eliminar panel'),
                          content: Text(
                              '¿Estás seguro de que deseas eliminar el panel?'),
                          actions: [
                            TextButton(
                              child: Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Aceptar'),
                              onPressed: () {
                                _deletePanel();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => DeviceList(
                                      user: _currentUser,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Text(widget.id),
          ],
        ),
      ),
    );
  }

// ---------------------------------------- _deletePanel
  Future<void> _deletePanel() async {
    if (mounted) {
      final db = FirebaseFirestore.instance;
      final panelID = widget.id;
      try {
        db
            .collection("users")
            .doc('${_currentUser.email}')
            .collection('devices')
            .doc('$panelID')
            .delete();

        debugPrint('$panelID');
      } on FirebaseAuthException catch (e) {
        debugPrint('$e');
      }
    }
  }

// ----------------------------------------------- _updatePanelName
  Future<void> _updatePanelName(var name) async {
    if (mounted) {
      final db = FirebaseFirestore.instance;
      final panelID = widget.id;

      var encode = {'id': panelID, 'type': 'cruz', 'name': name};

      Map<String, dynamic> data = encode;
      debugPrint('$data');
      try {
        db
            .collection("users")
            .doc('${_currentUser.email}')
            .collection('devices')
            .doc('${data['id']}')
            .set(data);
      } on FirebaseAuthException catch (e) {
        debugPrint('$e');
      }

      var _config = {
        "name": "${data['name']}",
        "mainTime": int.parse(textFieldController1.text),
      };

      Map<String, dynamic> configData = _config;
      debugPrint('$configData');

      final DatabaseReference ref =
          FirebaseDatabase.instance.ref('/panels/$panelID/');
      ref.child('config').update(configData);
    }
  }

// ---------------------------------------------- rowColor
  Widget _buildRow() {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return StreamBuilder(
      stream: ref.child('config').onValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          DataSnapshot data = snapshot.data.snapshot;

          jsonValue = data.value;
          //debugPrint('$jsonValue');

          textFieldController1.text = jsonValue["mainTime"].toString();

          return Column(
            children: [
              ListTile(
                title: Text(
                  'Color ',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(jsonValue["defColor"]),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Seleccionar color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: Color(jsonValue["defColor"]),
                            onColorChanged: (color) {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                            pickerAreaHeightPercent: 0.8,
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Aceptar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (selectedColor != null) {
                                ref.child('config').update({
                                  "defColor": selectedColor!.value,
                                });
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          );
        } else {
          return Text(
            "...",
            style: TextStyle(color: Colors.transparent),
          );
        }
      },
    );
  }

  //----------------------------- cruz
  Widget _buildDayNumberGrid(
      int diaHoy, List<int> ignoredIndices, Color dayColor) {
    final panelID = widget.id;
    int mes = 0;
    int anio = 23;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: StreamBuilder(
          stream: ref.child('actual').onValue,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              DataSnapshot data = snapshot.data.snapshot;
              final dynamic jsonValue = data.value;
              final int timeNow = jsonValue["time"] as int;
              final int gmtOff = jsonValue["gmtOff"];

              final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                  (timeNow - gmtOff) * 1000);
              final dynamic events = jsonValue["events"];

              diaHoy = dateTime.day;
              mes = dateTime.month;
              anio = dateTime.year;

              return GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                children: List.generate(49, (index) {
                  int dayNumber = index + 1;
                  final bool isIgnored = ignoredIndices.contains(dayNumber);

                  if (isIgnored) {
                    return Container();
                  }

                  if (index >= 2 && index <= 5)
                    dayNumber = index - 1;
                  else if (index >= 9 && index <= 12)
                    dayNumber = index - 5;
                  else if (index >= 14 && index <= 35)
                    dayNumber = index - 7;
                  else if (index >= 37 && index <= 40)
                    dayNumber = index - 9;
                  else if (index >= 44 && index <= 47) dayNumber = index - 13;

                  if (dayNumber > diaHoy)
                    dayColor = Colors.transparent;
                  else {
                    if (events != null && events is Map) {
                      //debugPrint('$events');
                      // Acceder a los valores del objeto "events"
                      final int? eventDay = events['$dayNumber'] as int?;

                      //final int eventNumber = events["number"] as int?;
                      // ... otros valores del objeto "events"

                      // Utilizar los valores extraídos
                      if (eventDay != null /*&& eventNumber != null*/) {
                        // Realizar acciones con eventDay y eventNumber
                        //debugPrint('$eventDay');
                        if (eventDay == 0)
                          dayColor = Colors.green;
                        else if (eventDay == 1)
                          dayColor = Colors.orange;
                        else if (eventDay == 2)
                          dayColor = Colors.blue;
                        else if (eventDay == 3)
                          dayColor = Colors.yellow;
                        else if (eventDay == 4) dayColor = Colors.red;
                      } else
                        dayColor = Colors.green;
                    } else {
                      //debugPrint('null');
                      dayColor = Colors.green;
                    }
                  }
                  //

                  return GestureDetector(
                    onTap: () {
                      if (dayNumber <= diaHoy) {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length +
                                  1, // Add 1 for the dayNumber item
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  // First item is the dayNumber
                                  return ListTile(
                                    title: Text(
                                      'Fecha: $dayNumber / $mes / $anio ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        //color: dayColor,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Remaining items are options
                                  return ListTile(
                                    title: Text(options[index -
                                        1]), // Subtract 1 to adjust index
                                    onTap: () {
                                      setState(() {
                                        selectedOption = index -
                                            1; // Update the selected option
                                        //debugPrint('');
                                      });
                                      Navigator.pop(context); // Close the modal
                                      debugPrint(
                                          'events: $dayNumber, $selectedOption');
                                      //if (selectedColor != null) {
                                      ref.child('config/events/').update({
                                        '$dayNumber': selectedOption,
                                      });
                                      //}
                                    },
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CustomColors.firebaseOrange,
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: dayColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            } else {
              return Container(); // Placeholder mientras carga los datos
            }
          },
        ),
      ),
    );
  }
}
