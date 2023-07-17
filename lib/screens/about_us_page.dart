import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../res/custom_colors.dart';

final Uri _mail = Uri.parse('mailto:alejandro.cortes@smartindustry.tech');
final String phoneNumber =
    '522223054814'; // Número de teléfono en formato internacional
final String _whats = 'whatsapp://send?phone=$phoneNumber';

class AboutUs extends StatelessWidget {
  const AboutUs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text('Contacto'),
        ),
      ),
      body: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(20),
        elevation: 10,
        color: CustomColors.panel,
        child: ListView(
          children: <Widget>[
            Container(
              height: 250,
              decoration: BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white70,
                        minRadius: 60.0,
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage:
                              AssetImage('lib/images/SmartIndustry.png'),
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
                  InkWell(
                    onTap: () {
                      launchUrl(_mail);
                    },
                    child: ListTile(
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
                  ),
                  Divider(),
                  InkWell(
                    onTap: () async {
                      if (await canLaunchUrlString(_whats)) {
                        await launchUrlString(_whats);
                      } else {
                        throw 'No se pudo abrir WhatsApp';
                      }
                    },
                    child: ListTile(
                      title: Text(
                        'WhatsApp',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '+52 2223054814',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
