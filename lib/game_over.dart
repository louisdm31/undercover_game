import 'package:flutter/material.dart';

class GameOverScreen extends StatefulWidget {
  final List<String> names;
  final List<String> roles;
  final String civilianWord;
  final String undercoverWord;
  final String whiteWord;
  final String winner;

  const GameOverScreen({
    Key? key,
    required this.names,
    required this.roles,
    required this.civilianWord,
    required this.undercoverWord,
    required this.whiteWord,
    required this.winner,
  }) : super(key: key);

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

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
        height: 70,
        width: 70,
        child: Image.asset('assets/crown.png'),
      );
    else
      crown = Container(
        height: 70,
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

    String title = 'Tout le monde a perdu';
    if (widget.winner == 'w')
      title = 'Victoire de Mr. White';
    else if (widget.winner == 'c')
      title = 'Victoire des civils';
    else if (widget.winner == 'u')
      title = 'Victoire des undercover';

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
                label1: 'mot des civils:\n"' + widget.civilianWord + '"',
                label2: civilianNames,
                winner: widget.winner == 'c',
              ),
              TwoStringsWidget(
                label1: 'mot des imposteurs:\n"' + widget.undercoverWord + '"',
                label2: undercoverNames,
                winner: widget.winner == 'u',
              ),
              TwoStringsWidget(
                label1: 'proposition de Mr. White:\n"' + widget.whiteWord + '"',
                label2: whiteName,
                winner: widget.winner == 'w',
              ),
            ]
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        return false;
      },
    );
  }
}

