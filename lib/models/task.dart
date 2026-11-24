class Task {
  String todo;
  DateTime timestamp;
  bool done;

  Task({required this.todo, required this.timestamp, required this.done});

  // Converts a Task object into a Map so Hive can store it
  Map<String, dynamic> toMap() {
    return {'todo': todo, 'timestamp': timestamp, 'done': done};
  }

  // Converts a stored Map from Hive back into a Task object
  factory Task.fromMap(Map task) {
    return Task(
      todo: task['todo'],
      timestamp: task['timestamp'],
      done: task['done'],
    );
  }
}
