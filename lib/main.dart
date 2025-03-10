import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plan Manager',
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({required this.name, required this.description, required this.date, this.isCompleted = false});
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _addPlan(String name, String description, DateTime date) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date));
    });
  }

  void _updatePlan(Plan plan, String newName, String newDescription) {
    setState(() {
      plan.name = newName;
      plan.description = newDescription;
    });
  }

  void _markCompleted(Plan plan) {
    setState(() {
      plan.isCompleted = !plan.isCompleted;
    });
  }

  void _deletePlan(Plan plan) {
    setState(() {
      plans.remove(plan);
    });
  }

  void _showPlanDialog({Plan? plan}) {
    final TextEditingController nameController = TextEditingController(text: plan?.name ?? "");
    final TextEditingController descController = TextEditingController(text: plan?.description ?? "");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(plan == null ? "Create Plan" : "Edit Plan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Plan Name")),
              TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (plan == null) {
                  _addPlan(nameController.text, descController.text, _selectedDate);
                } else {
                  _updatePlan(plan, nameController.text, descController.text);
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Manager')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Slidable(
                  key: Key(plan.name),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _markCompleted(plan),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.check,
                        label: 'Complete',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _deletePlan(plan),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onLongPress: () => _showPlanDialog(plan: plan),
                    child: Card(
                      color: plan.isCompleted ? Colors.green[200] : Colors.white,
                      child: ListTile(
                        title: Text(plan.name, style: TextStyle(decoration: plan.isCompleted ? TextDecoration.lineThrough : null)),
                        subtitle: Text(plan.description),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
