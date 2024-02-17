import 'package:flutter/material.dart';
import 'dart:math';
import 'names.dart';

class VotingScreen extends StatefulWidget {
  List<String> names;
  List<String> roles;
  String civilianWord;
  String undercoverWord;

  VotingScreen({
    Key? key,
    required this.names,
    required this.roles,
    required this.civilianWord,
    required this.undercoverWord,
  }) : super(key: key);

  @override
  _VotingScreenState createState() => _VotingScreenState();
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final VoidCallback onButtonPressed;

  const CustomAppBar({
    Key? key,
    required this.height,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Voting Screen'),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        IconButton(
          onPressed: onButtonPressed,
          icon: Image.asset('assets/add_player.png'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, height);
}


class _VotingScreenState extends State<VotingScreen> {
  Map<int, String?> revealedRoles = {-1: null};

  @override
  void initState() {
    super.initState();
    final Random _random = Random();
    int white = widget.roles.indexOf('w');
    int firstPlayer = min(_random.nextInt(widget.roles.length - 2), _random.nextInt(widget.roles.length - 2));
    firstPlayer = (white + 1 + firstPlayer) % widget.roles.length;
    String nameFirst = widget.names[firstPlayer];
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('premier joueur : $nameFirst'),
          );
        },
      );
    });
  }

  void revealAll() {
    for (int i = 0; i < widget.roles.length; i++)
    {
      if (widget.roles[i] == 'w')
        revealedRoles[i] = 'Mr. White';
      if (widget.roles[i] == 'u')
        revealedRoles[i] = 'undercover';
      if (widget.roles[i] == 'c')
        revealedRoles[i] = 'civil';
    }
    setState(() {});
  }

  void declareVictory() {
    int unrevealedCivilians = 0;
    int unrevealedUndercovers = 0;
    int unrevealedWhite = 0;
    for (int i = 0; i < widget.roles.length; i++)
    {
      if (!revealedRoles.containsKey(i)) {
        if (widget.roles[i] == 'c')
          unrevealedCivilians++;
        else if (widget.roles[i] == 'u')
          unrevealedUndercovers++;
        else if (widget.roles[i] == 'w')
          unrevealedWhite++;
      }
    }
    if (unrevealedUndercovers == 0 && unrevealedWhite == 0)
    {
      revealAll();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game over'),
            content: Text('victoire des civils'),
          );
        },
      );
    }
    if (unrevealedCivilians <= unrevealedUndercovers && unrevealedWhite == 0)
    {
      revealAll();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game over'),
            content: Text('victoire des undercovers'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //revealedRoles[-1] = null; // Force the map to re-render the views.
    final List<Widget> playerBoxes = widget.names.asMap().entries.map((entry) {
      final nameIndex = entry.key;
      final name = entry.value;
      final role = widget.roles[nameIndex];

      return InkWell(
        onTap: () {
          setState(() {
            if ( ! revealedRoles.containsValue(nameIndex))
            {
              if (role == 'w')
              {
                _mrWhiteGuessDialog(context);
                revealedRoles[nameIndex] = 'Mr. White';
              }

              if (role == 'u')
                revealedRoles[nameIndex] = 'undercover';
              if (role == 'c')
                revealedRoles[nameIndex] = 'civil';


              if (role != 'w')
                declareVictory();

            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                '$name',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                'Role: ${revealedRoles[nameIndex] ?? '[toujours en vie]'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(
        height: kToolbarHeight,
        onButtonPressed: () {
          int unrevealedCivilians = 0;
          int unrevealedUndercovers = 0;
          for (int i = 0; i < widget.roles.length; i++)
          {
            if (!revealedRoles.containsKey(i)) {
              if (widget.roles[i] == 'c')
                unrevealedCivilians++;
              else if (widget.roles[i] == 'u')
                unrevealedUndercovers++;
            }
          }
          double probabilityUndercover = 1 - 2 * unrevealedUndercovers / unrevealedCivilians;
          final Random _random = Random();
          bool isUndercover = _random.nextDouble() < probabilityUndercover;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NameSelection(
                numCivilians: (isUndercover ? 0 : 1),
                numUndercovers: (isUndercover ? 1 : 0),
                isLatePlayerAdd: true,
                latePlayerAddCallback: (name) {
                  widget.names.add(name);
                  widget.roles.add(isUndercover ? 'w' : 'c');
                  setState(() {});
                }
              ),
            ),
          );
        }
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: playerBoxes,
          ),
        ),
      ),
    );
  }

  void _mrWhiteGuessDialog(BuildContext context) {
    String guessWord = "toto";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Mr. White's Guess"),
          content: TextFormField(
            decoration: const InputDecoration(hintText: "Enter your guess"),
            onChanged: (value) {
              guessWord = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Submit"),
              onPressed: () {
                Navigator.of(context).pop();
                bool isCorrect = guessWord == widget.civilianWord;
                if (isCorrect)
                  revealAll();
                else
                  declareVictory();
                _displayGuessResult(context, isCorrect, widget.civilianWord, widget.undercoverWord);
              },
            ),
          ],
        );
      },
    );
  }

  void _displayGuessResult(BuildContext context, bool isCorrect, String civilianWord, String undercoverWord) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Guess Result"),
          content: Text(isCorrect ?
            "Félicitation ! Le mot des undercovers était $undercoverWord" :
            "Raté ! Le mot des civils était $civilianWord et celui des undercovers était $undercoverWord"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}

