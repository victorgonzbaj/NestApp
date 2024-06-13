import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/group.dart';
import '../models/event.dart';
import '../models/member.dart';
import '../models/notice.dart';
import '../models/reminder.dart';
import '../utils/Refresh.dart';
import '../utils/idGenerator.dart';
import 'CreateReminderScreen.dart';
import 'EditReminderScreen.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  late List<Event> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedEvents = _getEventsForDay(_selectedDay);
    refreshData().then((_) {
      setState(() {}); // Refresh UI after data is updated
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return Group.currentGroup?.eventList.where((event) {
      return isSameDay(event.date, day);
    }).toList() ?? [];
  }

  Set<DateTime> _getMarkedDays() {
    return Group.currentGroup?.eventList.where((event) {
      return !event.finished;
    }).map((event) => DateTime(event.date.year, event.date.month, event.date.day)).toSet() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Calendario'),
            Tab(text: 'Todas las Tareas'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              refreshData().then((_) {
                setState(() {}); // Refresh UI after data is updated
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(),
          _buildAllTasksTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateReminderScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _selectedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _selectedEvents = _getEventsForDay(selectedDay);
            });
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (_getMarkedDays().contains(DateTime(date.year, date.month, date.day))) {
                return Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange,
                  ),
                );
              }
              return Container();
            },
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(child: _buildEventList()),
      ],
    );
  }

  Widget _buildEventList() {
    if (_selectedEvents.isEmpty) {
      return Center(
        child: Text('Hoy no hay tareas'),
      );
    }

    return ListView.builder(
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedEvents[index];
        return ListTile(
          title: Text(event.name),
          subtitle: Text(event.desc),
          leading: Icon(
            event.finished ? Icons.check_circle : Icons.pending,
            color: event.finished ? Colors.green : Colors.red,
          ),
          onTap: event.finished ? null : () => _confirmMarkAsCompleted(event),
        );
      },
    );
  }

  Widget _buildAllTasksTab() {
    final reminders = Group.currentGroup?.reminderList ?? [];
    return ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return ListTile(
          title: Text(reminder.name),
          subtitle: Text(reminder.desc ?? ''),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDeleteReminder(reminder),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditReminderScreen(reminder: reminder),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmMarkAsCompleted(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Marcar como terminada'),
          content: Text('¿Deseas marcar esta tarea como terminada?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Marcar como terminada y actualizar en Firestore
      setState(() {
        event.finished = true;
      });
      await Group.currentGroup?.addGroupToFirestore();
      setState(() {
        _selectedEvents = _getEventsForDay(_selectedDay); // Actualizar lista de eventos del día seleccionado
      });

      // Crear notificaciones
      String authorName = Member.currentMember!.name;
      Notice memberNotice = Notice(
        id: generateID(),
        authorUID: Member.currentMember!.userUID,
        date: DateTime.now(),
        involvedUIDs: [Member.currentMember!.userUID],
        actionType: 'task_completed',
        message: '$authorName ha marcado como terminada la tarea ${event.name}',
      );
      Member.currentMember?.noticeList.add(memberNotice);
      await Member.currentMember?.addToFirestore();

      Notice groupNotice = Notice(
        id: generateID(),
        authorUID: Member.currentMember!.userUID,
        date: DateTime.now(),
        involvedUIDs: [Member.currentMember!.userUID],
        actionType: 'task_completed',
        message: '$authorName ha marcado como terminada la tarea ${event.name}',
      );
      await Group.currentGroup?.addNoticeToFirestore(groupNotice);

      // Mensaje de depuración
      print('Tarea marcada como terminada: ${event.name}');
    }
  }

  Future<void> _confirmDeleteReminder(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Recordatorio'),
          content: Text('¿Estás seguro de que deseas eliminar este recordatorio?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        Group.currentGroup?.removeReminder(reminder);
        Group.currentGroup?.addGroupToFirestore();
      });
    }
  }
}
