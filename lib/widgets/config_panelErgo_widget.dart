import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/device_list_page.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '/utils/validator.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

late User _currentUser;
//late var _t_max;
//late var _t_min;
//late var _icon_selected;
late RangeValues _currentRangeValues = const RangeValues(15, 30);
late dynamic jsonValue;

var _user = {
  "name": "${_currentUser.displayName}",
  "Ts": '${DateTime.now().millisecondsSinceEpoch}',
  "email": "${_currentUser.email}",
};

//late User _currentUser;

class ConfigPanelErgo extends StatefulWidget {
  final User user;
  final String name;
  final String id;

  const ConfigPanelErgo({
    Key? key,
    required this.user,
    required this.name,
    required this.id,
  }) : super(key: key);

  @override
  State<ConfigPanelErgo> createState() => _ConfigPanelErgoState();
}

class _ConfigPanelErgoState extends State<ConfigPanelErgo> {
  late String text;
  late IconData? selectedIcon = null; // Inicializar selectedIcon con null
  late Map<IconData, Color> iconColors;
  Color? selectedColor;

  @override
  void initState() {
    super.initState();

    iconColors = {
      Icons.thermostat: Colors.grey,
      Icons.water_drop_rounded: Colors.grey,
      Icons.sunny: Colors.grey,
      Icons.campaign_rounded: Colors.grey,
      Icons.light_rounded: Colors.grey,
      Icons.local_florist_rounded: Colors.grey,
    };

    _currentUser = widget.user;
    final panelID = widget.id;

    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');
    ref.child('actual/z_user').update(_user);
    debugPrint(panelID);
    selectedIcon = Icons.thermostat;
    iconColors[Icons.thermostat] = Colors.white;

    //debugPrint('update');

    //getLimits();
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
          //crossAxisAlignment: CrossAxisAlignment.spaceBetween,
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
            _setdata(
              units: ' ºC',
            ),
            //Botón eliminar y actualizar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text(
                    'Actualizar',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    final name = nameTextController.text;
                    _updatePanel(name);
                    debugPrint(name);

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => DeviceList(
                          user: _currentUser,
                          // prefs: _prefs,
                        ),
                      ),
                    );
                  },
                ),
/*                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // change button color to red
                  ),
                  onPressed: () {
                    //final name = nameTextController.text;
                    _deletePanel();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => DeviceList(
                          user: _currentUser,
                          // prefs: _prefs,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.white),
                  ),
                ), */ //Botón de borrar
              ],
            ),
            //Texto de id panel
            Text(widget.id),
          ],
        ),
      ),
    );
  }

/*Widget _buildColorPickerColumn() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _setColorPicker('Min', 't_colMin'),
      _setColorPicker('Def', 't_colDef'),
      _setColorPicker('Max', 't_colMax'),
    ],
  );
}*/

//Obtiene los datos de la base de datos

  Future<void> getLimits() async {
    var panelID = widget.id;
    DatabaseReference refID =
        FirebaseDatabase.instance.ref('/panels/$panelID/actual');

    refID.onValue.listen((DatabaseEvent event) {
      // The data from refID is available in the event parameter.
      // You can access the data using event.snapshot.value

      final dynamic jsonValue = event.snapshot.value;
      //debugPrint('$jsonValue');

      final int tMax = jsonValue["t_max"] as int;
      final int tMin = jsonValue["t_min"] as int;
      final Color tColmax = Color(jsonValue["t_colMax"]);
      final Color tColmin = Color(jsonValue["t_colMin"]);
      final Color tColdef = Color(jsonValue["t_colDef"]);

      _currentRangeValues = RangeValues(tMin.toDouble(), tMax.toDouble());
    }, onError: (error) {
      // Handle any errors that occur while retrieving data
      print('Error: $error');
    });
  }

//Elimina el panel demo (no se usa)
  //------------------------------------------------------------- _deletePanel
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

