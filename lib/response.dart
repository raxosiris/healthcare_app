import 'dart:io';
import 'dart:convert';
import "dart:async";
import "symptoms.dart";

enum Gender { MALE, FEMALE }

class Responder
{
  final _token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Im5pa29sYWltZXJyaXR0MjBAZ21haWwuY29tIiwicm9sZSI6IlVzZXIiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiIxNTE3IiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy92ZXJzaW9uIjoiMTA4IiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9saW1pdCI6IjEwMCIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcCI6IkJhc2ljIiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9sYW5ndWFnZSI6ImVuLWdiIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9leHBpcmF0aW9uIjoiMjA5OS0xMi0zMSIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcHN0YXJ0IjoiMjAxOC0xMS0xMCIsImlzcyI6Imh0dHBzOi8vYXV0aHNlcnZpY2UucHJpYWlkLmNoIiwiYXVkIjoiaHR0cHM6Ly9oZWFsdGhzZXJ2aWNlLnByaWFpZC5jaCIsImV4cCI6MTU0MTk0MTA1OSwibmJmIjoxNTQxOTMzODU5fQ.7hrBjee3VRtQAvniC9aJccMgawsHcs1lrvF3Cquwmu4";
  int _birthYear;
  Gender _gender;

  Map<String, int> _symptomToId = Map<String, int>();

  Responder(int birthYear, Gender gender)
  {
    this._birthYear = birthYear;
    this._gender = gender;

    Symptoms.symptomsBlock.split(";").forEach((data)
    {
      final dataSplit = data.split("->");
      _symptomToId[dataSplit[0].toLowerCase()] = int.parse(dataSplit[1]);
    });
  }


  List<int> idsOfSymptoms(String input)
  {
    List<int> ids = List<int>();
    for (var key in _symptomToId.keys)
      if (input.contains(key)) ids.add(_symptomToId[key]);
    return ids;
  }

  String intListToString(List<int> list)
  {
    String stringy = "";
    for (var i = 0; i < list.length; i++)
    {
      stringy += list[i].toString();
      if (i + 1 < list.length) stringy += ",";
    }
    return stringy;
  }

  Future<String> jsonFromAPI(List<int> symptomIds)
  {
    final url = Uri.https("healthservice.priaid.ch", "/diagnosis",
    {
      "token": _token,
      "language": "en-gb",
      "symptoms": "[${intListToString(symptomIds)}]",
      "gender": ((_gender == Gender.MALE) ? "male" : "female"),
      "year_of_birth": _birthYear.toString()
    });

    return HttpClient().getUrl(url)
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) => response.transform(utf8.decoder).join());
  }

  String diagnosisFromJson(String json)
  {
    // diagnosis with highest accuracy is after name, but before the following quote mark.
    print(json);
    List<String> diagnoses = List<String>();
    for (var issue in json.split("\"Issue\""))
    {
      if (issue.contains("\"Name\":\""))
      {
        diagnoses.add(issue
            .split("\"Name\":\"")[1] // first thing after Name ...
            .split("\"")[0] // ... and ends at the following quote mark
            .toLowerCase());
      }
    }
    var statement = "I think you have ${diagnoses[0]}";
    if (diagnoses.length > 1)
    {
      statement += "\nHowever, you could also have ${diagnoses[1]}";
      if (diagnoses.length == 3) statement += " or ${diagnoses[2]}";
      else if (diagnoses.length > 3)statement += ", ${diagnoses[2]} or ${diagnoses[3]}";
    }
    statement += ".";

    return statement;
  }

  Future<String> response(String input)
  {
    final completer = new Completer<String>();
    final List<int> symptomIds = idsOfSymptoms(input);
    if (symptomIds.isNotEmpty) // if user inputted a recognised symptom (e.g. i feel queasy)
    {
      jsonFromAPI(symptomIds).then((json) => completer.complete(diagnosisFromJson(json)));
    }
    else // Did not understand what the user inputted
    {
      completer.complete("I'm sorry, I did not understand your message. \nCould you please use simpler words?");
    }
    return completer.future;
  }
}