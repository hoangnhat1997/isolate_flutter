import 'dart:isolate';
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

void heavyComputation(SendPort sendPort) {
  int sum = 0;
  for (int i = 0; i < 100000000; i++) {
    sum += i;
  }
  // Send the result back to the main isolate
  sendPort.send(sum);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: IsolateExample(),
    );
  }
}

class IsolateExample extends StatefulWidget {
  const IsolateExample({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IsolateExampleState createState() => _IsolateExampleState();
}

class _IsolateExampleState extends State<IsolateExample> {
  int _result = 0;
  bool _isLoading = false;

  Future<void> _startHeavyComputation() async {
    setState(() {
      _isLoading = true;
    });

    // Create a ReceivePort to receive messages from the isolate
    final receivePort = ReceivePort();

    // Spawn the isolate
    await Isolate.spawn(heavyComputation, receivePort.sendPort);

    // Wait for the result from the isolate
    receivePort.listen((data) {
      setState(() {
        _result = data;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isolate Example'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
                'Result: $_result',
                style: const TextStyle(fontSize: 24),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startHeavyComputation,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
