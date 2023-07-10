import 'package:flutter/material.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

late User _currentUser;

var _user = {
  "name": "${_currentUser.displayName}",
  "Ts": '${DateTime.now().millisecondsSinceEpoch}',
  "email": "${_currentUser.email}",
};

var _userTime = {
  "time": ((DateTime.now().millisecondsSinceEpoch) ~/ 1000),
  "Ts": '${DateTime.now().millisecondsSinceEpoch}',
  "defColor": 4294967295,
  "days_ac": 1234,
  //"email": "${_currentUser.email}",
};

// ignore: camel_case_types
class panelCruz extends StatefulWidget {
  final User user;
  final String name;
  final String id;

  const panelCruz({
    Key? key,
    required this.user,
    required this.name,
    required this.id,
  }) : super(key: key);

  @override
  State<panelCruz> createState() => _panelCruzState();
}

// ignore: camel_case_types
class _panelCruzState extends State<panelCruz> {
  late Map<String, dynamic> _actualData;
  late DatabaseReference _actualRef;
  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    final panelID = widget.id;

    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');
    ref.child('actual/z_user').update(_user);

    debugPrint(panelID);
    debugPrint('update cruz');
  }

  @override
  void dispose() {
    //_actualRef.onValue.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(10),
      elevation: 10,
      color: CustomColors.panel,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.name,
                overflow: TextOverflow.fade,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CustomColors.firebaseOrange,
                  fontSize: 35,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildRowDays(
                  //icon: Icons.thermostat,
                  //units: ' Días sin accidentes',
                  ),
            ),
            Text(
              "Días sin accidentes",
              overflow: TextOverflow.clip,
              maxLines: 1,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildRowTime(
                  //icon: Icons.thermostat,
                  //units: ' Fecha',
                  ),
            ),
            Text(
              "Ultima actualización",
              overflow: TextOverflow.clip,
              maxLines: 1,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),

            /* Expanded(
              child: GridView.count(
                crossAxisCount: 7,
                children: List.generate(49, (index) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        '$index',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  );
                }),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  // ------------------------------------- Time
  Widget _buildRowTime(
      //{
      //IconData? icon,
      //String? text,
      //String? units,
      //Color? color
      //}
      ) {
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
              //child: Icon(icon, color: Colors.white, size: 50),
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
                    final int timeNow = jsonValue["time"] as int;
                    final int gmtOff = jsonValue["gmtOff"];
                    //final int hMax = jsonValue["h_max"] as int;
                    //final int hMin = jsonValue["h_min"] as int;
                    //final Color hColmax = Color(jsonValue["h_colMax"]);
                    //final Color hColmin = Color(jsonValue["h_colMin"]);
                    final Color defColor = Color(jsonValue["defColor"]);
                    final Color color;

                    //if (h >= hMax)
                    //  color = hColmax;
                    //else if (h <= hMin)
                    //  color = hColmin;
                    //else
                    color = defColor;

                    final DateTime dateTime =
                        DateTime.fromMillisecondsSinceEpoch(
                            (timeNow - gmtOff) * 1000);

                    // Utiliza el formato deseado sin los milisegundos
                    final DateFormat dateFormatter =
                        DateFormat('yyyy-MM-dd HH:mm:ss');
                    final String formattedDate = dateFormatter.format(dateTime);
                    print(formattedDate);

                    ///_t = t;

                    debugPrint('final $timeNow');
                    debugPrint('final $gmtOff');
                    // final DateTime dateTime =
                    //     DateTime.fromMillisecondsSinceEpoch(
                    //         (timeNow - gmtOff) * 1000);
                    //final String formattedDate = dateTime.toString();
                    //print(formattedDate);

                    //});

                    return Text(
                      '$formattedDate',
                      style: TextStyle(color: color, fontSize: 25),
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
        ],
      ),
    );
  }

  // ------------------------------------- Days
  Widget _buildRowDays(
      //{
      //IconData? icon,
      //String? text,
      //String? units,
      //Color? color
      //}
      ) {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    if (panelID == 'DEMOCRUZ') {
      //final DatabaseReference refConfig =
      //    FirebaseDatabase.instance.ref('/panels/$panelID/');
      ref.child('actual/').update(_userTime);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //Icon(icon, color: Colors.white, size: 50),
        StreamBuilder(
            stream: ref.child('actual').onValue,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                DataSnapshot data = snapshot.data.snapshot;

                //debugPrint('${data.value}');

                //setState(() {

                final dynamic jsonValue = data.value;
                //final int timeNow = (jsonValue["time"] as num).toInt();
                final int daysAc = jsonValue["days_ac"] as int;
                final Color color = Color(jsonValue["defColor"]);
                //final Color color;

                //color = Colors.white;
                //color = defColor;

                ///_t = t;

                debugPrint('final $color');
                //debugPrint('final $timeNow');
                //});

                return Text(
                  '$daysAc',
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
      ],
    );
  }
}
