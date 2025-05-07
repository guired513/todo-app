import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: ToDoHome(),
    );
  }
}

class ToDoHome extends StatefulWidget {
  @override
  ToDoHomeState createState() => ToDoHomeState();
}

class ToDoHomeState extends State<ToDoHome> {
  final TextEditingController _taskController = TextEditingController();
  List<Map<String, dynamic>> _tasks = [];

  String _filter = 'all'; // Possible values: all, active, completed

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _addTask() {
    String task = _taskController.text.trim();
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add({'title': task, 'isDone': false});
        _taskController.clear();
      });
      _saveTasks(); // hook to save task
    }
  }

  // Save tasks to shared_preferences
  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskStrings =
        _tasks.map((task) => jsonEncode(task)).toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  // Load tasks from shared_preferences
  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskStrings = prefs.getStringList('tasks');

    if (taskStrings != null) {
      setState(() {
        _tasks = taskStrings
            .map((taskString) => jsonDecode(taskString) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTasks = _tasks.where((task) {
      if (_filter == 'all') return true;
      if (_filter == 'active') return task['isDone'] == false;
      if (_filter == 'completed') return task['isDone'] == true;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: 'Enter a task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                  label: Text('All'),
                  selected: _filter == 'all',
                  onSelected: (_) {
                    setState(() => _filter = 'all');
                  },
                ),
                FilterChip(
                  label: Text('Active'),
                  selected: _filter == 'active',
                  onSelected: (_) {
                    setState(() => _filter = 'active');
                  },
                ),
                FilterChip(
                  label: Text('Completed'),
                  selected: _filter == 'completed',
                  onSelected: (_) {
                    setState(() => _filter = 'completed');
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

             
            // Task List
            Expanded(
              child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No tasks to show!',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
              
              : ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];

                  return Dismissible(
                    key: Key(task['title'] + index.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        _tasks.removeAt(index);
                      });
                      _saveTasks(); // hook to save task

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Task deleted')),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      child: CheckboxListTile(
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            decoration:
                                task['isDone'] ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        value: task['isDone'],
                        onChanged: (bool? value) {
                          setState(() {
                            task['isDone'] = value!;
                          });
                          _saveTasks(); // hook to save task
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
