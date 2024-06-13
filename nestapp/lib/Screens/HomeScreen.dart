import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../models/notice.dart';
import '../models/event.dart';
import '../utils/Refresh.dart';
import '../utils/idGenerator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    refreshData().then((_) {
      setState(() {}); // Refresh UI after data is updated
    });
  }

  @override
  Widget build(BuildContext context) {
    String welcomeMessage = 'Bienvenido ${Member.currentMember?.name ?? ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              welcomeMessage,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Tareas Pendientes'),
              Tab(text: 'Noticias'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTasksTab(),
                _buildNoticesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticesTab() {
    List<Notice> notices = Member.currentMember?.noticeList ?? [];
    notices.sort((a, b) => b.date.compareTo(a.date)); // Ordenar de más reciente a más antiguo

    if (notices.isEmpty) {
      return Center(child: Text('No hay noticias.'));
    }

    return ListView.builder(
      itemCount: notices.length,
      itemBuilder: (context, index) {
        final notice = notices[index];
        return ListTile(
          title: Text(notice.message),
          subtitle: Text(notice.date.toString()),
        );
      },
    );
  }

  Widget _buildPendingTasksTab() {
    DateTime today = DateTime.now();
    List<Event> pendingTasks = Group.currentGroup?.eventList.where((event) {
      return !event.finished && event.date.isBefore(today);
    }).toList() ?? [];

    if (pendingTasks.isEmpty) {
      return Center(child: Text('No hay tareas pendientes.'));
    }

    return ListView.builder(
      itemCount: pendingTasks.length,
      itemBuilder: (context, index) {
        final task = pendingTasks[index];
        return ListTile(
          title: Text(task.name),
          subtitle: Text(task.date.toString()),
          leading: Icon(Icons.pending, color: Colors.red),
          onTap: () => _confirmMarkAsCompleted(task),
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
        // Refrescar la lista de tareas pendientes
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
    }
  }
}
