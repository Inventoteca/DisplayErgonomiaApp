import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'res/custom_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Industry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: CustomColors.panelBackground,
        brightness: Brightness.light,
        //primarySwatch: Color(0xFF2196F3),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              fontSize: 18.0,
            ),
            padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          ),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 18.0,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
          bodyText1: TextStyle(fontSize: 18.0),
        ),
      ),
      home: LoginPage(),
    );
  }
}
