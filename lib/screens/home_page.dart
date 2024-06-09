import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:pomodoro/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int defaultWorkTime = 25 * 60; // 25 minutes in seconds
  static const int defaultBreakTime = 5 * 60; // 5 minutes in seconds

  late Timer _timer;
  late int _remainingTime;
  bool _isWorking = true;
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _workTime = defaultWorkTime;
  int _breakTime = defaultBreakTime;

  ///TODO
  String _text = 'Aperte o play para iniciar!';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _remainingTime = _workTime;
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _workTime = prefs.getInt('workTime') ?? defaultWorkTime;
      _breakTime = prefs.getInt('breakTime') ?? defaultBreakTime;
      _remainingTime = _isWorking ? _workTime : _breakTime;
    });
  }

  Future<void> _updatePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workTime', _workTime);
    await prefs.setInt('breakTime', _breakTime);
  }

  void _startTimer() {
    _text = _isWorking ? 'Contando...' : 'Intervalo';
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isWorking = !_isWorking;
          _remainingTime = _isWorking ? _workTime : _breakTime;
          _playSound();
        }
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _stopTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    setState(() {
      _isRunning = false;
      _text = 'Aperte o play para contiruar\nou reset para reiniciar!';
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingTime = _isWorking ? _workTime : _breakTime;
      _text = 'Aperte o play para iniciar!';
    });
  }

  void _playSound() async {
    await _audioPlayer.play(AssetSource('som.mp3'));
    await _audioPlayer.resume();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Image.asset('assets/tomate.png'),
        ),
        title: Text('POMODORO'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    workTime: _workTime,
                    breakTime: _breakTime,
                  ),
                ),
              );
              if (result != null) {
                setState(() {
                  _workTime = result['workTime'];
                  _breakTime = result['breakTime'];
                  _remainingTime = _isWorking ? _workTime : _breakTime;
                  _updatePreferences();
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/tomate.png'), opacity: 0.4)),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _text,
                        style: TextStyle(fontSize: 18, color: AppColor.carvao),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: 'Tempo restante: ${_formatTime(_remainingTime)}',
                        child: Text(
                          _formatTime(_remainingTime),
                          style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _remainingTime < 60
                                  ? AppColor.vermelho
                                  : AppColor.carvao),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: _isRunning ? _stopTimer : _startTimer,
                            child: Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              size: 40,
                              semanticLabel: 'play/pause',
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _resetTimer,
                            child: const Icon(
                              Icons.restart_alt_outlined,
                              size: 40,
                              semanticLabel: 'restart',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _audioPlayer.dispose();
    super.dispose();
  }
}
