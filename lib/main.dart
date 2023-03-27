import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:developer' as devtools show log;

extension Log on Object {
  void log() => devtools.log(toString());
}

void main() {
  runApp(
      MaterialApp(
        title: 'Bloc Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        // Injects the BlocProvider into the build context and makes it available throughout it 
        home: BlocProvider(
          create: (_) => PersonsBloc(),
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
      // basically, if given an event of LoadPersonsAction type, what do you want as output of FetchResult? type
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

// Extension on iterable
extension Subscript<T> on Iterable<T> {
  // Checks if length of iterable is greater then index or not, if lesser, then return null,
  // else return element at index.
  T? operator[](int index) => length > index ? elementAt(index) : null;
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                  onPressed: (){
                    // gets the PersonsBloc that had been injected into the build context
                    // add() method is used to give the required parameters into the bloc's on() function
                    // in the constructor.
                    context.read<PersonsBloc>().add(
                        const LoadPersonsAction(
                            url: PersonUrl.persons1
                        )
                    );
                  },
                  child: const Text('Load Json #1'),
              ),
              TextButton(
                onPressed: (){
                  context.read<PersonsBloc>().add(
                      const LoadPersonsAction(
                          url: PersonUrl.persons2
                      )
                  );
                },
                child: const Text('Load Json #2'),
              ),
            ],
          ),
          
          BlocBuilder<PersonsBloc, FetchResult?>(
            // Rebuilds only when previous result is not the same as the current result
              buildWhen: (previousResult, currentResult) {
                return previousResult?.persons != currentResult?.persons;
              },
              builder: ((context, fetchResult) {
                fetchResult?.log();
                final persons = fetchResult?.persons;
                if (persons == null) {
                  return const SizedBox();
                }
                return Expanded(
                  child: ListView.builder(
                      itemCount: persons.length,
                      itemBuilder: (context, index){
                        final person = persons[index]!;
                        return ListTile(
                          title: Text(person.name),
                        );
                      }),
                );
              })
          ),
        ],
      ),
    );
  }
}

