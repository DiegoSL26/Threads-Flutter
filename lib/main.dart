//Isolate function
import 'dart:isolate';

//compute fuction
//import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolates Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Isolates Test Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isWorking = false;
  int counter = 0;

  Future<void> _incrementCounter() async {
    setState(() {
      isWorking = true;
    });

    debugPrint("Starting process");

    ReceivePort receivePort = ReceivePort();
    Isolate firstIsolate =
        await Isolate.spawn(heavyProcess, receivePort.sendPort);

    receivePort.listen((respuestaNumero) {
      debugPrint("First Isolate ends");
      setState(() {
        isWorking = false;
      });
      debugPrint("End of the process");
      firstIsolate.kill(priority: Isolate.immediate);
    });
  }

  static Future<void> heavyProcess(SendPort sendPort) async {
    debugPrint("First Isolate starts");

    int numero = 0;

    for (int i = 1; i < 4000000000; i++) {
      numero = numero + i;
    }

    ReceivePort secondReceivePort = ReceivePort();
    await Isolate.spawn(heavyProcessComplementary, secondReceivePort.sendPort);

    secondReceivePort.listen((numero2) async {
      debugPrint("Second Isolate ends");
      sendPort.send(numero);
    });
  }

  static Future<void> heavyProcessComplementary(SendPort sendPort) async {
    int numero = 0;

    debugPrint("Second Isolate starts");

    for (int i = 1; i < 4000000000; i++) {
      numero = numero + i;
    }

    sendPort.send(numero);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isWorking)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                    onPressed: () {
                      _incrementCounter();
                    },
                    child: const Text('This is an example',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25))),
              Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: [
                      const Text(
                        'You have pushed:',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text('$counter times.',
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                    ],
                  ))
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  counter += 1;
                });
              },
            ),
            FloatingActionButton(
              child: const Icon(Icons.restart_alt),
              onPressed: () {
                setState(() {
                  counter = 0;
                });
              },
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
