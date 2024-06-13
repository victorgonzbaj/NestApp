import 'package:flutter/material.dart';
import 'package:nestapp/models/member.dart';
import 'package:nestapp/models/group.dart';
import 'package:nestapp/utils/idGenerator.dart';
import 'package:nestapp/models/expense.dart';
import 'package:nestapp/models/notice.dart';

class CreateExpenseScreen extends StatefulWidget {
  @override
  _CreateExpenseScreenState createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _payer;
  List<bool> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    _payer = Member.currentMember?.userUID;
    _selectedMembers = List<bool>.filled(Member.memberList.length, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Gasto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre del Gasto'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Importe'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _payer,
              onChanged: (String? newValue) {
                setState(() {
                  _payer = newValue;
                });
              },
              items: Member.memberList.map<DropdownMenuItem<String>>((Member member) {
                return DropdownMenuItem<String>(
                  value: member.userUID,
                  child: Text(member.name),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('Compartido con:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: Member.memberList.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(Member.memberList[index].name),
                    value: _selectedMembers[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedMembers[index] = value!;
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _createExpense,
              child: Text('Crear Gasto'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createExpense() async {
    String id = generateID();
    double amount = double.parse(_amountController.text);
    String payerUID = _payer!;
    List<String> sharedWithUIDs = [];
    for (int i = 0; i < _selectedMembers.length; i++) {
      if (_selectedMembers[i]) {
        sharedWithUIDs.add(Member.memberList[i].userUID);
      }
    }
    String expenseName = _nameController.text;

    Expense expense = Expense(
      id: id,
      amount: amount,
      payerUID: payerUID,
      sharedWithUIDs: sharedWithUIDs,
      expenseName: expenseName,
    );

    await Group.currentGroup?.addExpenseToFirestore(expense);

    // Crear notificaciones
    String authorName = Member.currentMember!.name;
    Notice memberNotice = Notice(
      id: generateID(),
      authorUID: payerUID,
      date: DateTime.now(),
      involvedUIDs: sharedWithUIDs,
      actionType: 'expense',
      message: 'Has realizado un nuevo gasto de $amount con el concepto $expenseName',
    );
    Member.currentMember?.noticeList.add(memberNotice);
    await Member.currentMember?.addToFirestore();

    Notice groupNotice = Notice(
      id: generateID(),
      authorUID: payerUID,
      date: DateTime.now(),
      involvedUIDs: sharedWithUIDs,
      actionType: 'expense',
      message: '$authorName ha hecho un gasto de $amount con el concepto $expenseName',
    );
    await Group.currentGroup?.addNoticeToFirestore(groupNotice);

    Navigator.pop(context);
  }
}
