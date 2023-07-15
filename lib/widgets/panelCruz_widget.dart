import 'package:flutter/material.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

late User _currentUser;
late dynamic _eventos;
late int diaHoy = 31;

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
};

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

class _panelCruzState extends State<panelCruz> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(10),
      elevation: 10,
      color: CustomColors.panel,
      child: SizedBox(
        width: 350,
        height: 700,
        child: Column(
          children: [
            SizedBox(height: 10),
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
            SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildRowDays(),
            ),
            Text(
              "Días sin accidentes",
              overflow: TextOverflow.clip,
              maxLines: 1,
              style: TextStyle(
                color: CustomColors.firebaseOrange,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 15),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildRowMY(),
            ),
            SizedBox(height: 15),
            _buildDayNumberGrid(diaHoy, ignoredIndices, Colors.green),
            SizedBox(height: 15),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildRowTime(),
            ),
            Text(
              " ",
              style: TextStyle(
                color: CustomColors.firebaseOrange,
                fontSize: 12,
              ),
            ),
            SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------- Mes Anio
  Widget _buildRowMY() {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: StreamBuilder(
                  stream: ref.child('actual').onValue,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      DataSnapshot data = snapshot.data.snapshot;
                      final dynamic jsonValue = data.value;
                      final int timeNow = jsonValue["time"] as int;
                      final int gmtOff = jsonValue["gmtOff"];
                      final DateTime dateTime =
                          DateTime.fromMillisecondsSinceEpoch(
                              (timeNow - gmtOff) * 1000);
                      final int defColor = jsonValue["defColor"];
                      final Color color = Color.fromARGB(
                        0xFF,
                        (defColor >> 16) & 0xFF,
                        (defColor >> 8) & 0xFF,
                        defColor & 0xFF,
                      );
                      final DateFormat dateM = DateFormat('MM');
                      final String formattedM = dateM.format(dateTime);

                      return Text(
                        '$formattedM',
                        style: TextStyle(color: color, fontSize: 35),
                        overflow: TextOverflow.ellipsis,
                      );
                    } else {
                      return Text(
                        "Loading...",
                        style: TextStyle(color: Colors.transparent),
                      );
                    }
                  },
                ),
              ),
              //SizedBox(height: 10),
              Text(
                'Mes',
                style:
                    TextStyle(fontSize: 18, color: CustomColors.firebaseOrange),
              ),
            ],
          ),
          SizedBox(width: 40),
          Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: StreamBuilder(
                  stream: ref.child('actual').onValue,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      DataSnapshot data = snapshot.data.snapshot;
                      final dynamic jsonValue = data.value;
                      final int timeNow = jsonValue["time"] as int;
                      final int gmtOff = jsonValue["gmtOff"];
                      final DateTime dateTime =
                          DateTime.fromMillisecondsSinceEpoch(
                              (timeNow - gmtOff) * 1000);
                      final int defColor = jsonValue["defColor"];
                      final Color color = Color.fromARGB(
                        0xFF,
                        (defColor >> 16) & 0xFF,
                        (defColor >> 8) & 0xFF,
                        defColor & 0xFF,
                      );
                      final DateFormat dateY = DateFormat('yy');
                      final String formattedY = dateY.format(dateTime);

                      return Text(
                        '$formattedY',
                        style: TextStyle(color: color, fontSize: 35),
                        overflow: TextOverflow.ellipsis,
                      );
                    } else {
                      return Text(
                        "...",
                        style: TextStyle(color: Colors.transparent),
                      );
                    }
                  },
                ),
              ),
              //SizedBox(height: 10),
              Text(
                'Año',
                style:
                    TextStyle(fontSize: 18, color: CustomColors.firebaseOrange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //----------------------------------------------Time
  Widget _buildRowTime() {
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
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: StreamBuilder(
              stream: ref.child('actual').onValue,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  DataSnapshot data = snapshot.data.snapshot;
                  final dynamic jsonValue = data.value;
                  final int timeNow = jsonValue["time"] as int;
                  final int gmtOff = jsonValue["gmtOff"];
                  //final int defColor = jsonValue["defColor"];
                  //final Color color = Color.fromARGB(
                  // 0xFF,
                  // (defColor >> 16) & 0xFF,
                  // (defColor >> 8) & 0xFF,
                  // defColor & 0xFF,
                  //);
                  final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                      (timeNow - gmtOff) * 1000);
                  final DateFormat dateFormatter =
                      DateFormat('dd/MM/yyyy  HH:mm:ss');
                  final String formattedDate = dateFormatter.format(dateTime);

                  diaHoy = dateTime.day;

                  return Text(
                    '$formattedDate',
                    style: TextStyle(
                        color: CustomColors.firebaseOrange, fontSize: 12),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  );
                } else {
                  return Text(
                    "...",
                    style: TextStyle(color: Colors.transparent),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- Days
  Widget _buildRowDays() {
    final panelID = widget.id;
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('/panels/$panelID/');

    if (panelID == 'DEMOCRUZ') {
      ref.child('actual/').update(_userTime);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StreamBuilder(
          stream: ref.child('actual').onValue,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              DataSnapshot data = snapshot.data.snapshot;
              final dynamic jsonValue = data.value;
              final int daysAc = jsonValue["days_ac"] as int;
              final int timeNow = jsonValue["time"] as int;
              final int gmtOff = jsonValue["gmtOff"];
              final int defColor = jsonValue["defColor"];
              final Color color = Color.fromARGB(
                0xFF,
                (defColor >> 16) & 0xFF,
                (defColor >> 8) & 0xFF,
                defColor & 0xFF,
              );

              final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                  (timeNow - gmtOff) * 1000);
              // final DateFormat dateFormatter =
              //    DateFormat('yyyy-MM-dd HH:mm:ss');
              //final String formattedDate = dateFormatter.format(dateTime);

              diaHoy = dateTime.day;

              return Text(
                '$daysAc',
                style: TextStyle(color: color, fontSize: 60),
                overflow: TextOverflow.fade,
              );
            } else {
              return Text(
                "...",
                style: TextStyle(color: Colors.transparent),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildDayNumberGrid(
      int diaHoy, List<int> ignoredIndices, Color dayColor) {
    final panelID = widget.id;
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

                  return Container(
                    padding: EdgeInsets.zero, // Eliminar el padding
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
