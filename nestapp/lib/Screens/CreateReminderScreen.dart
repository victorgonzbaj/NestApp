import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/group.dart';
import '../models/notice.dart';
import '../models/member.dart';
import '../models/repeatInterval.dart';
import '../utils/idGenerator.dart';

class CreateReminderScreen extends StatefulWidget {
  @override
  _CreateReminderScreenState createState() => _CreateReminderScreenState();
}

class _CreateReminderScreenState extends State<CreateReminderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _autofinish = false;
  bool _repeat = false;
  DateTime _firstDate = DateTime.now();
  RepeatIntervalType _repeatIntervalType = RepeatIntervalType.eachXDays;
  int _intervalValue = 1;
  List<bool> _daysOfTheWeek = List<bool>.filled(7, false);
  List<bool> _daysOfTheMonth = List<bool>.filled(31, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Recordatorio'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              SwitchListTile(
                title: Text('Autofinalizable'),
                value: _autofinish,
                onChanged: (bool value) {
                  setState(() {
                    _autofinish = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Repetir'),
                value: _repeat,
                onChanged: (bool value) {
                  setState(() {
                    _repeat = value;
                  });
                },
              ),
              ListTile(
                title: Text('Primera Fecha'),
                subtitle: Text('${_firstDate.toLocal()}'.split(' ')[0]),
                onTap: _pickFirstDate,
              ),
              if (_repeat) _buildRepeatOptions(),
              ElevatedButton(
                onPressed: _createReminder,
                child: Text('Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatOptions() {
    return Column(
      children: [
        DropdownButton<RepeatIntervalType>(
          value: _repeatIntervalType,
          onChanged: (RepeatIntervalType? newValue) {
            setState(() {
              _repeatIntervalType = newValue!;
            });
          },
          items: RepeatIntervalType.values.map((RepeatIntervalType type) {
            return DropdownMenuItem<RepeatIntervalType>(
              value: type,
              child: Text(_getRepeatIntervalTypeName(type)),
            );
          }).toList(),
        ),
        if (_repeatIntervalType == RepeatIntervalType.eachXDays)
          TextField(
            decoration: InputDecoration(labelText: 'Intervalo (días)'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _intervalValue = int.parse(value);
            },
          ),
        if (_repeatIntervalType == RepeatIntervalType.eachXDayOfTheWeek)
          Column(
            children: List<Widget>.generate(7, (index) {
              return CheckboxListTile(
                title: Text(_getDayName(index)),
                value: _daysOfTheWeek[index],
                onChanged: (bool? value) {
                  setState(() {
                    _daysOfTheWeek[index] = value!;
                  });
                },
              );
            }),
          ),
        if (_repeatIntervalType == RepeatIntervalType.eachXDayOfTheMonth)
          Column(
            children: List<Widget>.generate(31, (index) {
              return CheckboxListTile(
                title: Text('Día ${index + 1}'),
                value: _daysOfTheMonth[index],
                onChanged: (bool? value) {
                  setState(() {
                    _daysOfTheMonth[index] = value!;
                  });
                },
              );
            }),
          ),
      ],
    );
  }

  Future<void> _pickFirstDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _firstDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _firstDate) {
      setState(() {
        _firstDate = picked;
      });
    }
  }

  Future<void> _createReminder() async {
    String id = generateID();
    Reminder reminder = Reminder(
      id: id,
      name: _nameController.text,
      desc: _descController.text,
      groupID: Group.currentGroup!.id,
      autofinish: _autofinish,
      repeat: _repeat,
      repeatInterval: _repeat
          ? RepeatInterval(
        type: _repeatIntervalType,
        dayInterval: _repeatIntervalType == RepeatIntervalType.eachXDays ? _intervalValue : null,
        daysOfTheWeek: _repeatIntervalType == RepeatIntervalType.eachXDayOfTheWeek ? _daysOfTheWeek : null,
        daysOfTheMonth: _repeatIntervalType == RepeatIntervalType.eachXDayOfTheMonth ? _daysOfTheMonth : null,
      )
          : null,
      firstDate: _firstDate,
    );

    await Group.currentGroup?.addReminder(reminder);
    await Group.currentGroup?.generateEvents();

    _createNotice('ha creado la tarea ${reminder.name}');

    Navigator.pop(context);
  }

  void _createNotice(String action) {
    String authorName = Member.currentMember!.name;
    Notice groupNotice = Notice(
      id: generateID(),
      authorUID: Member.currentMember!.userUID,
      date: DateTime.now(),
      involvedUIDs: Group.currentGroup!.memberList,
      actionType: 'reminder',
      message: '$authorName $action',
    );
    Group.currentGroup?.addNoticeToFirestore(groupNotice);

    Notice memberNotice = Notice(
      id: generateID(),
      authorUID: Member.currentMember!.userUID,
      date: DateTime.now(),
      involvedUIDs: [Member.currentMember!.userUID],
      actionType: 'reminder',
      message: '$authorName $action',
    );
    Member.currentMember?.addToFirestore();
  }

  String _getRepeatIntervalTypeName(RepeatIntervalType type) {
    switch (type) {
      case RepeatIntervalType.eachXDays:
        return 'Cada X días';
      case RepeatIntervalType.eachXDayOfTheWeek:
        return 'Cada X día de la semana';
      case RepeatIntervalType.eachXDayOfTheMonth:
        return 'Cada X día del mes';
      default:
        return '';
    }
  }

  String _getDayName(int index) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    return days[index];
  }
}
