import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PanelData {
  late User _currentUser;
  late List<int> _ignoredIndices;
  late String _formattedDate;
  late int _diaHoy;
  late int _daysAc;

  void setCurrentUser(User user) {
    _currentUser = user;
  }

  void setIgnoredIndices(List<int> indices) {
    _ignoredIndices = indices;
  }

  void setFormattedDate(String date) {
    _formattedDate = date;
  }

  void setDiaHoy(int dia) {
    _diaHoy = dia;
  }

  void setDaysAc(int days) {
    _daysAc = days;
  }

  Color getDayColor(int dayNumber) {
    // Lógica para obtener el color del día desde Firebase o cualquier otra fuente de datos
    return Colors.green;
  }

  // Resto de métodos y propiedades de la clase PanelData
}
