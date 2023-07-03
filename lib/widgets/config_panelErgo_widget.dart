import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/device_list_page.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '/utils/validator.dart';

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

  @override
  void initState() {
    super.initState();
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
            SizedBox(
              height: 10,
            ),
            _buildRowT(
              icon: Icons.thermostat,
              units: ' ºC',
            ),
            _buildRowT(
              icon: Icons.water_drop_rounded,
              units: ' ºC',
            ),
            _buildRowT(
              icon: Icons.sunny,
              units: ' ºC',
            ),
            _buildRowT(
              icon: Icons.campaign_rounded,
              units: ' ºC',
            ),
            _buildRowT(
              icon: Icons.light_rounded,
              units: ' ºC',
            ),
            _buildRowT(
              icon: Icons.local_florist_rounded,
              units: ' ºC',
            ),
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
                ElevatedButton(
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
                ),
              ],
            ),
            Text(widget.id),
          ],
        ),
      ),
    );
  }

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

  // ------------------------------------- T Row
  Widget _buildRowT({
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
        Icon(icon, color: Colors.white, size: 70),
        StreamBuilder(
            stream: ref.child('actual').onValue,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                DataSnapshot data = snapshot.data.snapshot;

                jsonValue = data.value;
                final int t = jsonValue["t"] as int;
                final int tMax = jsonValue["t_max"] as int;
                final int tMin = jsonValue["t_min"] as int;
                final Color tColmax = Color(jsonValue["t_colMax"]);
                final Color tColmin = Color(jsonValue["t_colMin"]);
                final Color tColdef = Color(jsonValue["t_colDef"]);
                final Color color;

                if (t >= tMax)
                  color = tColmax;
                else if (t <= tMin)
                  color = tColmin;
                else
                  color = tColdef;

                //RangeValues _currentRangeValues =
                //    RangeValues(t_min.toDouble(), t_max.toDouble());

                return RangeSlider(
                  values: _currentRangeValues,
                  max: 50,
                  divisions: 50,
                  labels: RangeLabels(
                    _currentRangeValues.start.round().toString(),
                    _currentRangeValues.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRangeValues = values;
                      jsonValue["t_max"] = values.end.toInt();
                      jsonValue["t_min"] = values.start.toInt();
                      debugPrint('${jsonValue["t_max"]}');
                    });
                    final DatabaseReference ref =
                        FirebaseDatabase.instance.ref('/panels/$panelID/');
                    ref.child('actual/').update(jsonValue);
                  },
                );
              } else {
                return Text(
                  "Loading...",
                  style: TextStyle(color: CustomColors.panelBackground),
                );
              }
            }),
      ],
    );
  }
}
