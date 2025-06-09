// File: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/session.dart';

/// Service to handle user login, signup, and tokens.
class AuthService {
  // Singleton instance
  static final AuthService instance = AuthService._internal();

  AuthService._internal();

  // Base URL of your backend auth API
  static const String _baseUrl = 'https://api.yourapp.com/auth';

  /// Attempts to log in a user with [email] and [password].
  /// Returns a [Session] on success, throws on failure.
  Future<Session> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final session = Session.fromJson(data);
      return session;
    } else {
      throw AuthException('Login failed: ${response.body}');
    }
  }

  /// Registers a new user with [email], [password], and optional [name].
  /// Returns a [User] on success, throws on failure.
  Future<User> signup({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw AuthException('Signup failed: ${response.body}');
    }
  }

  /// Logs the current user out by invalidating the session on the server.
  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw AuthException('Logout failed: ${response.body}');
    }
  }

  /// Fetches the current session info using [token].
  /// Returns a [Session] if valid, or throws if invalid/expired.
  Future<Session> getSession(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/session'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body));
    } else {
      throw AuthException('Session retrieval failed: ${response.body}');
    }
  }
}

/// Thrown when an auth operation (login/signup/logout/session) fails.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
