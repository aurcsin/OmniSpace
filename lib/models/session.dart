// File: lib/models/session.dart

/// A session model holding auth tokens and expiry information.
class Session {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  Session({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Create a Session from API JSON.
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  /// Convert Session into JSON, typically for storing or refreshing.
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
