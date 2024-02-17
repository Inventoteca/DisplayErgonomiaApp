Widget _buildRowT({
  IconData? icon,
  String? units,
}) {
  final panelID = widget.id;
  final DatabaseReference ref =
      FirebaseDatabase.instance.ref('/panels/$panelID/');

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      GestureDetector(
        onTap: () {
          // Acciones cuando se toca el icono
        },
        child: Icon(icon, color: iconColors[icon], size: 70),
      ),
      StreamBuilder(
        stream: ref.child('actual').onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            DataSnapshot data = snapshot.data.snapshot;
            jsonValue = data.value;
            // Asegúrate de que tienes valores no nulos aquí
            final Color tColmax = Color(jsonValue["t_colMax"] ?? 0xFFFFFFFF);
            final Color tColmin = Color(jsonValue["t_colMin"] ?? 0xFFFFFFFF);
            final Color tColdef = Color(jsonValue["t_colDef"] ?? 0xFFFFFFFF);

            return Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildColorPickerTile(
                      color: tColmin,
                      onColorChanged: (Color newColor) {
                        setState(() {
                          jsonValue["t_colMin"] = newColor.value;
                          ref.child('actual').update({'t_colMin': newColor.value});
                        });
                      },
                      title: 'Color Mínimo',
                    ),
                  ),
                  Expanded(
                    child: _buildColorPickerTile(
                      color: tColdef,
                      onColorChanged: (Color newColor) {
                        setState(() {
                          jsonValue["t_colDef"] = newColor.value;
                          ref.child('actual').update({'t_colDef': newColor.value});
                        });
                      },
                      title: 'Color Defecto',
                    ),
                  ),
                  Expanded(
                    child: _buildColorPickerTile(
                      color: tColmax,
                      onColorChanged: (Color newColor) {
                        setState(() {
                          jsonValue["t_colMax"] = newColor.value;
                          ref.child('actual').update({'t_colMax': newColor.value});
                        });
                      },
                      title: 'Color Máximo',
                    ),
                  ),
                ],
              ),
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
      )
    ],
  );
}
