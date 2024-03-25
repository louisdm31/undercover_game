// This is the game over view, that reveals the winning team, the teams and their words.

import 'package:flutter/material.dart';
import 'database_helper.dart';

class GameOverScreen extends StatefulWidget {
  final List<String> names;
  final List<String> roles;
  final String civilianWord;
  final String undercoverWord;
  final String whiteWord;
  final String winner;
  final List<bool> survived;

  const GameOverScreen({
    Key? key,
    required this.names,
    required this.roles,
    required this.survived,
    required this.civilianWord,
    required this.undercoverWord,
    required this.whiteWord,
    required this.winner,
  }) : super(key: key);

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

// This widget corresponds to a team.
// It displays the list of the players in the team, the corresponding word (for Mr. White, it displays its guess).
// A crown icon is added to the winning team.
class TwoStringsWidget extends StatelessWidget {
  final String label1;
  final String label2;
  final bool winner;

  const TwoStringsWidget({
    Key? key,
    required this.label1,
    required this.label2,
    required this.winner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget crown;
    if (winner)
      crown = Container(
        height: 200,
        width: 70,
        child: Image.asset('assets/crown.png'),
      );
    else
      crown = Container(
        height: 200,
        width: 70,
      );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        crown,
        Expanded(
          child: Text(label1,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ),
        Expanded(
          child: Text(
            label2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}


class _GameOverScreenState extends State<GameOverScreen> {
  @override
  Widget build(BuildContext context) {

    List<bool> winningPlayers = <bool>[];
    for (int i = 0; i < widget.roles.length; i++)
        winningPlayers.add((widget.roles[i] == 'w' && widget.winner == 'w') || (widget.survived[i] && widget.roles[i] == widget.winner));

    final db = DatabaseHelper();
    db.insertResults(widget.civilianWord, widget.undercoverWord, widget.whiteWord, widget.names, widget.roles, winningPlayers);

    String title = 'Nobody wins';
    if (widget.winner == 'w')
      title = 'The winner is Mr. White';
    else if (widget.winner == 'c')
      title = 'Civilians win';
    else if (widget.winner == 'u')
      title = 'Undercovers win';

    String civilianNames = '';
    String undercoverNames = '';
    String whiteName = '';
    for (int i = 0; i < widget.roles.length; i++)
    {
      if (widget.roles[i] == 'c')
        civilianNames += widget.names[i] + ', ';
      else if (widget.roles[i] == 'u')
        undercoverNames += widget.names[i] + ', ';
      else if (widget.roles[i] == 'w')
        whiteName = widget.names[i];
    }
    civilianNames = civilianNames.substring(0, civilianNames.length - 2);
    undercoverNames = undercoverNames.substring(0, undercoverNames.length - 2);

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TwoStringsWidget(
                label1: 'Civilian word:\n"' + widget.civilianWord + '"',
                label2: civilianNames,
                winner: widget.winner == 'c',
              ),
              TwoStringsWidget(
                label1: 'Undercover word:\n"' + widget.undercoverWord + '"',
                label2: undercoverNames,
                winner: widget.winner == 'u',
              ),
              TwoStringsWidget(
                label1: 'Mr. White\'s guess:\n"' + widget.whiteWord + '"',
                label2: whiteName,
                winner: widget.winner == 'w',
              ),
            ]
          ),
        ),
      ),
      onWillPop: () async {
        // If the back arrow is pressed, return to the home screen.
        Navigator.popUntil(context, ModalRoute.withName('/'));
        return false;
      },
    );
  }
}

