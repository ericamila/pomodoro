import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:pomodoro/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class SettingsScreen extends StatefulWidget {
  final int workTime;
  final int breakTime;
  final Duration durationWorkTime = const Duration(minutes: 25);
  final Duration durationBreakTime = const Duration(minutes: 5);

  SettingsScreen({super.key, required this.workTime, required this.breakTime});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _workTimeController;
  late TextEditingController _breakTimeController;
  String? _selectedRingtoneUri;
  List<Map<String, String>> _ringtones = [];
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _workTimeController =
        TextEditingController(text: (widget.workTime ~/ 60).toString());
    _breakTimeController =
        TextEditingController(text: (widget.breakTime ~/ 60).toString());
    _loadRingtones();
    _loadSettings();
  }

  Future<void> _loadRingtones() async {
    try {
      final List<dynamic> ringtones =
          await platform.invokeMethod('getRingtones');
      setState(() {
        _ringtones = List<Map<String, String>>.from(
            ringtones.map((ringtone) => Map<String, String>.from(ringtone)));
      });
    } on PlatformException catch (e) {
      print("Failed to load ringtones: '${e.message}'.");
    }
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedRingtoneUri = prefs.getString('notificationSoundUri');
    });
  }

  void _playRingtone(String uri) async {
    player.stop();
    await player.setUrl(uri);
    player.play();
  }

  @override
  void dispose() {
    _workTimeController.dispose();
    _breakTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(title: Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(children: <Widget>[
          Text('Tempo de trabalho (minutos)'),
          Semantics(
            label: 'Tempo de trabalho (minutos)',
            child: textFild(controller: _workTimeController),
          ),
          SizedBox(height: 20),
          Text('Tempo de pausa (minutos)'),
          Semantics(
            label: 'Tempo de pausa (minutos)',
            child:
                textFild(controller: _breakTimeController, exemple: 'ex.: 05'),
          ),
          SizedBox(height: 20),
          Text('Som de Notificação'),
          DropdownButtonFormField<String>(
            value: _selectedRingtoneUri,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            hint: const Text('Selecionar Som de Notificação'),
            onChanged: (value) {
              setState(() {
                _selectedRingtoneUri = value!;
                _playRingtone(value);
              });
            },
            items: _ringtones.map((ringtone) {
              return DropdownMenuItem<String>(
                alignment: Alignment.center,
                value: ringtone['uri'],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note,
                      color: AppColor.carvao,
                    ),
                    Text(ringtone['title']!),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _save,
            child: Text('SALVAR'),
          ),
        ]),
      ),
    );
  }

  _save() {
    int newWorkTime = int.parse(_workTimeController.text) * 60;
    int newBreakTime = int.parse(_breakTimeController.text) * 60;
    Navigator.pop(context, {
      'workTime': newWorkTime,
      'breakTime': newBreakTime,
      'notificationSoundUri': _selectedRingtoneUri,
    });
  }

  CupertinoTextField textFild({
    required TextEditingController? controller,
    String exemple = 'ex.: 25',
  }) {
    return CupertinoTextField(
      padding: EdgeInsets.all(10),
      controller: controller,
      placeholder: exemple,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
    );
  }
}
