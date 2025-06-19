// File: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/session.dart';
import 'secure_storage_service.dart';

/// A service for handling user authentication:
/// - login
/// - signup
/// - token/session management (with persistence)
class AuthService {
  // Singleton instance
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  // Base URL of your backend auth API
  static const String _baseUrl = 'https://api.yourapp.com/auth';

  /// Attempts to log in a user with [email] and [password].
  /// Returns a [Session] on success, stores token locally, throws on failure.
  Future<Session> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final session = Session.fromJson(data);
      // Persist token (rename to whatever your Session model field is)
      await SecureStorageService.instance.write(
        'auth_token',
        session.accessToken,
      );
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

  /// Logs the current user out by invalidating the session on the server
  /// and removing the stored token.
  Future<void> logout() async {
    final token = await SecureStorageService.instance.read('auth_token');
    if (token == null) {
      throw AuthException('No user is currently logged in.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      await SecureStorageService.instance.delete('auth_token');
    } else {
      throw AuthException('Logout failed: ${response.body}');
    }
  }

  /// Fetches the current session info using the stored token.
  /// Returns a [Session] if valid, or throws if invalid/expired.
  Future<Session> getSession() async {
    final token = await SecureStorageService.instance.read('auth_token');
    if (token == null) {
      throw AuthException('No token found. User not authenticated.');
    }

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

  /// Retrieves the locally stored auth token, or null if none.
  Future<String?> getToken() async {
    return SecureStorageService.instance.read('auth_token');
  }
}

/// Thrown when an auth operation fails.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
