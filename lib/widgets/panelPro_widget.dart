import 'package:flutter/material.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

//late User _currentUser;

class PanelPro extends StatelessWidget {
  final User user;
  final String name;

  const PanelPro({
    Key? key,
    required this.user,
    required this.name,
  }) : super(key: key);

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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 180,
              child: FittedBox(
                fit: BoxFit.cover,
                child: Text(
                  name,
                  overflow: TextOverflow.fade,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CustomColors.firebaseOrange,
                    //fontSize: 20,
                  ),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              text!,
              style: TextStyle(color: color),
              overflow: TextOverflow.fade,
            ),
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: Text(
              units!,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
