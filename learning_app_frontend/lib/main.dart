import 'package:flutter/material.dart';

import 'models/task_item.dart';
import 'screens/login_screen.dart';
import 'screens/tasks_screen.dart';
import 'services/api_service.dart';
import 'services/auth_storage.dart';

void main() {
  runApp(const LearningApp());
}

class LearningApp extends StatelessWidget {
  const LearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF31553B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _apiService = ApiService();
  final _authStorage = AuthStorage();

  String? _token;
  String? _username;
  List<TaskItem> _tasks = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await _authStorage.readToken();
    final username = await _authStorage.readUsername();

    if (!mounted) {
      return;
    }

    setState(() {
      _token = token;
      _username = username;
      _loading = false;
    });

    if (token != null && token.isNotEmpty) {
      await _loadTasks(showSuccess: false);
    }
  }

  Future<void> _login(String username, String password) async {
    setState(() => _loading = true);
    final result = await _apiService.login(username: username, password: password);

    if (!mounted) {
      return;
    }

    if (!result.success || result.data == null) {
      setState(() => _loading = false);
      _showSnackBar(result.message);
      return;
    }

    await _authStorage.saveSession(token: result.data!.token, username: result.data!.username);

    setState(() {
      _token = result.data!.token;
      _username = result.data!.username;
    });

    _showSnackBar(result.message);
    await _loadTasks(showSuccess: false);
  }

  Future<void> _register(String username, String email, String password) async {
    setState(() => _loading = true);
    final result = await _apiService.register(
      username: username,
      email: email,
      password: password,
    );

    if (!mounted) {
      return;
    }

    setState(() => _loading = false);
    _showSnackBar(result.message);
  }

  Future<void> _loadTasks({bool showSuccess = true}) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);
    final result = await _apiService.fetchTasks(token);

    if (!mounted) {
      return;
    }

    if (!result.success) {
      setState(() => _loading = false);
      _showSnackBar(result.message);
      return;
    }

    setState(() {
      _tasks = result.data ?? const [];
      _loading = false;
    });

    if (showSuccess) {
      _showSnackBar(result.message);
    }
  }

  Future<void> _createTask(String title, String description) async {
    final token = _token;
    if (token == null) {
      return;
    }

    setState(() => _loading = true);
    final result = await _apiService.createTask(token, title: title, description: description);

    if (!mounted) {
      return;
    }

    _showSnackBar(result.message);
    await _loadTasks(showSuccess: false);
  }

  Future<void> _toggleTask(TaskItem task) async {
    final token = _token;
    if (token == null) {
      return;
    }

    setState(() => _loading = true);
    final result = await _apiService.updateTask(
      token,
      TaskItem(
        id: task.id,
        title: task.title,
        description: task.description,
        completed: !task.completed,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      ),
    );

    if (!mounted) {
      return;
    }

    _showSnackBar(result.message);
    await _loadTasks(showSuccess: false);
  }

  Future<void> _deleteTask(TaskItem task) async {
    final token = _token;
    if (token == null) {
      return;
    }

    setState(() => _loading = true);
    final result = await _apiService.deleteTask(token, task.id);

    if (!mounted) {
      return;
    }

    _showSnackBar(result.message);
    await _loadTasks(showSuccess: false);
  }

  Future<void> _logout() async {
    await _authStorage.clearSession();
    if (!mounted) {
      return;
    }

    setState(() {
      _token = null;
      _username = null;
      _tasks = const [];
      _loading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null || _token!.isEmpty) {
      return LoginScreen(
        onLogin: _login,
        onRegister: _register,
        loading: _loading,
      );
    }

    return TasksScreen(
      username: _username ?? 'Learner',
      tasks: _tasks,
      loading: _loading,
      onRefresh: () => _loadTasks(),
      onLogout: _logout,
      onCreateTask: _createTask,
      onToggleTask: _toggleTask,
      onDeleteTask: _deleteTask,
    );
  }
}
