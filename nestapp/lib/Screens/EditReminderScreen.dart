import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/group.dart';
import '../models/notice.dart';
import '../models/member.dart';
import '../models/repeatInterval.dart';
import '../utils/idGenerator.dart';

class EditReminderScreen extends StatefulWidget {
  final Reminder reminder;

  EditReminderScreen({required this.reminder});

  @override
  _EditReminderScreenState createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late bool _autofinish;
  late bool _repeat;
  late DateTime _firstDate;
  late RepeatIntervalType _repeatIntervalType;
  late int _intervalValue;
  late List<bool> _daysOfTheWeek;
  late List<bool> _daysOfTheMonth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.reminder.name);
    _descController = TextEditingController(text: widget.reminder.desc);
    _autofinish = widget.reminder.autofinish;
    _repeat = widget.reminder.repeat;
    _firstDate = widget.reminder.firstDate;
    _repeatIntervalType = widget.reminder.repeatInterval?.type ?? RepeatIntervalType.eachXDays;
    _intervalValue = widget.reminder.repeatInterval?.dayInterval ?? 1;
    _daysOfTheWeek = widget.reminder.repeatInterval?.daysOfTheWeek ?? List<bool>.filled(7, false);
    _daysOfTheMonth = widget.reminder.repeatInterval?.daysOfTheMonth ?? List<bool>.filled(31, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Recordatorio'),
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
                onPressed: _updateReminder,
                child: Text('Actualizar'),
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

  Future<void> _updateReminder() async {
    widget.reminder.name = _nameController.text;
    widget.reminder.desc = _descController.text;
    widget.reminder.autofinish = _autofinish;
    widget.reminder.repeat = _repeat;
    widget.reminder.firstDate = _firstDate;
    widget.reminder.repeatInterval = _repeat
        ? RepeatInterval(
      type: _repeatIntervalType,
      dayInterval: _repeatIntervalType == RepeatIntervalType.eachXDays ? _intervalValue : null,
      daysOfTheWeek: _repeatIntervalType == RepeatIntervalType.eachXDayOfTheWeek ? _daysOfTheWeek : null,
      daysOfTheMonth: _repeatIntervalType == RepeatIntervalType.eachXDayOfTheMonth ? _daysOfTheMonth : null,
    )
        : null;

    await Group.currentGroup?.addReminder(widget.reminder);
    await Group.currentGroup?.generateEvents();

    _createNotice('ha modificado la tarea ${widget.reminder.name}');

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
