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

  void _addTask() {
    String task = _taskController.text.trim();
    if (task.isNotEmpty) {
      setState(() {
        _tasks.add({'title': task, 'isDone': false});
        _taskController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Task List
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];

                  return Dismissible(
                    key: Key(task['title'] + index.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        _tasks.removeAt(index);
                      });

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
