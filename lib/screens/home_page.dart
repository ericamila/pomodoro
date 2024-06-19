import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:pomodoro/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';

const platform = MethodChannel('dev.ericamila.pomodoro/ringtones');

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const int defaultWorkTime = 25 * 60; // 25 minutes in seconds
  static const int defaultBreakTime = 5 * 60; // 5 minutes in seconds

  late Timer _timer;
  late int _remainingTime;
  bool _isWorking = true;
  bool _isRunning = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _workTime = defaultWorkTime;
  int _breakTime = defaultBreakTime;
  String? _notificationSoundUri;

  int feed = 1;
  late AnimationController _animacao;

  List<Map<String, String>> _ringtones = [];
  String? defaultSound; //

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _animacao =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _loadPreferences();
    _remainingTime = _workTime;
  }

  toggle() {
    _isRunning = !_isRunning;
    _isRunning ? _animacao.forward() : _animacao.reverse();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('notificationSoundUri') == null) {
      await _loadRingtones();
    }

    setState(() {
      _notificationSoundUri =
          prefs.getString('notificationSoundUri') ?? defaultSound;
      _workTime = prefs.getInt('workTime') ?? defaultWorkTime;
      _breakTime = prefs.getInt('breakTime') ?? defaultBreakTime;
      _remainingTime = _isWorking ? _workTime : _breakTime;
    });
  }

  Future<void> _loadRingtones() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final List<dynamic> ringtones =
          await platform.invokeMethod('getRingtones');
      setState(() {
        _ringtones = List<Map<String, String>>.from(
            ringtones.map((ringtone) => Map<String, String>.from(ringtone)));
        defaultSound = _ringtones.first['uri'];
      });
      await prefs.setString('notificationSoundUri', defaultSound!);
    } on PlatformException catch (e) {
      print("Failed to load ringtones: '${e.message}'.");
    }
  }

  Future<void> _updatePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workTime', _workTime);
    await prefs.setInt('breakTime', _breakTime);
    await prefs.setString('notificationSoundUri', _notificationSoundUri!);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        feed = _isWorking ? 2 : 3;
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _playSound();
          _isWorking = !_isWorking;
          _remainingTime = _isWorking ? _workTime : _breakTime;
        }
      });
    });
    toggle();
  }

  void _stopTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _isRunning = true;
    setState(() {
      toggle();
      feed = 4;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingTime = _isWorking ? _workTime : _breakTime;
      feed = 1;
    });
  }

  void _playSound() async {
    if (_notificationSoundUri != null) {
      await _audioPlayer.setUrl(_notificationSoundUri!);
      _audioPlayer.play();
    }
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
                  _notificationSoundUri = result['notificationSoundUri'];
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
            alignment: Alignment.center,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/tomate.png'), opacity: 0.4)),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    feedback(feed),
                    Column(
                      children: [
                        Text(
                          _formatTime(_remainingTime),
                          style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _remainingTime < 60
                                  ? AppColor.vermelho
                                  : AppColor.carvao),
                          semanticsLabel:
                              'Tempo restante: ${_formatTime(_remainingTime)}',
                        ),
                        IconButton(
                          padding: EdgeInsets.all(32),
                          onPressed: _isRunning ? _stopTimer : _startTimer,
                          icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              color: AppColor.vermelho,
                              progress: _animacao),
                          iconSize: 136,
                          tooltip: 'play/pause',
                        ),
                      ],
                    ),
                    Semantics(
                      label: 'restart',
                      child: TextButton(
                        onPressed: _resetTimer,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.restart_alt_outlined, size: 40),
                            const Text('Reiniciar'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget feedback(int opcao) {
    switch (opcao) {
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            texto('\nAperte o '),
            Icon(Icons.play_arrow),
            texto('\n para iniciar!'),
          ],
        );
      case 2:
        return texto('\nExecutando...');
      case 3:
        return texto('\nIntervalo');
      case 4:
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  texto('Aperte '),
                  Icon(Icons.play_arrow),
                  texto(' para continuar'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  texto('ou '),
                  Icon(Icons.restart_alt_outlined),
                  texto(' para reiniciar'),
                ],
              ),
            ]);
      default:
        return Text('');
    }
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

Text texto(String texto) {
  return Text(texto, style: TextStyle(fontSize: 18, color: AppColor.carvao));
}
