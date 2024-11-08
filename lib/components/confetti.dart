import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:pamfurred/components/globals.dart';

class ConfettiDisplay extends StatefulWidget {
  final Duration duration;
  final bool shouldLoop;

  const ConfettiDisplay({
    super.key,
    this.duration = const Duration(seconds: 2),
    this.shouldLoop = false,
  });

  @override
  ConfettiDisplayState createState() => ConfettiDisplayState();
}

class ConfettiDisplayState extends State<ConfettiDisplay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: widget.duration);
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      numberOfParticles: 250,
      maximumSize: const Size(20, 10),
      confettiController: _confettiController,
      blastDirectionality: BlastDirectionality.explosive, // Explosive effect
      shouldLoop: false,
      colors: const [
        Colors.yellow,
        Colors.red,
        primaryColor,
        secondaryColor,
        lighterSecondaryColor,
        lightRedColor
      ],
      maxBlastForce: 100, // Increase blast force for more explosion
      minBlastForce: 10, // Minimum blast force
      gravity: 0.5, // Control how quickly confetti falls
      child: Container(), // Placeholder for the widget
    );
  }
}
