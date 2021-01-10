import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; //←追加
import 'package:firebase_core/firebase_core.dart'; //←追加

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'やれやれだぜ'),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    return FutureBuilder(
      future: _initialization,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _streamBuilder();
        }
        return LinearProgressIndicator();
      },
    );
  }

  Widget _streamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rushes').snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        return _buildList(snapshot.data.docs);
      },
    );
  }

  Widget _buildList(List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) {
        return _buildListItem(data);
      }).toList(),
    );
  }

  Widget _buildListItem(DocumentSnapshot data) {
    final rushes = Rushes(data);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: ListTile(
            title: Text(rushes.makeOraOra()),
            trailing: FlatButton(
              onPressed: () {
                rushes.reference.update({'times': 0});
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.delete,
                  ),
                  Text(rushes.times.toString()),
                ],
              ),
            ),
            onTap: () {
              rushes.reference.update({'times': FieldValue.increment(1)});
            }),
      ),
    );
  }
}

class Rushes {
  String word;
  int times;
  DocumentReference reference;

  Rushes(DocumentSnapshot snapshot) {
    var map = snapshot.data();
    this.word = map['word'];
    this.times = map['times'];
    this.reference = snapshot.reference;
  }

  String makeOraOra() {
    var ret = "";
    for (var i = 0; i < times; i++) {
      ret += word;
    }
    return ret;
  }
}
