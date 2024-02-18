# Undercover

This repo is a simple android app that implements the "undercover" role-playing game.

## The rules

Undercover is a funny game for 5-10 players.
The players are grouped into three teams:
* Civilians. A majority of players are civilians.
* Undercovers. A small minority of players are undercover.
* One player is chosen to be Mr. White.

The app assigns a certain word to each civilian and a different word to each undercover.
No word is assigned to Mr. White.
A non-Mr. White player has initially no way to know whether he is civilian or undercover.
The words assigned to civilians and undercovers are different but related (e.g., bath / shower).
The game is a succession of rounds.
During each round, each player chooses a word and declares it publicly.
The second part of each round consists of a vote in which one player is eliminated.
The goal of Mr. White is to guess civilian's word.
For civilians, the point is choosing a word that convinces other civilians that they are in the same team,
in order to eliminate non-civilians, without letting Mr. White guess their word.
For undercover players, the point is deceive civilians in order remain alive and eventually outnumber civilians.

## Getting Started with Flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## TODO

This version of the app is quite early.
Much remain to be done:
* cleaning up the code, adding comments.
* adding proper multi-language support. The app currently contains a mixture of french and english.
* a better way for players to register their names in the app.
