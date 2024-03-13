import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balloon Popper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Balloon Popper',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int balloonsPopped = 0;
  int balloonsMissed = 0;
  int secondsRemaining = 120;
  late Timer timer;
  List<Balloon> balloons = [];

  @override
  void initState() {
    super.initState();
    startTimer();
    generateBalloons();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          t.cancel();
          endGame();
        }
      });
    });
  }

  void endGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EndScreen(
          finalScore: balloonsPopped * 2 - balloonsMissed,
        ),
      ),
    );
  }

  void generateBalloons() {
    addBalloon(balloons); // Start the recursive process
  }

  void addBalloon(balloon) {
    if (secondsRemaining <= 0) return;
    balloon = Balloon(
      onPopped: () {
        setState(() {
          balloonsPopped++;
        });
        removeBalloon(balloon); // Pass the balloon to be removed
      },
      onMissed: () {
        setState(() {
          balloonsMissed++;
        });
        removeBalloon(balloon); // Pass the balloon to be removed
      },
    );
    setState(() {
      balloons.add(balloon);
    });
    Timer(const Duration(seconds: 3), () => addBalloon(balloon)); // Recursive call after 3 seconds
  }

  void removeBalloon(Balloon balloonToRemove) {
    setState(() {
      balloons.remove(balloonToRemove);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balloon Popper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Time: ${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(secondsRemaining % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Balloons Popped: $balloonsPopped',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Balloons Missed: $balloonsMissed',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Stack(
                children: balloons,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EndScreen extends StatelessWidget {
  final int finalScore;

  const EndScreen({Key? key, required this.finalScore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balloon Popper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Final Score: $finalScore',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class Balloon extends StatefulWidget {
  final VoidCallback onPopped;
  final VoidCallback onMissed;

  const Balloon({Key? key, required this.onPopped, required this.onMissed})
      : super(key: key);

  @override
  _BalloonState createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> {
  double bottom = 0;
  late double left;
  bool popped = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    left = Random().nextDouble() * 300;
    startFalling();
  }

  void startFalling() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (Timer t) {
      setState(() {
        if (bottom < 600 && !popped) {
          bottom += 5;
        } else {
          t.cancel();
          if (!popped) {
            widget.onMissed();
          }
          resetBalloon(); // Reset the balloon state
        }
      });
    });
  }

  void resetBalloon() {
    setState(() {
      bottom = 0;
      left = Random().nextDouble() * 300;
      popped = false;
    });
    startFalling(); // Restart the falling animation
  }

  @override
  Widget build(BuildContext context) {
    return popped
        ? SizedBox() // Return an empty SizedBox if balloon is popped
        : AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            bottom: bottom,
            left: left,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  popped = true;
                });
                widget.onPopped();
                timer?.cancel(); // Stop the timer when the balloon is popped
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
  }
}