//Actualiza los datos del panel
  //------------------------------------------------------------- _updatePanel
  Future<void> _updatePanel(var name) async {
    if (mounted) {
      final db = FirebaseFirestore.instance;
      final panelID = widget.id;

      var encode = {'id': panelID, 'type': 'ergo', 'name': name};

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
    }
  }

  Widget _buildColorPickerTile({
    required Color currentColor,
    required ValueChanged<Color> onColorChanged,
    required String title,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            Color temporaryColor = currentColor;
            return AlertDialog(
              title: Text('Seleccionar color'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: currentColor,
                  // onColorChanged: onColorChanged,
                  onColorChanged: (Color color) {
                    // Actualiza el color temporalmente
                    temporaryColor = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: false,
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Guardar'),
                  onPressed: () {
                    onColorChanged(temporaryColor);
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: currentColor,
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            SizedBox(height: 8), // Espacio entre el cuadro de color y el texto
            Text(
              title,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

//Widget para poner los iconos con la funcion de selección
  Widget _iconset({
    IconData? icon,
    //String? text,
    String? units,
    //Color? color
  }) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      GestureDetector(
        onTap: () {
          // Cambiar el color del ícono al ser tocado
          setState(() {
            // Si ya hay un ícono seleccionado, restaura su color al valor inicial
            if (selectedIcon != null) {
              iconColors[selectedIcon!] = Colors.grey;
            }
            // Actualiza el ícono seleccionado y su color
            selectedIcon = icon;
            iconColors[icon!] = Colors.white;
          });
        },
        child: Icon(icon,
            color: iconColors[icon], size: 70), // Usar el color actualizado
      ),
    ]);
  }

  // ------------------------------------- T Row

  final TextEditingController _maxController = TextEditingController();
  final TextEditingController _minController = TextEditingController();

  Widget _setdata({
    String? units,
  }) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Columna para los iconos
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconset(icon: Icons.thermostat, units: 'Temperatura'),
            _iconset(icon: Icons.water_drop_rounded, units: ' ºC'),
            _iconset(icon: Icons.sunny, units: ' ºC'),
            _iconset(icon: Icons.campaign_rounded, units: ' ºC'),
            _iconset(icon: Icons.light_rounded, units: ' ºC'),
            _iconset(icon: Icons.local_florist_rounded, units: ' ºC'),
          ],
        ),
        // Columna para los number entrys y los color pickers
        Expanded(
          child: SizedBox(
            height: 400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primer text field
                StreamBuilder(
                  stream: ref.child('config').onValue,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      DataSnapshot data = snapshot.data!.snapshot;
                      Map<dynamic, dynamic>? jsonValue =
                          data.value as Map<dynamic, dynamic>?;

                      if (jsonValue != null) {
                        String tMax = jsonValue['t_max']?.toString() ?? '';
                        String tMin = jsonValue['t_min']?.toString() ?? '';
                        String hMax = jsonValue['h_max']?.toString() ?? '';
                        String hMin = jsonValue['h_min']?.toString() ?? '';
                        String uvMax = jsonValue['uv_max']?.toString() ?? '';
                        String uvMin = jsonValue['uv_min']?.toString() ?? '';
                        String dbMax = jsonValue['db_max']?.toString() ?? '';
                        String dbMin = jsonValue['db_min']?.toString() ?? '';
                        String luxMax = jsonValue['lux_max']?.toString() ?? '';
                        String luxMin = jsonValue['lux_min']?.toString() ?? '';
                        String ppmMax = jsonValue['ppm_max']?.toString() ?? '';
                        String ppmMin = jsonValue['ppm_min']?.toString() ?? '';

                        // ----------------------------------------------------- temperature
                        if (selectedIcon == Icons.thermostat) {
                          _maxController.text = tMax.toString();
                          _minController.text = tMin.toString();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 100,
                                child: Text(
                                  'Temperatura',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 100),
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Máximo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _maxController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el primer text field
                                    // Actualiza el valor en Firebase
                                    int? max = int.tryParse(value);
                                    if (max != null) {
                                      ref
                                          .child('config')
                                          .update({'t_max': max});
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 30),
                              // Segundo text field
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mínimo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _minController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el segundo text field
                                    // Actualiza el valor en Firebase
                                    int? min = int.tryParse(value);
                                    if (min != null) {
                                      ref
                                          .child('config')
                                          .update({'t_min': min});
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        } // ----------------------------------------------------- humidity
                        else if (selectedIcon == Icons.water_drop_rounded) {
                          _maxController.text = hMax.toString();
                          _minController.text = hMin.toString();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 100,
                                child: Text(
                                  'Humedad',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(height: 100),
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Máximo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _maxController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el primer text field
                                    // Actualiza el valor en Firebase
                                    int? max = int.tryParse(value);
                                    if (max != null) {
                                      ref
                                          .child('config')
                                          .update({'h_max': max});
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 30),
                              // Segundo text field
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mínimo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _minController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el segundo text field
                                    // Actualiza el valor en Firebase
                                    int? min = int.tryParse(value);
                                    if (min != null) {
                                      ref
                                          .child('config')
                                          .update({'h_min': min});
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        // ----------------------------------------------------- uv index
                        else if (selectedIcon == Icons.sunny) {
                          _maxController.text = uvMax.toString();
                          _minController.text = uvMin.toString();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 100,
                                child: Text(
                                  'Radiación UV',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: 100),
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Máximo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _maxController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el primer text field
                                    // Actualiza el valor en Firebase
                                    int? max = int.tryParse(value);
                                    if (max != null) {
                                      ref
                                          .child('config')
                                          .update({'uv_max': max});
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 30),
                              // Segundo text field
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mínimo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _minController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el segundo text field
                                    // Actualiza el valor en Firebase
                                    int? min = int.tryParse(value);
                                    if (min != null) {
                                      ref
                                          .child('config')
                                          .update({'uv_min': min});
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        // ----------------------------------------------------- dB
                        else if (selectedIcon == Icons.campaign_rounded) {
                          _maxController.text = dbMax.toString();
                          _minController.text = dbMin.toString();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 100,
                                child: Text(
                                  'Ruido (dB)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: 100),
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Máximo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _maxController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el primer text field
                                    // Actualiza el valor en Firebase
                                    int? max = int.tryParse(value);
                                    if (max != null) {
                                      ref
                                          .child('config')
                                          .update({'db_max': max});
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 30),
                              // Segundo text field
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mínimo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _minController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el segundo text field
                                    // Actualiza el valor en Firebase
                                    int? min = int.tryParse(value);
                                    if (min != null) {
                                      ref
                                          .child('config')
                                          .update({'db_min': min});
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }

                        // ----------------------------------------------------- lux
                        else if (selectedIcon == Icons.light_rounded) {
                          _maxController.text = luxMax.toString();
                          _minController.text = luxMin.toString();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 100,
                                child: Text(
                                  'Lux',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: 100),
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Máximo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _maxController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el primer text field
                                    // Actualiza el valor en Firebase
                                    int? max = int.tryParse(value);
                                    if (max != null) {
                                      ref
                                          .child('config')
                                          .update({'lux_max': max});
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 30),
                              // Segundo text field
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mínimo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _minController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el segundo text field
                                    // Actualiza el valor en Firebase
                                    int? min = int.tryParse(value);
                                    if (min != null) {
                                      ref
                                          .child('config')
                                          .update({'lux_min': min});
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        // ----------------------------------------------------- lppm
                        else if (selectedIcon == Icons.local_florist_rounded) {
                          _maxController.text = ppmMax.toString();
                          _minController.text = ppmMin.toString();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 100,
                                child: Text(
                                  'AireQ PPM',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: 100),
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Máximo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _maxController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el primer text field
                                    // Actualiza el valor en Firebase
                                    int? max = int.tryParse(value);
                                    if (max != null) {
                                      ref
                                          .child('config')
                                          .update({'ppm_max': max});
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 30),
                              // Segundo text field
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Mínimo',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _minController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el segundo text field
                                    // Actualiza el valor en Firebase
                                    int? min = int.tryParse(value);
                                    if (min != null) {
                                      ref
                                          .child('config')
                                          .update({'ppm_min': min});
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Max',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _maxController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el primer text field
                                    // Actualiza el valor en Firebase
                                    int? max = int.tryParse(value);
                                    if (max != null) {
                                      ref
                                          .child('config')
                                          .update({'t_max': max});
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 30),
                              // Segundo text field
                              SizedBox(
                                height: 50,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Min',
                                    labelStyle: TextStyle(fontSize: 15),
                                  ),
                                  style: TextStyle(fontSize: 20),
                                  controller: _minController,
                                  onChanged: (value) {
                                    // Maneja los cambios en el segundo text field
                                    // Actualiza el valor en Firebase
                                    int? min = int.tryParse(value);
                                    if (min != null) {
                                      ref
                                          .child('config')
                                          .update({'t_min': min});
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                      }
                    }
                    return CircularProgressIndicator();
                  },
                ),
                SizedBox(width: 30),
                // Columna para los color pickers
                StreamBuilder(
                  stream: ref.child('config').onValue,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      DataSnapshot data = snapshot.data!.snapshot;
                      Map<dynamic, dynamic>? jsonValue =
                          data.value as Map<dynamic, dynamic>?;

                      if (jsonValue != null) {
                        // ------------------------------------------------------ temperatureColors
                        if (selectedIcon == Icons.thermostat) {
                          final Color tColmax =
                              Color(jsonValue["t_colMax"] ?? 0xFFFFFFFF);
                          final Color tColmin =
                              Color(jsonValue["t_colMin"] ?? 0xFFFFFFFF);
                          final Color tColdef =
                              Color(jsonValue["t_colDef"] ?? 0xFFFFFFFF);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildColorPickerTile(
                                currentColor: tColmax,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'t_colMax': newColor.value});
                                },
                                title: 'Máximo',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColdef,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'t_colDef': newColor.value});
                                },
                                title: 'Normal',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColmin,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'t_colMin': newColor.value});
                                },
                                title: 'Mínimo',
                              ),
                            ],
                          );
                        }
                        // ------------------------------------------------------ humidityColors
                        else if (selectedIcon == Icons.water_drop_rounded) {
                          final Color tColmax =
                              Color(jsonValue["h_colMax"] ?? 0xFFFFFFFF);
                          final Color tColmin =
                              Color(jsonValue["h_colMin"] ?? 0xFFFFFFFF);
                          final Color tColdef =
                              Color(jsonValue["h_colDef"] ?? 0xFFFFFFFF);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildColorPickerTile(
                                currentColor: tColmax,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'h_colMax': newColor.value});
                                },
                                title: 'Máximo',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColdef,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'h_colDef': newColor.value});
                                },
                                title: 'Normal',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColmin,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'h_colMin': newColor.value});
                                },
                                title: 'Mínimo',
                              ),
                            ],
                          );
                        }
                        // ------------------------------------------------------ UVColors
                        else if (selectedIcon == Icons.sunny) {
                          final Color tColmax =
                              Color(jsonValue["uv_colMax"] ?? 0xFFFFFFFF);
                          final Color tColmin =
                              Color(jsonValue["uv_colMin"] ?? 0xFFFFFFFF);
                          final Color tColdef =
                              Color(jsonValue["uv_colDef"] ?? 0xFFFFFFFF);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildColorPickerTile(
                                currentColor: tColmax,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'uv_colMax': newColor.value});
                                },
                                title: 'Máximo',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColdef,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'uv_colDef': newColor.value});
                                },
                                title: 'Normal',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColmin,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'uv_colMin': newColor.value});
                                },
                                title: 'Mínimo',
                              ),
                            ],
                          );
                        }
                        // ------------------------------------------------------ DBColors
                        else if (selectedIcon == Icons.campaign_rounded) {
                          final Color tColmax =
                              Color(jsonValue["db_colMax"] ?? 0xFFFFFFFF);
                          final Color tColmin =
                              Color(jsonValue["db_colMin"] ?? 0xFFFFFFFF);
                          final Color tColdef =
                              Color(jsonValue["db_colDef"] ?? 0xFFFFFFFF);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildColorPickerTile(
                                currentColor: tColmax,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'db_colMax': newColor.value});
                                },
                                title: 'Máximo',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColdef,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'db_colDef': newColor.value});
                                },
                                title: 'Normal',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColmin,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'db_colMin': newColor.value});
                                },
                                title: 'Mínimo',
                              ),
                            ],
                          );
                        } // ------------------------------------------------------ luxColors
                        else if (selectedIcon == Icons.light_rounded) {
                          final Color tColmax =
                              Color(jsonValue["lux_colMax"] ?? 0xFFFFFFFF);
                          final Color tColmin =
                              Color(jsonValue["lux_colMin"] ?? 0xFFFFFFFF);
                          final Color tColdef =
                              Color(jsonValue["lux_colDef"] ?? 0xFFFFFFFF);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildColorPickerTile(
                                currentColor: tColmax,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'lux_colMax': newColor.value});
                                },
                                title: 'Máximo',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColdef,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'lux_colDef': newColor.value});
                                },
                                title: 'Normal',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColmin,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'lux_colMin': newColor.value});
                                },
                                title: 'Mínimo',
                              ),
                            ],
                          );
                        }
                        // ------------------------------------------------------ ppmColors
                        else if (selectedIcon == Icons.local_florist_rounded) {
                          final Color tColmax =
                              Color(jsonValue["ppm_colMax"] ?? 0xFFFFFFFF);
                          final Color tColmin =
                              Color(jsonValue["ppm_colMin"] ?? 0xFFFFFFFF);
                          final Color tColdef =
                              Color(jsonValue["ppm_colDef"] ?? 0xFFFFFFFF);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildColorPickerTile(
                                currentColor: tColmax,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'ppm_colMax': newColor.value});
                                },
                                title: 'Máximo',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColdef,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'ppm_colDef': newColor.value});
                                },
                                title: 'Normal',
                              ),
                              _buildColorPickerTile(
                                currentColor: tColmin,
                                onColorChanged: (Color newColor) {
                                  // Actualiza el valor en Firebase
                                  ref
                                      .child('config')
                                      .update({'ppm_colMin': newColor.value});
                                },
                                title: 'Mínimo',
                              ),
                            ],
                          );
                        }
                      }
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
