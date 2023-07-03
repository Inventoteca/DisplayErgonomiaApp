import 'package:flutter/material.dart';
import '/res/custom_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

//late User _currentUser;

class panelCruz extends StatelessWidget {
  final User user;
  final String name;

  const panelCruz({
    Key? key,
    required this.user,
    required this.name,
  }) : super(key: key);

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
            Container(
              width: 180,
              child: Text(
                name,
                overflow: TextOverflow.fade,
                maxLines: 2,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: CustomColors.firebaseOrange, fontSize: 20),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
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
            ),
          ],
        ),
      ),
    );
  }
}
