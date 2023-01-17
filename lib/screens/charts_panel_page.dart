// ignore_for_file: unused_element

//import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:smart_industry/screens/panelList_page.dart';
//import '/screens/profile_page.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
//import 'package:segment_display/segment_display.dart';
//import 'package:device_info/device_info.dart';
//import '/screens/NavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
//import 'dart:math' as math;

MqttConnectionState? connectionState;
StreamSubscription? subscription;
late User _currentUser;
late SharedPreferences _prefs;
late String _panelID;
late TooltipBehavior _tooltipBehavior;
//late bool _chartReceived = false;
String t = '20';
String h = '40';
String uv = '0.0';
String db = '40';
String lux = '0';
String ppm = '400';

// Renders the realtime line chart sample.
class ChartsPanelPage extends StatefulWidget {
  final User user;
  final SharedPreferences prefs;
  final String id;

  /// Creates the realtime line chart sample.
  const ChartsPanelPage(
      {required this.user, required this.prefs, required this.id})
      : super();

  @override
  ChartsPanelPageState createState() => ChartsPanelPageState();
}

/// State class of the realtime line chart.
///
//class ChartsPanelPageState extends SampleViewState {
//ChartsPanelPageState() {
//timer =
//    Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);
// }

class ChartsPanelPageState extends State<ChartsPanelPage> {
  MqttServerClient? client;
  List<ChartData>? chartData;
  late int count;
  ChartSeriesController? _chartSeriesController;

  @override
  void dispose() {
    chartData!.clear();
    onDisConnected();
    _chartSeriesController = null;
    super.dispose();
  }

  @override
  void initState() {
    _currentUser = widget.user;
    _prefs = widget.prefs;
    _panelID = widget.id;
    _loadConfig();
    debugPrint(_panelID);
    count = 0;
    chartData = <ChartData>[];

    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLiveLineChart();
  }

  /// Returns the realtime Cartesian line chart.
  SfCartesianChart _buildLiveLineChart() {
    return SfCartesianChart(
        legend: Legend(isVisible: true),
        tooltipBehavior: _tooltipBehavior,
        plotAreaBorderWidth: 0,
        primaryXAxis: DateTimeAxis(),
        // NumericAxis(majorGridLines: const MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(
            //visibleMaximum: 100,
            //anchorRangeToVisiblePoints: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0)),
        series: <ChartSeries<ChartData, DateTime>>[
          //----------------------------------- temperature
          LineSeries<ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            enableTooltip: true,
            name: 'Temperatura [°C]',
            dataSource: chartData!,
            color: const Color.fromRGBO(192, 108, 132, 1),
            xValueMapper: (ChartData sensors, _) => sensors.timex,
            yValueMapper: (ChartData sensors, _) => sensors.t,
            dataLabelSettings: DataLabelSettings(isVisible: false),
            animationDuration: 0,
          ),
          //----------------------------------- humidity
          LineSeries<ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            enableTooltip: true,
            name: 'Humedad [%]',
            dataSource: chartData!,
            color: Color.fromARGB(212, 118, 170, 121),
            xValueMapper: (ChartData sensors, _) => sensors.timex,
            yValueMapper: (ChartData sensors, _) => sensors.h,
            dataLabelSettings: DataLabelSettings(isVisible: false),
            animationDuration: 0,
          ),
          //----------------------------------- ultraviolet
          LineSeries<ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            enableTooltip: true,
            name: 'UltraVioleta [Index]',
            dataSource: chartData!,
            color: Color.fromARGB(213, 134, 118, 170),
            xValueMapper: (ChartData sensors, _) => sensors.timex,
            yValueMapper: (ChartData sensors, _) => sensors.uv,
            dataLabelSettings: DataLabelSettings(isVisible: false),
            animationDuration: 0,
          ),
          //----------------------------------- Sound
          LineSeries<ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            enableTooltip: true,
            name: 'Ruido [dB]',
            dataSource: chartData!,
            color: Color.fromARGB(255, 94, 157, 252),
            xValueMapper: (ChartData sensors, _) => sensors.timex,
            yValueMapper: (ChartData sensors, _) => sensors.db,
            dataLabelSettings: DataLabelSettings(isVisible: false),
            animationDuration: 0,
          ),
          //----------------------------------- Ligth
          LineSeries<ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            enableTooltip: true,
            name: 'Iluminacion [Lux x10]',
            dataSource: chartData!,
            color: Color.fromARGB(255, 234, 252, 133),
            xValueMapper: (ChartData sensors, _) => sensors.timex,
            yValueMapper: (ChartData sensors, _) => sensors.lux,
            dataLabelSettings: DataLabelSettings(isVisible: false),
            animationDuration: 0,
          ),
          //----------------------------------- Air
          LineSeries<ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            enableTooltip: true,
            name: 'Aire [PPM x10]',
            dataSource: chartData!,
            color: Color.fromARGB(255, 112, 112, 112),
            xValueMapper: (ChartData sensors, _) => sensors.timex,
            yValueMapper: (ChartData sensors, _) => sensors.ppm,
            dataLabelSettings: DataLabelSettings(isVisible: false),
            animationDuration: 0,
          )
        ]);
  }

  // ---------------------------------------------------------- onMsg
  void onMessage(List<MqttReceivedMessage> event) {
    if (mounted) {
//print(event.length);

      //final topicFilter = MqttClientTopicFilter('inv/random', client?.updates);

      final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      //debugPrint('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
      //    'payload is <-- $message -->');

      //print("[MQTT client] message with topic: ${event[0].topic}");

      //debugPrint("[MQTT client] ${event[0].topic}: $message");

      //------------------ Temperature-----------------------
      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/t') ==
          0)
        setState(() {
          if (t != message) {
            t = message;
            _updateDataSource();
          }
          //debugPrint("[MQTT client] ${event[0].topic}: $message");
        });

      //------------------ Humidity-----------------------
      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/h') ==
          0)
        setState(() {
          if (h != message) {
            h = message;
            _updateDataSource();
          }

          //debugPrint("[MQTT client] ${event[0].topic}: $message");
        });

      //------------------ Ultraviolet-----------------------
      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/uv') ==
          0)
        setState(() {
          if (uv != message) {
            uv = message;
            debugPrint('${double.parse(uv)}');
            _updateDataSource();
          }

          //debugPrint("[MQTT client] ${event[0].topic}: $message");
        });

      //------------------ Sound-----------------------
      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/db') ==
          0)
        setState(() {
          if (db != message) {
            db = message;
            _updateDataSource();
          }

          //debugPrint("[MQTT client] ${event[0].topic}: $message");
        });
      //------------------ Ligth-----------------------
      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/lux') ==
          0)
        setState(() {
          if (lux != message) {
            lux = message;
            _updateDataSource();
          }

          //debugPrint("[MQTT client] ${event[0].topic}: $message");
        });
      //------------------ Air Q-----------------------
      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/sensors/ppm') ==
          0)
        setState(() {
          if (ppm != message) {
            ppm = message;
            _updateDataSource();
          }

          //debugPrint("[MQTT client] ${event[0].topic}: $message");
        });

      //------------------ panel/app/response-----------------------
      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/app/response') ==
          0)
        setState(() {
          debugPrint("Chart Received");
        });

      //------------------ panel/app/report-----------------------
      if (event[0].topic.compareTo('${_prefs.getString('rootTopic')}' +
              'panels/' +
              _panelID +
              '/app/report') ==
          0)
        setState(() {
          debugPrint("Report Received");
        });
    } else {
      onDisConnected();
    }
  }

  // -------------------------------- _loadConfig
  Future _loadConfig() async {
    debugPrint('UID ${_prefs.getString('mqttClient')}');
    client = MqttServerClient.withPort('${_prefs.getString('broker')}',
        '${_prefs.getString('mqttClient')}', 1883);
    //client = MqttServerClient(broker, mqttClient);
    connect('prefBroker', '${_prefs.getString('mqttClient')}');
    //MqttUtilities.asyncSleep(60);
  }

