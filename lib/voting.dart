// This is the view displayed when the game is ongoing.
// It displays the list of players.
// When a player is voted out, the interface reveal its role.
// In case the eliminated player is Mr. White, he has the opportunity to guess the word.

import 'package:flutter/material.dart';
import 'dart:math';
import 'names.dart';
import 'game_over.dart';

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

// This is the top bar of the view, with a button to add a player when the game is ongoing.
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
  String guessWord = '';

  @override
  void initState() {
    super.initState();

    // When the game starts, the app displays the player that starts each round.
    // A player is randomly picked, such that, with high probability, Mr. White is among the last players to play.
    // It has therefore the opportunity to listen to other player's words and make an educated guess of the civilian's word.
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
            title: Text('First player : $nameFirst'),
          );
        },
      );
    });
  }

  // Checks winning conditions for civilians and undercovers.
  void detectWinningTeam() {
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
    if (((unrevealedCivilians <= unrevealedUndercovers) || unrevealedUndercovers == 0) && unrevealedWhite == 0)
    {
      String winner;
      if (unrevealedCivilians == 0 && unrevealedUndercovers == 0)
        winner = 'n';   // Nobody wins. Mr. White has eliminated all players but failed to guess the word.
      else if (unrevealedUndercovers == 0)
        winner = 'c';
      else
        winner = 'u';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameOverScreen(
            names: widget.names,
            roles: widget.roles,
            civilianWord: widget.civilianWord,
            undercoverWord: widget.undercoverWord,
            whiteWord: guessWord,
            winner: winner,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    // constructs the list of boxes corresponding to each player.
    final List<Widget> playerBoxes = widget.names.asMap().entries.map((entry) {
      final nameIndex = entry.key;
      final name = entry.value;
      final role = widget.roles[nameIndex];

      return InkWell(
        onTap: () {
          setState(() {

            // This code is executed when a player is voted out.
            // Its role is revealed.
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
                revealedRoles[nameIndex] = 'civilian';


              if (role != 'w')
                detectWinningTeam();

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
                'Role: ${revealedRoles[nameIndex] ?? '[still alive]'}',
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
          
          // This code is executed when the user tries to add a player during the game.
          // The new player will be either civilian of undercover, according to a probability distribution constructed below.
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

          // Pushes the name selection view.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NameSelection(
                civilianWord: widget.civilianWord,
                undercoverWord: widget.undercoverWord,
                numCivilians: (isUndercover ? 0 : 1),
                numUndercovers: (isUndercover ? 1 : 0),
                isLatePlayerAdd: true,
                latePlayerAddCallback: (name) {

                  // Callback function that adds the new player to the voting screen view.
                  widget.names.add(name);
                  widget.roles.add(isUndercover ? 'u' : 'c');
                  setState(() {});
                }
              ),
            ),
          );
        }
      ),
      body: SingleChildScrollView(
        child: Column(
          children: playerBoxes,
        ),
      ),
    );
  }

  void _mrWhiteGuessDialog(BuildContext context) {
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
                if (guessWord.trim() == widget.civilianWord)
                {
                  // If successful, go to game over screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameOverScreen(
                        names: widget.names,
                        roles: widget.roles,
                        civilianWord: widget.civilianWord,
                        undercoverWord: widget.undercoverWord,
                        whiteWord: guessWord.trim(),
                        winner: 'w',
                      ),
                    ),
                  );
                }
                else   // Displays the two words to Mr. White.
                  _displayGuessResult(context, widget.civilianWord, widget.undercoverWord);
              },
            ),
          ],
        );
      },
    );
  }

  void _displayGuessResult(BuildContext context, String civilianWord, String undercoverWord) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Guess Result"),
          content: Text("You missed ! Civilian's word is $civilianWord and undercover's word is $undercoverWord"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                detectWinningTeam();   // Detect a victory of civilians and undercovers.
              },
            ),
          ],
        );
      },
    );
  }

}

