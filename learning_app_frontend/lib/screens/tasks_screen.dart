import 'package:flutter/material.dart';

import '../models/task_item.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({
    super.key,
    required this.username,
    required this.tasks,
    required this.loading,
    required this.onRefresh,
    required this.onLogout,
    required this.onCreateTask,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  final String username;
  final List<TaskItem> tasks;
  final bool loading;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final Future<void> Function(String title, String description) onCreateTask;
  final Future<void> Function(TaskItem task) onToggleTask;
  final Future<void> Function(TaskItem task) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
        actions: [
          IconButton(
            onPressed: loading ? null : () { onRefresh(); },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: loading ? null : () { onLogout(); },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : () => _showTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF254336), Color(0xFF4C7B58)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Your tasks come straight from Django. Toggle, delete, or add one and watch the API logs update.',
                style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            if (loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ))
            else if (tasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text('No tasks yet. Create your first one to test the full stack flow.'),
              )
            else
              ...tasks.map(
                (task) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Checkbox(
                      value: task.completed,
                      onChanged: loading ? null : (_) { onToggleTask(task); },
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: task.description.isEmpty ? null : Text(task.description),
                    trailing: IconButton(
                      onPressed: loading ? null : () { onDeleteTask(task); },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTaskDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  return;
                }
                Navigator.of(context).pop();
                await onCreateTask(
                  titleController.text.trim(),
                  descriptionController.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