// -------------------------------- onPublish
  void onPublish(String message, String topic) {
    print('send msg: $message');

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    //client?.publishMessage('inv/' + _currentUser.uid + '/app',
    //    MqttQos.atLeastOnce, builder.payload!);
    client?.publishMessage('$topic', MqttQos.atLeastOnce, builder.payload!);

    builder.clear();
  }

  // -------------------------------- onDisconected
  void onDisConnected() {
    debugPrint('Panel Chart Disconnected');
    onPublish('0',
        '${_prefs.getString('rootTopic')}' + 'panels/' + _panelID + '/app');
    client?.disconnect();
  }

  // --------------------------------- onConnected
  void connect(String? top, String? left) async {
    print('mqtt conection panel chart');
    final connMessage = MqttConnectMessage()
        //.keepAliveFor(10)
        //.withWillTopic('inv/' + '$_currentUser.email' + '/app')
        .withWillTopic('${_prefs.getString('rootTopic')}' +
            'panels/' +
            '$_panelID' +
            '/app')
        .withWillMessage('0')
        .startClean()
        //.withWillRetain()
        .withWillQos(MqttQos.exactlyOnce);
    client?.connectionMessage = connMessage;
    try {
      await client?.connect();
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }

    final topic1 = '${_prefs.getString('rootTopic')}' +
        'panels/' +
        _panelID +
        '/#'; // Wildcard topic
    //client?.subscribe(topic1, MqttQos.atMostOnce);
    //onSubscribe(topic1);
    client?.subscribe(topic1, MqttQos.atLeastOnce);
    subscription = client?.updates?.listen(onMessage);

    onPublish('{"method":"Chart"}',
        '${_prefs.getString('rootTopic')}' + 'panels/' + _panelID + '/app');
  }

  ///Continously updating the data source based on timer
  void _updateDataSource() {
    //if (isCardView != null)
    {
      DateTime tsdate = DateTime.now();
      //tsdate = tsdate.hour as DateTime;
      chartData!.add(ChartData(
          tsdate,
          int.parse(t),
          int.parse(h),
          double.parse(uv),
          int.parse(db),
          int.parse(lux) / 10,
          int.parse(ppm) / 10));
      //chartData!.add(ChartData(count, newnumber));
      //if (chartData!.length == 2000) {
      //  chartData!.removeAt(0);
      //  _chartSeriesController?.updateDataSource(
      //    addedDataIndexes: <int>[chartData!.length - 1],
      //    removedDataIndexes: <int>[0],
      //  );
      //} else {
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[chartData!.length - 1],
      );
      //}
    }
  }
}

/// Private calss for storing the chart series data points.
class ChartData {
  ChartData(this.timex, this.t, this.h, this.uv, this.db, this.lux, this.ppm);
  final DateTime timex;
  final num t;
  final num h;
  final num uv;
  final num db;
  final num lux;
  final num ppm;
}
