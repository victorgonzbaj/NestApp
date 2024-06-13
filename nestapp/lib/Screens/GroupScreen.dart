import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/notice.dart';
import '../utils/Refresh.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> with SingleTickerProviderStateMixin {
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
    String groupName = Group.currentGroup?.name ?? 'Nombre del Grupo';
    String groupDescription = Group.currentGroup?.desc ?? 'Descripción del Grupo';

    return Scaffold(
      appBar: AppBar(
        title: Text('Grupo'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  groupDescription,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Chat'),
              Tab(text: 'Noticias del Grupo'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatTab(),
                _buildGroupNoticesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Center(
      child: Text(
        'Aquí va un chat',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildGroupNoticesTab() {
    List<Notice> groupNotices = Group.currentGroup?.noticeList ?? [];
    groupNotices.sort((a, b) => b.date.compareTo(a.date)); // Ordenar de más reciente a más antiguo

    if (groupNotices.isEmpty) {
      return Center(child: Text('No hay noticias del grupo.'));
    }

    return ListView.builder(
      itemCount: groupNotices.length,
      itemBuilder: (context, index) {
        final notice = groupNotices[index];
        return ListTile(
          title: Text(notice.message),
          subtitle: Text(notice.date.toString()),
        );
      },
    );
  }
}
