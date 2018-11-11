import 'dart:io';
import 'dart:convert';
import "dart:async";
import "symptoms.dart";

enum Gender { MALE, FEMALE }

class Responder
{
  final _token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6Im5pa29sYWltZXJyaXR0MjBAZ21haWwuY29tIiwicm9sZSI6IlVzZXIiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiIxNTE3IiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy92ZXJzaW9uIjoiMTA4IiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9saW1pdCI6IjEwMCIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcCI6IkJhc2ljIiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9sYW5ndWFnZSI6ImVuLWdiIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9leHBpcmF0aW9uIjoiMjA5OS0xMi0zMSIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcHN0YXJ0IjoiMjAxOC0xMS0xMCIsImlzcyI6Imh0dHBzOi8vYXV0aHNlcnZpY2UucHJpYWlkLmNoIiwiYXVkIjoiaHR0cHM6Ly9oZWFsdGhzZXJ2aWNlLnByaWFpZC5jaCIsImV4cCI6MTU0MTkzMDc2MiwibmJmIjoxNTQxOTIzNTYyfQ.W5FTeM3o91f0L4P-BqxTeqZe9T0jqOxbsi-Zm69pL7M";
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


  int idOfSymptom(String input)
  {
    for (var key in _symptomToId.keys)
      if (input.contains(key)) return _symptomToId[key];
    return -1;
  }

  Future<String> jsonFromAPI(int symptomId)
  {
    final url = Uri.https("healthservice.priaid.ch", "/diagnosis",
    {
      "token": _token,
      "language": "en-gb",
      "symptoms": "[${symptomId.toString()}]",
      "gender": ((_gender == Gender.MALE) ? "male" : "female"),
      "year_of_birth": _birthYear.toString()
    });

    return HttpClient().getUrl(url)
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) => response.transform(utf8.decoder).join());
  }

  String diagnosisFromJson(String json)
  {
    print(json);
    // diagnosi;s with highest accuracy is after name, but before the following quote mark.
    return "I think you have "
        + json
        .split("\"Name\":\"")[1] // first thing after Name ...
        .split("\"")[0] // ... and ends at the following quote mark
        .toLowerCase()
    + "."; // because it will be displayed in middle of sentence.
  }

  Future<String> response(String input)
  {
    final completer = new Completer<String>();
    final int symptomId = idOfSymptom(input);
    if (symptomId != -1) // if user inputted a recognised symptom (e.g. i feel queasy)
    {
      jsonFromAPI(symptomId).then((json) => completer.complete(diagnosisFromJson(json)));
    }
    else // Did not understand what the user inputted
    {
      completer.complete("I'm sorry, I did not understand your message. \nCould you please use simpler words?");
    }
    return completer.future;
  }
}