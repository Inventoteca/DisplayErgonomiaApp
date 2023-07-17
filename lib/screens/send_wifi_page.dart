// ignore_for_file: prefer_const_constructors, unused_element

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/material.dart';
import 'device_list_page.dart';

late List<dynamic> panelDataList = List.empty(growable: true);
late ProvisioningRequest _request;
late Provisioner provisioner = Provisioner.espTouchV2();
StreamSubscription? _subscription;
late String _panelID;
late String _name;
late String _type;

class AddingDevice extends StatefulWidget {
  final User user;
  final String id;
  final String name;
  final String type;
  final ProvisioningRequest request;

  const AddingDevice({
    required this.user,
    required this.type,
    required this.id,
    required this.name,
    required this.request,
  });

  @override
  State<AddingDevice> createState() => _AddingDeviceState();
}

class _AddingDeviceState extends State<AddingDevice> {
  late User _currentUser;
  final info = NetworkInfo();
  bool _isLoading = true;
  late String _msg = '';

  void initState() {
    _isLoading = false;
    _currentUser = widget.user;
    _panelID = widget.id;
    _name = widget.name;
    _type = widget.type;
    _request = widget.request;
    _sendConfig();
    super.initState();
  }

  @override
  void dispose() {
    provisioner.stop();
    super.dispose();
  }

  void _sendConfig() async {
    setState(() {
      _isLoading = true;
    });

    if (_subscription != null) {
      _subscription!.cancel();
    }

    try {
      _subscription = provisioner.listen((response) {
        debugPrint("Device ${response.bssidText} connected to WiFi!");
        setState(() {
          _isLoading = false;
          _msg = "Dispositivo encontrado";
          // Tu código aquí
        });
        provisioner.stop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DeviceList(
              user: _currentUser,
            ),
          ),
        );
      });

      await provisioner.start(_request);
      await Future.delayed(Duration(seconds: 60));
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        if (_isLoading) {
          _msg =
              "Error, vuelve a Intentarlo, revisa la contraseña y el nombre de la red";
          _isLoading = false;
        }
        provisioner.stop();
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DeviceList(
            user: _currentUser,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscando"),
      ),
      body: Center(
        child: _isLoading
            ? Container(
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(height: 10),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(_msg),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
