// This file contains the first screen of the app.
// It is composed of two cursors that are used to choose the number of civilians and undercovers.

import 'package:flutter/material.dart';
import 'names.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _totalWords = 0;
  int _usedWords = 0;

  // this function is called when the user validates the number of players
  void _navigateToNameSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NameSelection(
          civilianWord: 'foo',
          undercoverWord: 'bar',
          numCivilians: _numCivilians,
          numUndercovers: _numUndercovers,
          isLatePlayerAdd: false,
          latePlayerAddCallback: (name) => {},
        ),
      ),
    );
  }

  void getNbWords() async {
    final prefs = await SharedPreferences.getInstance();
    _usedWords = prefs.getInt('counter') ?? -1;
    _usedWords ++;
    try {
      final csvData = await loadAsset();
      List<String> rows = csvData.split('\n');
      _totalWords = rows.length;
    } catch (e) {
      print('Error reading CSV: $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getNbWords();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role-playing Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('number of pair of words used: $_usedWords / $_totalWords.'),
            const SizedBox(height: 20),
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

