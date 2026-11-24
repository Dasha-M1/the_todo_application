import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late double _deviceHeight;
  String? _content;
  Box? _box;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.1,
        title: const Text("Daily Planner"),
      ),
      body: _tasksWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayTaskPopup,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Opens the Hive box asynchronously and loads the list
  Widget _tasksWidget() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _todoList();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  // Renders each saved task as a ListTile
  Widget _todoList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = Task.fromMap(tasks[index]);
        return ListTile(
          title: Text(
            task.todo,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(task.timestamp.toString()),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank,
            color: task.done ? Colors.green : null,
          ),
          // Tap to toggle done/undone
          onTap: () {
            task.done = !task.done;
            _box!.putAt(index, task.toMap());
            setState(() {});
          },
          // Long-press to delete task
          onLongPress: () {
            _box!.deleteAt(index);
            setState(() {});
          },
        );
      },
    );
  }

  // Popup dialog to add a new task
  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a Todo"),
          content: TextField(
            autofocus: true,
            onChanged: (value) {
              setState(() {
                _content = value;
              });
            },
            onSubmitted: (value) {
              if (_content != null && _content!.trim().isNotEmpty) {
                var task = Task(
                  todo: _content!.trim(),
                  timestamp: DateTime.now(),
                  done: false,
                );
                _box!.add(task.toMap());
                setState(() {
                  _content = null;
                });
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }
}
