import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_industry/screens/panelList_page.dart';
import '/screens/profile_page.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
//import 'package:segment_display/segment_display.dart';
//import 'package:device_info/device_info.dart';
import '/screens/NavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:smart_industry/screens/sample_view.dart';
import 'dart:math' as math;

MqttConnectionState? connectionState;
StreamSubscription? subscription;
late User _currentUser;
late SharedPreferences _prefs;
late String _panelID;

// Renders the realtime line chart sample.
class ChartsPanelPage extends SampleView {
  final User user;
  final SharedPreferences prefs;
  final String id;

  /// Creates the realtime line chart sample.
  const ChartsPanelPage(
      {required this.user, required this.prefs, required this.id})
      : super(user: user, prefs: prefs, id: id);

  @override
  ChartsPanelPageState createState() => ChartsPanelPageState();
}

/// State class of the realtime line chart.
class ChartsPanelPageState extends SampleViewState {
  ChartsPanelPageState() {
    //timer =
    //    Timer.periodic(const Duration(milliseconds: 100), _updateDataSource);
  }

  MqttServerClient? client;
  Timer? timer;
  List<_ChartData>? chartData;
  late int count;
  ChartSeriesController? _chartSeriesController;

  @override
  void dispose() {
    timer?.cancel();
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
    count = 19;
    chartData = <_ChartData>[
      _ChartData(0, 42),
      _ChartData(1, 47),
      _ChartData(2, 33),
      _ChartData(3, 49),
      _ChartData(4, 54),
      _ChartData(5, 41),
      _ChartData(6, 58),
      _ChartData(7, 51),
      _ChartData(8, 98),
      _ChartData(9, 41),
      _ChartData(10, 53),
      _ChartData(11, 72),
      _ChartData(12, 86),
      _ChartData(13, 52),
      _ChartData(14, 94),
      _ChartData(15, 92),
      _ChartData(16, 86),
      _ChartData(17, 72),
      _ChartData(18, 94),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLiveLineChart();
  }

  /// Returns the realtime Cartesian line chart.
  SfCartesianChart _buildLiveLineChart() {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis:
            NumericAxis(majorGridLines: const MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0)),
        series: <LineSeries<_ChartData, int>>[
          LineSeries<_ChartData, int>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            dataSource: chartData!,
            color: const Color.fromRGBO(192, 108, 132, 1),
            xValueMapper: (_ChartData sales, _) => sales.country,
            yValueMapper: (_ChartData sales, _) => sales.sales,
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
              '/sensors/db') ==
          0)
        setState(() {
          _updateDataSource(int.parse(message));
          debugPrint("[MQTT client] ${event[0].topic}: $message");
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

    onPublish('1',
        '${_prefs.getString('rootTopic')}' + 'panels/' + _panelID + '/app');
  }

  ///Continously updating the data source based on timer
  void _updateDataSource(int newnumber) {
    //if (isCardView != null)
    {
      chartData!.add(_ChartData(count, newnumber));
      if (chartData!.length == 20) {
        chartData!.removeAt(0);
        _chartSeriesController?.updateDataSource(
          addedDataIndexes: <int>[chartData!.length - 1],
          removedDataIndexes: <int>[0],
        );
      } else {
        _chartSeriesController?.updateDataSource(
          addedDataIndexes: <int>[chartData!.length - 1],
        );
      }
      count = count + 1;
    }
  }

  ///Get the random data
  int _getRandomInt(int min, int max) {
    final math.Random random = math.Random();
    return min + random.nextInt(max - min);
  }
}

/// Private calss for storing the chart series data points.
class _ChartData {
  _ChartData(this.country, this.sales);
  final int country;
  final num sales;
}
