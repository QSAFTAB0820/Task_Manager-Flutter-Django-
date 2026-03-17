import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task_item.dart';

class ApiResult<T> {
  const ApiResult({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final T? data;
}

class SessionData {
  const SessionData({required this.token, required this.username});

  final String token;
  final String username;
}

class ApiService {
  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? "http://127.0.0.1:8000/api";

  final String baseUrl;

  Future<ApiResult<void>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _post(
      '/auth/register/',
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    return ApiResult<void>(
      success: response['success'] as bool? ?? false,
      message: response['message'] as String? ?? 'Registration failed.',
    );
  }

  Future<ApiResult<SessionData>> login({
    required String username,
    required String password,
  }) async {
    final response = await _post(
      '/auth/login/',
      body: {
        'username': username,
        'password': password,
      },
    );

    final success = response['success'] as bool? ?? false;
    final data = response['data'] as Map<String, dynamic>?;
    final user = data?['user'] as Map<String, dynamic>?;

    if (!success || data == null || user == null) {
      return ApiResult<SessionData>(
        success: false,
        message: response['message'] as String? ?? 'Login failed.',
      );
    }

    return ApiResult<SessionData>(
      success: true,
      message: response['message'] as String? ?? 'Login successful.',
      data: SessionData(
        token: data['access'] as String? ?? '',
        username: user['username'] as String? ?? username,
      ),
    );
  }

  Future<ApiResult<List<TaskItem>>> fetchTasks(String token) async {
    final response = await _get('/tasks/', token: token);
    final success = response['success'] as bool? ?? false;
    final data = response['data'] as Map<String, dynamic>?;
    final rawTasks = data?['tasks'] as List<dynamic>? ?? const [];

    return ApiResult<List<TaskItem>>(
      success: success,
      message: response['message'] as String? ?? 'Unable to fetch tasks.',
      data: rawTasks
          .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResult<TaskItem>> createTask(
    String token, {
    required String title,
    required String description,
  }) async {
    final response = await _post(
      '/tasks/',
      token: token,
      body: {
        'title': title,
        'description': description,
        'completed': false,
      },
    );
    return _taskResult(response, 'Unable to create task.');
  }

  Future<ApiResult<TaskItem>> updateTask(String token, TaskItem task) async {
    final response = await _patch(
      '/tasks/${task.id}/',
      token: token,
      body: task.toJson(),
    );
    return _taskResult(response, 'Unable to update task.');
  }

  Future<ApiResult<void>> deleteTask(String token, int taskId) async {
    final response = await _delete('/tasks/$taskId/', token: token);
    return ApiResult<void>(
      success: response['success'] as bool? ?? false,
      message: response['message'] as String? ?? 'Unable to delete task.',
    );
  }

  Future<Map<String, dynamic>> _get(String path, {required String token}) async {
    final uri = Uri.parse('$baseUrl$path');
    _logRequest('GET', uri, headers: _headers(token));
    final response = await http.get(uri, headers: _headers(token));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    String? token,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = _headers(token);
    _logRequest('POST', uri, headers: headers, body: body);
    final response = await http.post(uri, headers: headers, body: jsonEncode(body));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _patch(
    String path, {
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = _headers(token);
    _logRequest('PATCH', uri, headers: headers, body: body);
    final response = await http.patch(uri, headers: headers, body: jsonEncode(body));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _delete(String path, {required String token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = _headers(token);
    _logRequest('DELETE', uri, headers: headers);
    final response = await http.delete(uri, headers: headers);
    return _decodeResponse(response);
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  void _logRequest(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    print('[HTTP Request] $method $uri');
    print('[HTTP Headers] $headers');
    if (body != null) {
      print('[HTTP Body] ${jsonEncode(body)}');
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    print('[HTTP Response] ${response.statusCode} ${response.request?.url}');
    print('[HTTP Response Body] ${response.body}');

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {
      'success': false,
      'message': 'Unexpected response format.',
      'data': null,
      'errors': null,
    };
  }

  ApiResult<TaskItem> _taskResult(Map<String, dynamic> response, String fallbackMessage) {
    final success = response['success'] as bool? ?? false;
    final data = response['data'] as Map<String, dynamic>?;
    final task = data?['task'] as Map<String, dynamic>?;

    return ApiResult<TaskItem>(
      success: success,
      message: response['message'] as String? ?? fallbackMessage,
      data: task == null ? null : TaskItem.fromJson(task),
    );
  }
}
