import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatefulWidget {
  const PomodoroApp({Key? key}) : super(key: key);

  @override
  _PomodoroAppState createState() => _PomodoroAppState();
}

class _PomodoroAppState extends State<PomodoroApp> {
  int workDuration = 1 * 60; // 25 minutes in seconds
  int breakDuration = 1 * 60; // 5 minutes in seconds
  int currentDuration = 1 * 60; // Start with work duration
  bool isWorking = true; // Indicates if it's work or break time
  bool isRunning = false; // Indicates if the timer is running
  late Timer _timer;
  late AudioPlayer _audioPlayer;

  Color primaryColor = Colors.red; // Color for work session
  Color secondaryColor = Colors.blue; // Color for break session

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  void playSound() async {
    await _audioPlayer.setAsset('assets/alarm.wav');
    _audioPlayer.play();
  }

  void startTimer() {
    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (currentDuration > 0) {
          currentDuration--;
        } else {
          playSound();
          isWorking = !isWorking;
          currentDuration = isWorking ? workDuration : breakDuration;
          primaryColor = isWorking ? Colors.white : Colors.blue;
          secondaryColor = isWorking ? Colors.blue : Colors.green;
        }
      });
    });
  }

  void pauseTimer() {
    setState(() {
      isRunning = false;
    });
    _timer.cancel();
  }

  void resetTimer() {
    setState(() {
      _timer.cancel();
      isRunning = false;
      currentDuration = workDuration;
      isWorking = true;
      primaryColor = Color(0xfff47a72);
      secondaryColor = Colors.blue;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Pomodoro Timer'),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formatTime(currentDuration),
                  style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: currentDuration /
                      (isWorking ? workDuration : breakDuration),
                  minHeight: 10,
                  backgroundColor: Color(0xfff11313),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isRunning ? null : startTimer,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      child: const Text('Start'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: !isRunning ? null : pauseTimer,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor),
                      child: const Text('Pause'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: resetTimer,
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
