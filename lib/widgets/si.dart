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
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildIconColumn(), // Columna izquierda con íconos
              _buildColorPickerColumn(), // Columna derecha con color pickers
            ],
          ),
          // ... Resto de tus widgets (Botón de actualizar y texto de id panel)
        ],
      ),
    ),
  );
}

Widget _buildIconColumn() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _iconset(icon: Icons.thermostat, units: ' ºC'),
      // ... otros íconos
    ],
  );
}

Widget _buildColorPickerColumn() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _setColorPicker('Min', 't_colMin'),
      _setColorPicker('Def', 't_colDef'),
      _setColorPicker('Max', 't_colMax'),
    ],
  );
}

Widget _setColorPicker(String title, String jsonKey) {
  final panelID = widget.id;
  final DatabaseReference ref =
      FirebaseDatabase.instance.ref('/panels/$panelID/config/$jsonKey');

  return StreamBuilder(
    stream: ref.onValue,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.hasData && snapshot.data != null) {
        DataSnapshot data = snapshot.data.snapshot;
        Color color = Color(data.value ?? 0xFFFFFFFF);

        return _buildColorPickerTile(
          color: color,
          onColorChanged: (Color newColor) {
            setState(() {
              ref.update({jsonKey: newColor.value});
            });
          },
          title: title,
        );
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}
