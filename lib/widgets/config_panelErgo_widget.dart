import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/device_list_page.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '/utils/validator.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

late User _currentUser;
late var _t_max;
late var _t_min;
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
      Icons.local_florist_rounded: Colors.grey
    };

    _currentUser = widget.user;
    final panelID = widget.id;

    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');
    ref.child('actual/z_user').update(_user);
    debugPrint(panelID);

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
                  child: Text(
                    'Actualizar',
                    style: TextStyle(color: Colors.white),
                  ),
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
                ), */  //Botón de borrar
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
    required Color color, 
    required ValueChanged<Color> onColorChanged, 
    required String title,
  }) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Seleccionar color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: color,
                onColorChanged: onColorChanged,
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
              ),
            ),
            actions: [
              TextButton(
                child: Text('Guardar'),
                onPressed: () {
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
              color: color,
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

    
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
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
        child: Icon(icon, color: iconColors[icon], size: 70), // Usar el color actualizado
      ),
    ]
  );
  }



    // ------------------------------------- T Row
    Widget _setdata({
    String? units,
  }) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Alinea los elementos a la izquierda
      crossAxisAlignment: CrossAxisAlignment.center, // Centra verticalmente los elementos
      children: [
        // Columna para los iconos
        Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinea los iconos a la izquierda
          children: [
            _iconset(icon: Icons.thermostat, units: ' ºC'),
            _iconset(icon: Icons.water_drop_rounded, units: ' ºC'),
            _iconset(icon: Icons.sunny, units: ' ºC'),
            _iconset(icon: Icons.campaign_rounded, units: ' ºC'),
            _iconset(icon: Icons.light_rounded, units: ' ºC'),
            _iconset(icon: Icons.local_florist_rounded, units: ' ºC'),
          ],
        ),
        SizedBox(width: 20), // Espacio entre los iconos y los color pickers
        // Columna para los color pickers

        StreamBuilder(
          stream: ref.child('config').onValue,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              DataSnapshot data = snapshot.data.snapshot;
              jsonValue = data.value;
              // Asegúrate de que tienes valores no nulos aquí
              final Color tColmax = Color(jsonValue["t_colMax"] ?? 0xFFFFFFFF);
              final Color tColmin = Color(jsonValue["t_colMin"] ?? 0xFFFFFFFF);
              final Color tColdef = Color(jsonValue["t_colDef"] ?? 0xFFFFFFFF);
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea los color pickers a la izquierda
                
                children: [

                  _buildColorPickerTile(
                    color: tColmin,
                    onColorChanged: (Color newColor) {
                      setState(() {
                        jsonValue["t_colMin"] = newColor.value;
                        ref.child('config').update({'t_colMin': newColor.value});
                      });
                    },
                    title: 'Min',
                  ),
                  SizedBox(width: 20), // Espacio entre los iconos y los color pickers
                  _buildColorPickerTile(
                    color: tColdef,
                    onColorChanged: (Color newColor) {
                      setState(() {
                        jsonValue["t_colDef"] = newColor.value;
                        ref.child('config').update({'t_colDef': newColor.value});
                      });
                    },
                    title: 'Def',
                  ),
                  SizedBox(width: 20), // Espacio entre los iconos y los color pickers
                  _buildColorPickerTile(
                    color: tColmax,
                    onColorChanged: (Color newColor) {
                      setState(() {
                        jsonValue["t_colMax"] = newColor.value;
                        ref.child('config').update({'t_colMax': newColor.value});
                      });
                    },
                    title: 'Max',
                  ),
                ],
              );
            } else {
              return Expanded(
                child: Center(
                  child: Text(
                    "Loading...",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}