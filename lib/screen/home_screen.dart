import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:piano_tiles/provider/game_state.dart';
import 'package:piano_tiles/provider/mission_provider.dart';

import '../model/node_model.dart';
import 'widgets/line.dart';
import 'widgets/line_divider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Note> notes = mission();
  final AudioPlayer player = AudioPlayer();
  late AnimationController animationController;
  int currentNoteIndex = 0;
  int points = 0;
  bool hasStarted = false;
  bool isPlaying = true;
  late NoteState state;
  int time = 5000;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        if (notes[currentNoteIndex].state != NoteState.tapped) {
          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          animationController.reverse().then((_) => _showFinishDialog());
        } else if (currentNoteIndex >= notes.length - 5) {
          _showFinishDialog();
        } else {
          setState(() => currentNoteIndex++);
          animationController.forward(from: 0);
        }
      }
    });

    animationController.forward(from: -1);
  }

  void _onTap(Note note) {
    bool areAllPreviousTapped = notes
        .sublist(0, note.orderNumber)
        .every((n) => n.state == NoteState.tapped);

    if (areAllPreviousTapped) {
      if (!hasStarted) {
        setState(() => hasStarted = true);
        animationController.forward();
      }
      _playNote(note);
      setState(() {
        note.state = NoteState.tapped;
        points++;

        if (points == 10) {
          animationController.duration = const Duration(milliseconds: 700);
        } else if (points == 15) {
          animationController.duration = const Duration(milliseconds: 500);
        } else if (points == 30) {
          animationController.duration = const Duration(milliseconds: 400);
        }
      });
    }
  }

  Widget _drawPoints() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Text(
          "$points",
          style: const TextStyle(color: Colors.red, fontSize: 60),
        ),
      ),
    );
  }

  Widget _drawLine(int lineNumber) {
    return Expanded(
      child: Line(
        lineNumber: lineNumber,
        currentNotes: notes.sublist(
            currentNoteIndex,
            currentNoteIndex + 5 > notes.length
                ? notes.length
                : currentNoteIndex + 5),
        animation: animationController,
        onTileTap: _onTap,
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    player.dispose();
    super.dispose();
  }

  void _restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;
      notes = mission();
      points = 0;
      currentNoteIndex = 0;
      animationController.duration = const Duration(milliseconds: 1000);
    });
    animationController.reset();
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: InkWell(
            onTap: () => Navigator.pop(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(150)),
                  ),
                  child: const Icon(Icons.play_arrow, size: 50),
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(150)),
                  ),
                  child: Text(
                    "Score: $points",
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 10),
                // _startWidget(),
              ],
            ),
          ),
        );
      },
    ).then((_) => _restart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              "assets/background.gif",
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: <Widget>[
              _drawLine(0),
              LineDivider(),
              _drawLine(1),
              LineDivider(),
              _drawLine(2),
              LineDivider(),
              _drawLine(3)
            ],
          ),
          _drawPoints(),
          _drawCompleteTile(),
        ],
      ),
    );
  }

  void _playNote(Note note) async {
    String audioFile;
    switch (note.line) {
      case 0:
        audioFile = 'a.wav';
        break;
      case 1:
        audioFile = 'c.wav';
        break;
      case 2:
        audioFile = 'e.wav';
        break;
      case 3:
        audioFile = 'f.wav';
        break;
      default:
        return;
    }
    await player.play(AssetSource(audioFile));
  }

  Widget _drawCompleteTile() {
    return Positioned(
      top: 25,
      right: 50,
      left: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _tileWidget(Icons.star,
              color: points >= 10 ? Colors.deepOrange : Colors.green[200]!),
          _tileHorizontalLine(
              points >= 10 ? Colors.deepOrange : Colors.deepOrange[200]!),
          _tileWidget(Icons.star,
              color: points >= 30 ? Colors.deepOrange : Colors.green[200]!),
        ],
      ),
    );
  }

  Widget _tileWidget(IconData icon, {required Color color}) {
    return Icon(icon, color: color);
  }

  Widget _tileHorizontalLine(Color color) {
    return Container(width: 80, height: 4, color: color);
  }
}
