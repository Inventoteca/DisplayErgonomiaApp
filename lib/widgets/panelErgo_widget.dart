//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

late User _currentUser;
//late var t_max = 0;
//late var t_min = 0;
//Color t_ColMax = Colors.white;
//Color t_ColMin = Colors.white;
//Color t_ColDef = Colors.white;
//late Color _color = Colors.white;
//late var _t = 0;

//final DatabaseReference ref =
//    FirebaseDatabase.instance.ref('/panels/$_panelID/');
//DatabaseReference ref =
//    FirebaseDatabase.instance.ref('/panels/40:91:51:93:45:B8/');
late DatabaseEvent _event;

var _user = {
  "name": "${_currentUser.displayName}",
  "Ts": '${DateTime.now().millisecondsSinceEpoch}',
  "email": "${_currentUser.email}",
};

//late User _currentUser;

class PanelErgo extends StatefulWidget {
  final User user;
  final String name;
  final String id;

  const PanelErgo({
    Key? key,
    required this.user,
    required this.name,
    required this.id,
  }) : super(key: key);

  @override
  State<PanelErgo> createState() => _PanelErgoState();
}

class _PanelErgoState extends State<PanelErgo> {
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
    debugPrint('update');
  }

  //_currentUser = widget.user;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: CustomColors.panel,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              //width: 180,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.name,
                  overflow: TextOverflow.fade,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CustomColors.firebaseOrange,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildRowT(
                icon: Icons.thermostat,
                units: ' ºC',
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildRowH(
                  icon: Icons.water_drop_rounded,
                  units: ' %',
                ),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildRowUV(
                  icon: Icons.sunny,
                  units: ' UV',
                ),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _buildRowDB(
                  icon: Icons.campaign_rounded,
                  //text: 'db',
                  units: ' dB',
                  //color: Colors.white,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildRowLUX(
                icon: Icons.light_rounded,
                //text: 'lux',
                units: ' Lux',
                //color: Colors.white,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildRowPPM(
                icon: Icons.local_florist_rounded,
                //text: 'ppm',
                units: ' PPM',
                //color: Colors.white,
              ),
            ),
            //Row(
            //  children: [Text(widget.id)],
            // icon: Icons.local_florist_rounded,
            // text: 'ppm',
            // units: ' ID',
            // color: Colors.white,
            //),
          ],
        ),
      ),
    );
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, color: Colors.white, size: 50),
        StreamBuilder(
            stream: ref.child('actual').onValue,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                DataSnapshot data = snapshot.data.snapshot;

                //debugPrint('${data.value}');

                //setState(() {

                final dynamic jsonValue = data.value;
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

                ///_t = t;

                //debugPrint('final $_color');
                //});

                return Text(
                  '$t',
                  style: TextStyle(color: color, fontSize: 50),
                  overflow: TextOverflow.fade,
                );
              } else {
                return Text(
                  "Loading...",
                  style: TextStyle(color: CustomColors.panelBackground),
                );
              }
            }),
        Text(
          units!,
          overflow: TextOverflow.clip,
          maxLines: 2,
          style: TextStyle(
            color: Colors.orange,
            fontSize: 50,
          ),
        ),
      ],
    );
  }

  // ------------------------------------- H Row
  Widget _buildRowH({
    IconData? icon,
    //String? text,
    String? units,
    //Color? color
  }) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, color: Colors.white, size: 50),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: StreamBuilder(
                stream: ref.child('actual').onValue,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    DataSnapshot data = snapshot.data.snapshot;

                    //debugPrint('${data.value}');

                    //setState(() {

                    final dynamic jsonValue = data.value;
                    final int h = jsonValue["h"] as int;
                    final int hMax = jsonValue["h_max"] as int;
                    final int hMin = jsonValue["h_min"] as int;
                    final Color hColmax = Color(jsonValue["h_colMax"]);
                    final Color hColmin = Color(jsonValue["h_colMin"]);
                    final Color hColdef = Color(jsonValue["h_colDef"]);
                    final Color color;

                    if (h >= hMax)
                      color = hColmax;
                    else if (h <= hMin)
                      color = hColmin;
                    else
                      color = hColdef;

                    ///_t = t;

                    //debugPrint('final $_color');
                    //});

                    return Text(
                      '$h',
                      style: TextStyle(color: color, fontSize: 50),
                      overflow: TextOverflow.fade,
                    );
                  } else {
                    return Text(
                      "Loading...",
                      style: TextStyle(color: CustomColors.panelBackground),
                    );
                  }
                }),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              units!,
              overflow: TextOverflow.clip,
              maxLines: 2,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------- UV Row
  Widget _buildRowUV({
    IconData? icon,
    //String? text,
    String? units,
    //Color? color
  }) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, color: Colors.white, size: 50),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: StreamBuilder(
                stream: ref.child('actual').onValue,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    DataSnapshot data = snapshot.data.snapshot;

                    //debugPrint('${data.value}');

                    //setState(() {

                    final dynamic jsonValue = data.value;
                    final uv = jsonValue["uv"];
                    final int uvMax = (jsonValue["uv_max"] as int);
                    final int uvMin = jsonValue["uv_min"] as int;
                    final Color uvColmax = Color(jsonValue["uv_colMax"]);
                    final Color uvColmin = Color(jsonValue["uv_colMin"]);
                    final Color uvColdef = Color(jsonValue["uv_colDef"]);
                    final Color color;

                    if (uv >= uvMax)
                      color = uvColmax;
                    else if (uv <= uvMin)
                      color = uvColmin;
                    else
                      color = uvColdef;

                    ///_t = t;

                    //debugPrint('final $_color');
                    //});

                    return Text(
                      '$uv',
                      style: TextStyle(color: color, fontSize: 50),
                      overflow: TextOverflow.fade,
                    );
                  } else {
                    return Text(
                      "Loading...",
                      style: TextStyle(color: CustomColors.panelBackground),
                    );
                  }
                }),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              units!,
              overflow: TextOverflow.clip,
              maxLines: 2,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------- DB Row
  Widget _buildRowDB({
    IconData? icon,
    //String? text,
    String? units,
    //Color? color
  }) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, color: Colors.white, size: 50),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: StreamBuilder(
                stream: ref.child('actual').onValue,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    DataSnapshot data = snapshot.data.snapshot;

                    //debugPrint('${data.value}');

                    //setState(() {

                    final dynamic jsonValue = data.value;
                    final int db = jsonValue["db"] as int;
                    final int dbMax = jsonValue["db_max"] as int;
                    final int dbMin = jsonValue["db_min"] as int;
                    final Color dbColmax = Color(jsonValue["db_colMax"]);
                    final Color dbColmin = Color(jsonValue["db_colMin"]);
                    final Color dbColdef = Color(jsonValue["db_colDef"]);
                    final Color color;

                    if (db >= dbMax)
                      color = dbColmax;
                    else if (db <= dbMin)
                      color = dbColmin;
                    else
                      color = dbColdef;

                    ///_t = t;

                    //debugPrint('final $_color');
                    //});

                    return Text(
                      '$db',
                      style: TextStyle(color: color, fontSize: 50),
                      overflow: TextOverflow.fade,
                    );
                  } else {
                    return Text(
                      "Loading...",
                      style: TextStyle(color: CustomColors.panelBackground),
                    );
                  }
                }),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              units!,
              overflow: TextOverflow.clip,
              maxLines: 2,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------- LUX Row
  Widget _buildRowLUX({
    IconData? icon,
    //String? text,
    String? units,
    //Color? color
  }) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Icon(icon, color: Colors.white, size: 50),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: StreamBuilder(
              stream: ref.child('actual').onValue,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  DataSnapshot data = snapshot.data.snapshot;

                  //debugPrint('${data.value}');

                  //setState(() {

                  final dynamic jsonValue = data.value;
                  final int lux = jsonValue["lux"] as int;
                  final int luxMax = jsonValue["lux_max"] as int;
                  final int luxMin = jsonValue["lux_min"] as int;
                  final Color luxColmax = Color(jsonValue["lux_colMax"]);
                  final Color luxColmin = Color(jsonValue["lux_colMin"]);
                  final Color luxColdef = Color(jsonValue["lux_colDef"]);
                  final Color color;

                  if (lux >= luxMax)
                    color = luxColmax;
                  else if (lux <= luxMin)
                    color = luxColmin;
                  else
                    color = luxColdef;

                  ///_t = t;

                  //debugPrint('final $_color');
                  //});

                  return Text(
                    '$lux',
                    style: TextStyle(color: color, fontSize: 50),
                    overflow: TextOverflow.fade,
                  );
                } else {
                  return Text(
                    "Loading...",
                    style: TextStyle(color: CustomColors.panelBackground),
                  );
                }
              }),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            units!,
            overflow: TextOverflow.clip,
            maxLines: 2,
            style: TextStyle(
              color: Colors.orange,
              fontSize: 50,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------- PPM Row
  Widget _buildRowPPM({
    IconData? icon,
    //String? text,
    String? units,
    //Color? color
  }) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, color: Colors.white, size: 50),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: StreamBuilder(
                stream: ref.child('actual').onValue,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    DataSnapshot data = snapshot.data.snapshot;

                    //debugPrint('${data.value}');

                    //setState(() {

                    final dynamic jsonValue = data.value;
                    final int ppm = jsonValue["ppm"] as int;
                    final int ppmMax = jsonValue["ppm_max"] as int;
                    final int ppmMin = jsonValue["ppm_min"] as int;
                    final Color ppmColmax = Color(jsonValue["ppm_colMax"]);
                    final Color ppmColmin = Color(jsonValue["ppm_colMin"]);
                    final Color ppmColdef = Color(jsonValue["ppm_colDef"]);
                    final Color color;

                    if (ppm >= ppmMax)
                      color = ppmColmax;
                    else if (ppm <= ppmMin)
                      color = ppmColmin;
                    else
                      color = ppmColdef;

                    ///_t = t;

                    //debugPrint('final $_color');
                    //});

                    return Text(
                      '$ppm',
                      style: TextStyle(color: color, fontSize: 50),
                      overflow: TextOverflow.fade,
                    );
                  } else {
                    return Text(
                      "Loading...",
                      style: TextStyle(color: CustomColors.panelBackground),
                    );
                  }
                }),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              units!,
              overflow: TextOverflow.clip,
              maxLines: 2,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
      {IconData? icon, String? text, String? units, Color? color}) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');
    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.contain,
      child: Padding(
        padding: const EdgeInsets.only(left: 2, right: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Icon(icon, color: Colors.white, size: 50),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: StreamBuilder(
                  stream: ref.child('actual/$text').onValue,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      DataSnapshot data = snapshot.data.snapshot;

                      //  debugPrint('${data.value}');

                      // if (text == 't')
                      //{
                      //final t = data.value as int;
                      //final color = (t >= t_max) ? Colors.red : Colors.white;
                      //}

                      return Text(
                        '${data.value}',
                        style: TextStyle(color: color, fontSize: 50),
                        overflow: TextOverflow.fade,
                      );
                    } else {
                      return Text(
                        "Loading...",
                        style: TextStyle(color: CustomColors.panelBackground),
                      );
                    }
                  }),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                units!,
                overflow: TextOverflow.clip,
                maxLines: 2,
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
