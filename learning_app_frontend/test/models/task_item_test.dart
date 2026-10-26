import 'package:flutter_test/flutter_test.dart';
import 'package:learning_app_frontend/models/task_item.dart';

void main() {
  test('TaskItem reads API fields and serializes writable fields', () {
    final task = TaskItem.fromJson({
      'id': 12,
      'title': 'Plan release',
      'description': 'Check the build',
      'completed': true,
      'created_at': '2025-03-04T10:11:12Z',
      'updated_at': '2025-03-05T13:14:15Z',
    });

    expect(task.id, 12);
    expect(task.title, 'Plan release');
    expect(task.description, 'Check the build');
    expect(task.completed, isTrue);
    expect(task.createdAt, DateTime.utc(2025, 3, 4, 10, 11, 12));
    expect(task.updatedAt, DateTime.utc(2025, 3, 5, 13, 14, 15));
    expect(task.toJson(), {
      'title': 'Plan release',
      'description': 'Check the build',
      'completed': true,
    });
  });
}
