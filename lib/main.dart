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

    widgetList
        .add(botText('Hi, how are you feeling today. Any symptoms?', false));
  }

  @override
  void dispose() {
    typeController.dispose();
    super.dispose();
  }

  Widget botText(String message, bool showOptions) {
    return Container(
        padding: EdgeInsets.all(10.0),
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.green,
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 20.0),
        ));
  }

  Widget ageText() {
    Iterable<String> list = ageCategoriesToApproxAge.keys;

    List<Widget> options = List();

    for (String s in list) {
      options.add(GestureDetector(
        child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.yellow,
              borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
            ),
            child: Text(
              s,
              style: TextStyle(fontSize: 20.0),
            )),
        onTap: () {
          widgetList.add(botText('And, are you a male or a female?', true));
          widgetList.add(genderText());
          setState(() {});
        },
      ));
    }

    return Row(
      children: options,
    );
  }

  Widget genderText() {
    return Row(
      children: <Widget>[
        GestureDetector(
          child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.yellow,
                borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
              ),
              child: Text(
                'MALE',
                style: TextStyle(fontSize: 20.0),
              )),
          onTap: () {},
        ),
        GestureDetector(
          child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.yellow,
                borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
              ),
              child: Text(
                'FEMALE',
                style: TextStyle(fontSize: 20.0),
              )),
          onTap: () {},
        )
      ],
    );
  }

  Widget userText(String message) {
    return Container(
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.red,
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
        ),
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
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Container(
                // color: Colors.red,
                child: ListView.builder(
                    itemCount: widgetList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return widgetList[index];
                    }),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Type to ChatBot...'),
                controller: typeController,
                onSubmitted: (s) {
                  print(s);
                  widgetList.add(userText(s));

                  final responder = Responder(2018 - approxAge, gender);
                  setState(() {});
                  responder.response(typeController.text).then((response) {
                    print('Respionse');
                    print(response);
                    print(response.toUpperCase().contains(
                        "I did not understand your message".toUpperCase()));
                    if (response.toUpperCase().contains(
                        "I did not understand your message".toUpperCase())) {
                      widgetList.add(
                          botText("I'm sorry, I did not understand your message. \nCould you please use simpler words?", true));
                    } else {
                      widgetList.add(
                          botText('Okay, may I know how old you are?', true));
                      widgetList.add(ageText());
                    }

                    chatHistory += "$response\n";

                    setState(() {});
                  });
                  chatHistory += "${typeController.text}\n";
                  typeController.text = "";
                },
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
