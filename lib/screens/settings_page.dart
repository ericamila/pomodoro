import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _workTimeController = TextEditingController(
      text: (widget.workTime ~/ 60).toString(),
    );
    _breakTimeController = TextEditingController(
      text: (widget.breakTime ~/ 60).toString(),
    );
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
          Text('Tempo de intervalo (minutos)'),
          Semantics(
            label: 'Tempo de intervalo (minutos)',
            child:
                textFild(controller: _breakTimeController, exemple: 'ex.: 05'),
          ),
          SizedBox(height: 20),
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
