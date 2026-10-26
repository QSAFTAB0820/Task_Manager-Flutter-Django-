import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_app_frontend/main.dart';
import 'package:learning_app_frontend/models/task_item.dart';
import 'package:learning_app_frontend/screens/login_screen.dart';
import 'package:learning_app_frontend/screens/tasks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LearningApp restores an empty session to the login screen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const LearningApp());
    await tester.pumpAndSettle();

    expect(find.text('Learning Tasks'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    expect(find.text('Need an account? Register'), findsOneWidget);
  });

  testWidgets('login form validates required fields and trims the username',
      (tester) async {
    String? submittedUsername;
    String? submittedPassword;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          loading: false,
          onLogin: (username, password) async {
            submittedUsername = username;
            submittedPassword = password;
          },
          onRegister: (_, __, ___) async {},
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a username'), findsOneWidget);
    expect(find.text('Enter a password'), findsOneWidget);
    expect(submittedUsername, isNull);

    await tester.enterText(find.byType(TextFormField).at(0), '  sam  ');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle();

    expect(submittedUsername, 'sam');
    expect(submittedPassword, 'secret');
  });

  testWidgets('registration mode shows email and enforces the password length',
      (tester) async {
    var registered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          loading: false,
          onLogin: (_, __) async {},
          onRegister: (_, __, ___) async {
            registered = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Need an account? Register'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(3));

    await tester.enterText(find.byType(TextFormField).at(0), 'sam');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'sam@example.test');
    await tester.enterText(find.byType(TextFormField).at(2), 'short');
    await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Use at least 6 characters'), findsOneWidget);
    expect(registered, isFalse);
  });

  testWidgets('task dialog rejects an empty title and submits trimmed fields',
      (tester) async {
    String? createdTitle;
    String? createdDescription;

    await tester.pumpWidget(
      MaterialApp(
        home: TasksScreen(
          username: 'sam',
          tasks: const [],
          loading: false,
          onRefresh: () async {},
          onLogout: () async {},
          onCreateTask: (title, description) async {
            createdTitle = title;
            createdDescription = description;
          },
          onToggleTask: (_) async {},
          onDeleteTask: (_) async {},
        ),
      ),
    );

    await tester.tap(find.text('New Task'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Create Task'), findsOneWidget);
    expect(createdTitle, isNull);

    await tester.enterText(find.byType(TextField).at(0), '  Buy milk  ');
    await tester.enterText(find.byType(TextField).at(1), '  Oat milk  ');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(createdTitle, 'Buy milk');
    expect(createdDescription, 'Oat milk');
  });

  testWidgets('task controls report the selected task to their callbacks',
      (tester) async {
    final task = TaskItem(
      id: 7,
      title: 'Review release',
      description: 'Check deployment notes',
      completed: false,
      createdAt: DateTime.utc(2025, 1, 1),
      updatedAt: DateTime.utc(2025, 1, 2),
    );
    TaskItem? toggledTask;
    TaskItem? deletedTask;

    await tester.pumpWidget(
      MaterialApp(
        home: TasksScreen(
          username: 'sam',
          tasks: [task],
          loading: false,
          onRefresh: () async {},
          onLogout: () async {},
          onCreateTask: (_, __) async {},
          onToggleTask: (value) async => toggledTask = value,
          onDeleteTask: (value) async => deletedTask = value,
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(toggledTask, same(task));
    expect(deletedTask, same(task));
  });
}
