import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
      MaterialApp(
        title: 'Bloc Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: BlocProvider(
          create: (context) => PersonsBloc(),
          child: const HomePage(),
        ),
      )
  );
}

// The class that takes care of the action to be done ->
// umbrella event for all events -> Bloc action
@immutable
abstract class LoadAction {
  const LoadAction();
}

// Input to the bloc
@immutable
class LoadPersonsAction extends LoadAction {
  final PersonUrl url;

  const LoadPersonsAction({required this.url}) : super();
}

enum PersonUrl {
  persons1,
  persons2,
}

// Gets the json file from the url that is of the type PersonUrl
extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.persons1:
        return 'http://127.0.0.1:5500/api/persons1.json';
      case PersonUrl.persons2:
        return 'http://127.0.0.1:5500/api/persons2.json';
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  // Constructor that initializes the Person class object using the
  // data recieved from the json file
  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;

  // Default construction -> not needed in this example
  const Person({
    required this.name,
    required this.age
  });
}

// Returns an iterable (list) of persons from the url provided
Future<Iterable<Person>> getPersons(String url) =>
    HttpClient()
    // Gives us a request
        .getUrl(Uri.parse(url))
    // Gives us a response based on the request received from above
        .then((req) => req.close())
    // Response is then converted into a string
        .then((resp) => resp.transform(utf8.decoder).join())
    // String is converted into a list
        .then((str) => json.decode(str) as List<dynamic>)
    // Finally, list is converted into an iterable of persons and the result is a Future
        .then((list) => list.map((e) => Person.fromJson(e)));

// Application State -> output of the bloc
@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult({
    required this.persons,
    required this.isRetrievedFromCache,
  });

  @override
  String toString() =>
      'FetchResult (isRetrievedFromCache = $isRetrievedFromCache, persons = $persons)';
}

class PersonsBloc extends Bloc<LoadPersonsAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};

  PersonsBloc() : super(null) {
    on<LoadPersonsAction>(
      // event is input and emit is output
          (event, emit) async {
        final url = event.url;
        // Checks if the cache contains the person already
        if (_cache.containsKey(url)) {
          // Cache contains value, so we send the value directly from the cache
          final cachedPersons = _cache[url]!;
          final result = FetchResult(
            persons: cachedPersons,
            isRetrievedFromCache: true,
          );
          // The resulting event is returned to whoever requested change
          emit(result);
        } else {
          final persons = await getPersons(url.urlString);
          // Since the cache does not have the required person, the data is first stored into
          // the cache and then emitted.
          _cache[url] = persons;
          final result = FetchResult(
            persons: persons,
            isRetrievedFromCache: false,
          );
          emit(result);
        }
      },
    );
  }

}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
    );
  }
}

