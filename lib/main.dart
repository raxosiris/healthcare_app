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

  @override
  void dispose() {
    typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(widget.title)),
        body: new Center(
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
            ])),
        floatingActionButton: new FloatingActionButton(
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
            child: new Icon(Icons.add)));
  }
}
