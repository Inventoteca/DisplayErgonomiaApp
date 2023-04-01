//import 'dart:ui';

import 'package:flutter/material.dart';
//import '/screens/NavBar.dart';

class AboutUs extends StatelessWidget {
  const AboutUs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 54, 222, 244),
        title: Center(
          child: const Text('Contacto'),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 250,
            decoration: BoxDecoration(
                /* gradient: LinearGradient(
                  colors: [Colors.blue, Colors.deepPurple.shade300],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.5, 0.9]),*/
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade300,
                      minRadius: 35.0,
                      child: Icon(
                        Icons.call,
                        size: 30,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white70,
                      minRadius: 60.0,
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage:
                            AssetImage('lib/images/SmartIndustry.png'),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade300,
                      minRadius: 35.0,
                      child: Icon(
                        Icons.message,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Alejandro Cortés',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'alejandro.cortes@smartindustry.tech',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'Teléfono',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '+52 222 305 4814',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
