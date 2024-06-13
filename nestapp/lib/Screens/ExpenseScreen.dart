import 'package:flutter/material.dart';
import 'package:nestapp/models/expense.dart';
import 'package:nestapp/models/group.dart';
import 'package:nestapp/models/member.dart';
import 'package:nestapp/models/notice.dart';

import '../utils/Refresh.dart';
import 'CreateExpenseScreen.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> with SingleTickerProviderStateMixin {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshData().then((_) {
      setState(() {}); // Refresh UI after data is updated
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gastos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Balance'),
            Tab(text: 'Gastos'),
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
          _buildBalanceTab(),
          _buildExpensesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateExpenseScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBalanceTab() {
    double userBalance = _calculateUserBalance();
    Map<String, double> otherMembersBalance = _calculateOtherMembersBalance();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu Balance: ${userBalance.toStringAsFixed(2)} €',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Balance de otros miembros:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...otherMembersBalance.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${_getMemberName(entry.key)}: ${entry.value.toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExpensesTab() {
    return ListView.builder(
      itemCount: Group.currentGroup?.expenseList.length ?? 0,
      itemBuilder: (context, index) {
        Expense expense = Group.currentGroup!.expenseList[index];
        return ListTile(
          title: Text(expense.expenseName),
          subtitle: Text('Pagado por: ${_getMemberName(expense.payerUID)}'),
          trailing: Text('${expense.amount.toStringAsFixed(2)} €'),
          onTap: () => _showExpenseDialog(expense),
          leading: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteExpense(expense),
          ),
        );
      },
    );
  }

  String _getMemberName(String uid) {
    Member? member = Member.memberList.firstWhere((member) => member.userUID == uid, orElse: () => Member(userUID: '', name: 'Unknown', email: ''));
    return member.name ?? 'Unknown';
  }

  double _calculateUserBalance() {
    double balance = 0.0;
    Group.currentGroup?.expenseList.forEach((expense) {
      if (expense.payerUID == Member.currentMember!.userUID) {
        balance += expense.amount;
      }
      if (expense.sharedWithUIDs.contains(Member.currentMember!.userUID)) {
        balance -= expense.amount / expense.sharedWithUIDs.length;
      }
    });
    return balance;
  }

  Map<String, double> _calculateOtherMembersBalance() {
    Map<String, double> balances = {};
    Group.currentGroup?.memberList.forEach((uid) {
      if (uid != Member.currentMember!.userUID) {
        balances[uid] = 0.0;
      }
    });
    Group.currentGroup?.expenseList.forEach((expense) {
      if (balances.containsKey(expense.payerUID)) {
        balances[expense.payerUID] = (balances[expense.payerUID] ?? 0) + expense.amount;
      }
      expense.sharedWithUIDs.forEach((uid) {
        if (balances.containsKey(uid)) {
          balances[uid] = (balances[uid] ?? 0) - (expense.amount / expense.sharedWithUIDs.length);
        }
      });
    });
    return balances;
  }

  void _deleteExpense(Expense expense) {
    setState(() {
      Group.currentGroup?.expenseList.remove(expense);
      Group.currentGroup?.addGroupToFirestore();
    });
  }

  void _showExpenseDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Información del Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre: ${expense.expenseName}'),
              Text('Importe: ${expense.amount.toStringAsFixed(2)} €'),
              Text('Pagado por: ${_getMemberName(expense.payerUID)}'),
              Text('Compartido con:'),
              ...expense.sharedWithUIDs.map((uid) => Text(_getMemberName(uid))).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
