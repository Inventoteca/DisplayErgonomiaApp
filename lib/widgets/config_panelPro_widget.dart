import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/device_list_page.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

late User _currentUser;

class ConfigPanelPro extends StatefulWidget {
  final User user;
  final String name;
  final String id;

  const ConfigPanelPro({
    Key? key,
    required this.user,
    required this.name,
    required this.id,
  }) : super(key: key);

  @override
  State<ConfigPanelPro> createState() => _ConfigPanelProState();
}

class _ConfigPanelProState extends State<ConfigPanelPro> {
  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    final panelID = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: CustomColors.panelBack,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 180,
              child: Text(
                'Configuracion: ${widget.name}',
                overflow: TextOverflow.fade,
                maxLines: 4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  //color: CustomColors.firebaseOrange,
                  fontSize: 20,
                ),
              ),
            ),
            _buildRow(
              icon: Icons.calendar_month,
              text: '25',
              units: ' Días',
              color: Colors.white,
            ),
            _buildRow(
              icon: Icons.pie_chart,
              text: '70',
              units: ' % ',
              color: Colors.red,
            ),
            _buildRow(
              icon: Icons.perm_identity,
              text: '101',
              units: ' Users',
              color: Colors.white,
            ),
            _buildRow(
              icon: Icons.devices,
              text: '995',
              units: ' Piezas',
              color: Colors.white,
            ),
            _buildRow(
              icon: Icons.filter_alt,
              text: '0',
              units: ' Fallos',
              color: Colors.white,
            ),
            _buildRow(
              icon: Icons.query_builder,
              text: '1',
              units: ' Turno',
              color: Colors.white,
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
                          child: Text('Eliminar'),
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
                        TextButton(
                          child: Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(context).pop();
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
      ),
    );
  }

  Widget _buildRow(
      {IconData? icon, String? text, String? units, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 1, right: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            text!,
            style: TextStyle(color: color),
          ),
          Text(
            units!,
            overflow: TextOverflow.fade,
            maxLines: 4,
            style: TextStyle(
              color: Colors.orange,
              //fontSize: 9,
            ),
          ),
        ],
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
}
