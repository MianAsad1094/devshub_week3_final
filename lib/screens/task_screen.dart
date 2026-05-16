import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON encode/decode k liye

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // Ab hum sirf String ki jagah Map (key-value pair) use kr rhy hain
  List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // SharedPreferences se tasks load krna
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('saved_tasks');

    if (tasksString != null) {
      // JSON string ko wapis List m convert krna
      final List<dynamic> decodedTasks = json.decode(tasksString);
      setState(() {
        _tasks = decodedTasks.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  // Tasks ko SharedPreferences m save krna
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    // List ko JSON string m convert kr k save krna
    final String tasksString = json.encode(_tasks);
    await prefs.setString('saved_tasks', tasksString);
  }

  // Naya task add krna
  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;

    setState(() {
      _tasks.add({
        'title': _taskController.text.trim(),
        'isDone': false, // By default task complete nahi hota
      });
      _taskController.clear();
    });
    _saveTasks();
  }

  // Task ko Complete/Incomplete mark krna
  void _toggleTaskStatus(int index, bool? value) {
    setState(() {
      _tasks[index]['isDone'] = value ?? false;
    });
    _saveTasks();
  }

  // Task delete krna
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  // Task add krne k liye chota sa popup (Dialog)
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: _taskController,
            decoration: const InputDecoration(hintText: 'e.g. Complete Flutter project'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addTask();
                Navigator.pop(context); // Dialog close krnay k liye
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: _showAddTaskDialog, // Custom Action Button
            tooltip: 'Add Task',
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.checklist, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text('No tasks yet. Tap the + icon to add one!',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              // Checkbox for Marking Complete
              leading: Checkbox(
                value: task['isDone'],
                activeColor: Colors.blueAccent,
                onChanged: (value) => _toggleTaskStatus(index, value),
              ),
              title: Text(
                task['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  // Agar task done hy to us pe line lga dain (Strikethrough)
                  decoration: task['isDone'] ? TextDecoration.lineThrough : null,
                  color: task['isDone'] ? Colors.grey : Colors.black,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteTask(index),
              ),
            ),
          );
        },
      ),
      // Floating Action Button as a secondary way to add task
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}