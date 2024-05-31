import 'package:flutter/material.dart';
import 'package:pomodoro/screens/splash.dart';
import 'package:pomodoro/theme.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro',
      theme: theme,
      home: const Splash(),
    );
  }
}

