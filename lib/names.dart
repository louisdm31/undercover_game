// This file contains the view in which each player can input its name and is assigned a word.

import 'package:flutter/material.dart';
import 'voting.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/words.csv');
}

class NameSelection extends StatefulWidget {
  final int numCivilians;
  final int numUndercovers;
  final bool isLatePlayerAdd;
  final Function(String) latePlayerAddCallback;
  String civilianWord;
  String undercoverWord;

  NameSelection({
    Key? key,
    required this.numCivilians,
    required this.numUndercovers,
    required this.isLatePlayerAdd,         // The next four parameters are only used in the case where a player joins in the middle of the game.
    required this.latePlayerAddCallback,
    required this.civilianWord,
    required this.undercoverWord,
  }) : super(key: key);

  @override
  _NameSelectionState createState() => _NameSelectionState();

  // Randomly assigns a role to each player by generating an array of the form ['c', 'w', 'c', 'u', 'c', 'c']
  List<String> _generateRoles() {
    final List<String> roles = <String>[];
    if (!isLatePlayerAdd)
        roles.add('w');
    roles.addAll(List.filled(numCivilians, 'c'));
    roles.addAll(List.filled(numUndercovers, 'u'));
    roles.shuffle();
    return roles;
  }
}

class _NameSelectionState extends State<NameSelection> {
  String _selectedName = '';
  final List<String> all_names = [];
  int _currentPlayerIndex = 0;
  late List<String> roles;

  // For now, the name selection view proposes a list of pre-recorded player names which is hard-coded.
  final defaultNames = ['Alex', 'Corentin', 'Cyrille', 'Dimitri', 'François', 'Grégoire', 'Louis', 'Lucas', 'Nathan', 'Mathieu', 'Maxime', 'Rachel', 'Robinson', 'Tristan'];
  final String alphabet = 'abcdefghijklmnopqrstuvwxyzéèçêôù';
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!widget.isLatePlayerAdd)
      fillWords();
    roles = widget._generateRoles();
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) + newChar + oldString.substring(index + 1);
  }

  // This function is used to decipher the pair of words that is read from assets/words.csv.
  // The words are ciphered with the Cesar cipher so that I can compile the app without seeing the words.
  String decrypt(String text) {
    for (int i = 0; i < text.length; i++)
    {
      int index = alphabet.indexOf(text[i]);
      if (index == -1)
        continue;
      text = replaceCharAt(text, i, alphabet[(index - 10) % alphabet.length]);
    }
    return text;
  }

  // Reads a counter and the corresponding pair of words in assets/words.csv.
  // The counter is then incremented for the next game.
  void fillWords() async
  {
    final prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt('counter') ?? -1;
    prefs.setInt('counter', counter + 1);
    try {
      final csvData = await loadAsset();
      List<String> rows = csvData.split('\n');
      List<String> first = rows[counter + 1].split(',');


      if (rows.isNotEmpty && rows[0].length >= 2) {
        widget.civilianWord = decrypt(first[0]);
        widget.undercoverWord = decrypt(first[1]);
      }
    } catch (e) {
      print('Error reading CSV: $e');
    }
  }

  void _navigateToVotingScreen() {
    if (widget.isLatePlayerAdd)
    {
      Navigator.pop(context);
      widget.latePlayerAddCallback(_selectedName);  // Adds the new player to the view of the voting screen.
    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VotingScreen(
            names: all_names,
            roles: roles,
            civilianWord: widget.civilianWord,
            undercoverWord: widget.undercoverWord,
          ),
        ),
      );
    }
  }
  
  // Records player's name and displays a word, in function of its role.
  void _submitName() async {
    if (_selectedName == '0')
    {
      // This is a special admin feature to reset the counter to 0.
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('counter', -1);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('back to 0'),
          );
        },
      );
      return;
    }
    all_names.add(_selectedName);
    _currentPlayerIndex++;

    String role = roles[_currentPlayerIndex - 1];
    String word;

    if (role == 'w') {
      word = 'You are Mr. White';
    } else {
      word = 'Your word is ${role == 'c' ? widget.civilianWord : widget.undercoverWord}';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your word'),
          content: Text(word),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_currentPlayerIndex == roles.length) {
                  _navigateToVotingScreen();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Displays the list of default player names.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submit your name"),
      ),
      body: 
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ ...defaultNames
                .map(
                  (name) => Column(
                    children: [
                      SizedBox(
                        height: 30,
                        child:
                        ChoiceBox(
                          name: name,
                          onTap: () {
                            setState(() => _selectedName = name);
                            _submitName();
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
                .toList(),

                // Displays the text field for players whose name is not in the default list.
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Custom Name',
                    labelText: 'Or enter a custom name',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    _selectedName = value;
                  },
                  controller: _textController,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitName();
                    _textController.clear();
                  },
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 20),
              ],
          ),
        ),
    );
  }
}

// Widget containing a single box with a default player name.
class ChoiceBox extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const ChoiceBox({
    required this.name,
    required this.onTap,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

