import 'package:flutter/material.dart';
import 'names.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _numCivilians = 1;
  int _numUndercovers = 1;

  void _navigateToNameSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NameSelection(
          numCivilians: _numCivilians,
          numUndercovers: _numUndercovers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role-playing Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Number of Civilians'),
            Slider(
              value: _numCivilians.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _numCivilians = value.round();
                });
              },
            ),
            Text('$_numCivilians'),
            const SizedBox(height: 20),
            Text('Number of Undercovers'),
            Slider(
              value: _numUndercovers.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _numUndercovers = value.round();
                });
              },
            ),
            Text('$_numUndercovers'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToNameSelection,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

