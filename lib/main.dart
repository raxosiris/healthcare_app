import 'package:flutter/material.dart';
import 'response.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(primarySwatch: Colors.blue),
        home: new MyHomePage(title: 'Flutter Demo Home Page'));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final typeController = TextEditingController();
  final ageCategoriesToApproxAge = {
    'Child': 10,
    'Teenager': 16,
    'Young adult': 30,
    'Middle aged': 50,
    'Senior': 70
  };
  var chatHistory = "Welcome! What seems to be the problem?\n";
  var approxAge = 50;
  var gender = Gender.MALE;
  List<Widget> widgetList = List();

  @override
  void initState() {
    super.initState();

    widgetList.add(botText('Hi, how are you feeling today. Any symptoms?'));
  }

  @override
  void dispose() {
    typeController.dispose();
    super.dispose();
  }

  Widget botText(String message) {
    return Container(
        child: Text(
      message,
      style: TextStyle(fontSize: 20.0),
    ));
  }

  Widget userText(String message) {
    return Container(
        child: Text(
      message,
      style: TextStyle(fontSize: 20.0),
      textAlign: TextAlign.right,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(widget.title)),
      body: Container(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ListView(
                children: widgetList,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 20.0,
                child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Type to ChatBot...'),
                    controller: typeController),
              ),
            )
          ],
        ),
      ),
      /*new Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              new DropdownButton<String>(
                  items: ageCategoriesToApproxAge.keys
                      .map((ageRange) => DropdownMenuItem<String>(
                            child: new Text(ageRange),
                            value: ageRange,
                          ))
                      .toList(),
                  hint: Text("Please give your age range"),
                  onChanged: (ageRange) => setState(
                      () => approxAge = ageCategoriesToApproxAge[ageRange])),
              new DropdownButton<String>(
                items: <String>['Male', 'Female']
                    .map((gender) => DropdownMenuItem<String>(
                        child: new Text(gender), value: gender))
                    .toList(),
                hint: Text("Please give your gender"),
                onChanged: (g) {
                  setState(() =>
                      gender = (g == "Male" ? Gender.MALE : Gender.FEMALE));
                },
              ),
              new Text(chatHistory),
              new TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Type to ChatBot...'),
                  controller: typeController)
            ])),*/
      /* floatingActionButton: new FloatingActionButton(
            onPressed: () // buggy :(
                {
              final responder = Responder(2018 - approxAge, gender);
              setState(() {
                responder
                    .response(typeController.text)
                    .then((response) => chatHistory += "$response\n");
                chatHistory += "${typeController.text}\n";
                typeController.text = "";
              });
            },
            tooltip: 'Increment',
            child: new Icon(Icons.add))*/
    );
  }
}
