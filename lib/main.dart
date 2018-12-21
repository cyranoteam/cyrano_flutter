import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/src/common/color.dart' as chart_color;

class CyranoWord {
  //{"color":"#faa000","dimensions":"Nurturing","found":true,"in_graph":"1","text":"world","weight":0.3}],"success":true}
  String color;
  String dimensions;
  bool found;
  String inGraph;
  String text;
  double weight;

  CyranoWord(
      {this.color,
      this.dimensions,
      this.found,
      this.inGraph,
      this.text,
      this.weight});

  factory CyranoWord.fromJson(Map<String, dynamic> json) {
    return CyranoWord(
        color: json['color'] ?? '#000000',
        dimensions: json['dimensions'] ?? '',
        found: json['found'] ?? false,
        inGraph: json['in_graph'] ?? '',
        text: json['text'] ?? '',
        weight: (json['weight'] ?? 0.0).toDouble());
  }

  Color get realcolor =>
      Color(int.parse("0x${color.substring(1)}") | 0xFF000000);
  chart_color.Color get chartcolor => chart_color.Color.fromHex(code: color);
}

class CyranoData {
  final String message;
  final bool success;
  final List<CyranoWord> words;

  CyranoData({this.message, this.success, this.words});

  factory CyranoData.fromJson(Map<String, dynamic> json) {
    print("Data returned: $json");
    return CyranoData(
        message: json['message'] ?? '',
        success: json['success'] ?? '',
        words: List.generate(json['data'].length,
            (idx) => CyranoWord.fromJson(json['data'][idx])));
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyrano.ai Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Cyrano.ai Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<CyranoData> _data;
  String _model = "5be758a7fd4f43000c77812d";
  String _submittedText = '';
  CyranoData _snapshot;

  // Create a text controller. We will use it to retrieve the current value
  // of the TextField!
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myController.dispose();
    super.dispose();
  }

  var map = {};

  Future<CyranoData> fetchData() async {
    print("Fetching for model $_model");
    final response = await http.post(
        "http://color-demo-api.cyrano.ai/chat/$_model",
        headers: {"Content-Type": "application/json"},
        body: '{"message": ${json.encode(myController.text)}}');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      _submittedText = myController.text;
      myController.text = "";
      return CyranoData.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      print("Error: ${response.body}");
      throw Exception('Cyrano.ai returned an error: ${response.reasonPhrase}');
    }
  }

  void _analyzeText() {
    // String decode = json.decode(response.body);

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // data without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _data = fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: SingleChildScrollView(
            child: Column(
              // Column is also layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28.0, vertical: 30.0),
                      child: Text("Model"),
                    ),
                    new DropdownButton<String>(
                      onChanged: _onModelChange,
                      value: _model,
                      items: _getModelItems(),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: FutureBuilder<CyranoData>(
                    future: _data,
                    builder: (context, snapshot) {
                      if (_data == null) {
                        return Text(
                            "Enter some text to see the Cyrano.ai Analysis");
                      }
                      if (snapshot.hasData) {
                        _snapshot = snapshot.data;
                        List<Widget> widgets = new List();
                        snapshot.data.words.forEach(
                            (f) => widgets.add(_textFromCyranoWord(f)));
                        return Column(
                          children: <Widget>[
                            Container(
                                child: SimpleBarChart.withData(generateSeriesData()),
                                constraints:
                                    BoxConstraints.tightFor(height: 100)),
                            Wrap(children: widgets),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      // By default, show a loading spinner
                      return CircularProgressIndicator();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: TextField(
                    controller: myController,
                    onEditingComplete: _analyzeText,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Please enter text to analyze'),
                  ),
                ),
                // This trailing comma makes auto-formatting nicer for build methods.
                new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new RaisedButton(
                            key: null,
                            color: Colors.blue,
                            onPressed: _analyzeText,
                            child: new Text(
                              "Analyze",
                              style: new TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Roboto"),
                            )),
                      )
                    ])
              ],
            ),
          ),
        ));
  }

  _onModelChange(String newValue) {
    myController.text = _submittedText;
    setState(() {
      _model = newValue;
      _data = fetchData();
    });
  }

  _getModelItems() {
    final models = [
      ["5be758a7fd4f43000c77812d", "Bank"],
      ["5be8d6d8fd4f43000c7782dd", "Senses"],
      ["5be8f3e8fd4f43000c778398", "Emotions"],
      ["5be883d8fd4f43000c778223", "Commitment Motivation"],
      ["5bfd1fd0fd4f43000c778979", "Direction"],
      ["5bfd0810fd4f43000c778813", "Locus"],
      ["5c04fceefd4f430009778047", "Persuasion"],
      ["5bfd19ccfd4f43000c77890c", "Proximity"],
      ["5c1571dcfd4f43000c7790bf", "Zero Abuse"],
    ];
    List<DropdownMenuItem<String>> list = new List();
    models.forEach((element) => list.add(new DropdownMenuItem<String>(
        value: element[0], child: new Text(element[1]))));
    return list;
  }

  var _models = new List<ModelScore>();

  generateSeriesData() {
    var map = <String, ModelScore>{};
    if (_snapshot != null) {
      _models.clear();
      _snapshot.words.where((word) => word.found).forEach((word) =>
          word.dimensions.split(',').forEach((dimension) => map
              .putIfAbsent(dimension,
                  () => new ModelScore(dimension, word.chartcolor, 0))
              .score += word.weight));
      print("Create model graph series $map");
      if (_model == "5be758a7fd4f43000c77812d") {
        // BANK
        ["Blueprint", "Action", "Nurturing", "Knowledge"].forEach((val) {
          if (map.containsKey(val)) {
            _models.add(map[val]);
          }
        });
        return _models;
      }
      _models.addAll(map.values);
      return _models;
    }
    return _models;
  }
}

Widget _textFromCyranoWord(CyranoWord cyranoWord) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Text(cyranoWord.text,
        style: new TextStyle(
            fontSize: 12.0,
            color: cyranoWord.realcolor,
            fontWeight: FontWeight.bold,
            fontFamily: "Roboto")),
  );
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SimpleBarChart.withSampleData() {
    return SimpleBarChart.withData(_createSampleData());
  }

  factory SimpleBarChart.withData(data) {
    return new SimpleBarChart(
      _createSeries(data),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
    );
  }

  /// Create one series with sample hard coded data.
  static List<ModelScore> _createSampleData() {
    final data = [
      new ModelScore('2014', charts.MaterialPalette.blue.shadeDefault, 5),
      new ModelScore('2015', charts.MaterialPalette.blue.shadeDefault, 25),
      new ModelScore('2016', charts.MaterialPalette.blue.shadeDefault, 100),
      new ModelScore('2017', charts.MaterialPalette.blue.shadeDefault, 75),
    ];

    return data;
  }

  static List<charts.Series<ModelScore, String>> _createSeries(data) {
    return [
      new charts.Series<ModelScore, String>(
        id: 'Cyrano',
        colorFn: (t, __) => t.color,
        domainFn: (ModelScore factor, _) => factor.label,
        measureFn: (ModelScore factor, _) => factor.score,
        data: data,
      )
    ];
  }
}

/// Sample ordinal data type.
class ModelScore {
  final String label;
  chart_color.Color color;
  double score;

  ModelScore(this.label, this.color, this.score);
}
