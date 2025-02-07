import 'package:flutter/material.dart';
import 'package:piano_tiles/model/node_model.dart';
import 'package:piano_tiles/screen/widgets/tile_widget.dart';

class Line extends AnimatedWidget {
  final int lineNumber;
  final List<Note> currentNotes;
  final Function(Note) onTileTap;

  const Line({
    super.key,
    required this.lineNumber,
    required this.currentNotes,
    required Animation<double> animation,
    required this.onTileTap,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;

    // Mendapatkan tinggi layar
    double height = MediaQuery.of(context).size.height;
    double tileHeight = height / 4;

    // Ambil hanya notes yang ada di garis ini
    List<Note> thisLineNotes =
        currentNotes.where((note) => note.line == lineNumber).toList();

    // Ubah notes menjadi widget
    List<Widget> tiles = thisLineNotes.map((note) {
      // Tentukan jarak note dari atas
      int index = currentNotes.indexWhere((n) => n.orderNumber == note.orderNumber);
      double offset = (3 - index + animation.value) * tileHeight;

      return Transform.translate(
        offset: Offset(0, offset),
        child: Tile(
          height: tileHeight,
          state: note.state,
          onTapDown: () => onTileTap(note),
          index: note.orderNumber,
        ),
      );
    }).toList();

    return SizedBox.expand(
      child: Stack(
        children: tiles,
      ),
    );
  }
}
