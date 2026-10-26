import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learning_app_frontend/services/api_service.dart';

void main() {
  test('login posts credentials to the auth endpoint and parses the session',
      () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
          request.url.toString(), 'https://api.example.test/api/auth/login/');
      expect(jsonDecode(request.body), {
        'username': 'sam',
        'password': 'test-password',
      });

      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Login successful.',
          'data': {
            'access': 'test-token',
            'user': {'username': 'sam'},
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    addTearDown(client.close);
    final api =
        ApiService(baseUrl: 'https://api.example.test/api', client: client);

    final result = await api.login(username: 'sam', password: 'test-password');

    expect(result.success, isTrue);
    expect(result.data?.token, 'test-token');
    expect(result.data?.username, 'sam');
  });

  test('task fetch sends the bearer token and parses task data', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), 'https://api.example.test/api/tasks/');
      expect(request.headers['authorization'], 'Bearer test-token');

      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Tasks loaded.',
          'data': {
            'tasks': [
              {
                'id': 3,
                'title': 'Write tests',
                'description': 'Use a mock API',
                'completed': false,
                'created_at': '2025-03-04T10:11:12Z',
                'updated_at': '2025-03-05T13:14:15Z',
              },
            ],
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    addTearDown(client.close);
    final api =
        ApiService(baseUrl: 'https://api.example.test/api', client: client);

    final result = await api.fetchTasks('test-token');

    expect(result.success, isTrue);
    expect(result.data, hasLength(1));
    expect(result.data!.single.title, 'Write tests');
    expect(result.data!.single.completed, isFalse);
  });
}
