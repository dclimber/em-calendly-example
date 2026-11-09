import 'dart:convert';

import 'package:http/http.dart' as http;

/// The person behind a session. In this application, the user id is the employee id.
final class AuthUser {
  const AuthUser({required this.id, required this.email, required this.displayName});

  final String id;
  final String email;
  final String displayName;
}

final class AuthSession {
  const AuthSession({required this.accessToken, required this.refreshToken, required this.user});

  final String accessToken;
  final String refreshToken;
  final AuthUser user;
}

/// The identity provider refused the request. [message] is safe to show.
final class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

/// The corporate single sign-on port.
abstract interface class Authenticator {
  Future<AuthSession> signIn({required String email, required String password});

  Future<AuthSession> signUp({required String email, required String password, required String displayName});

  /// The user of a valid access token, or null.
  Future<AuthUser?> userFor(String accessToken);

  /// A new session for [refreshToken], or null when it is no longer valid.
  Future<AuthSession?> refresh(String refreshToken);

  Future<void> signOut(String accessToken);
}

/// [Authenticator] on Supabase Auth (GoTrue), with email and password.
final class SupabaseAuthenticator implements Authenticator {
  SupabaseAuthenticator({required Uri supabaseUrl, required String apiKey, http.Client? client})
    : _base = supabaseUrl.resolve('/auth/v1/'),
      _apiKey = apiKey,
      _client = client ?? http.Client();

  final Uri _base;
  final String _apiKey;
  final http.Client _client;

  Map<String, String> _headers([String? accessToken]) => {
    'apikey': _apiKey,
    'content-type': 'application/json',
    if (accessToken != null) 'authorization': 'Bearer $accessToken',
  };

  @override
  Future<AuthSession> signIn({required String email, required String password}) async {
    final response = await _client.post(
      _base.resolve('token?grant_type=password'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _session(response);
  }

  @override
  Future<AuthSession> signUp({required String email, required String password, required String displayName}) async {
    final response = await _client.post(
      _base.resolve('signup'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'data': {'display_name': displayName},
      }),
    );
    return _session(response);
  }

  @override
  Future<AuthUser?> userFor(String accessToken) async {
    final response = await _client.get(_base.resolve('user'), headers: _headers(accessToken));
    if (response.statusCode != 200) return null;
    return _user(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<AuthSession?> refresh(String refreshToken) async {
    final response = await _client.post(
      _base.resolve('token?grant_type=refresh_token'),
      headers: _headers(),
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    if (response.statusCode != 200) return null;
    return _session(response);
  }

  @override
  Future<void> signOut(String accessToken) async {
    await _client.post(_base.resolve('logout'), headers: _headers(accessToken));
  }

  AuthSession _session(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['access_token'] == null) {
      final message = body['msg'] ?? body['error_description'] ?? body['message'] ?? 'Sign-in failed.';
      throw AuthFailure('$message');
    }
    return AuthSession(
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String,
      user: _user(body['user'] as Map<String, dynamic>),
    );
  }

  static AuthUser _user(Map<String, dynamic> json) {
    final email = json['email'] as String;
    final metadata = (json['user_metadata'] as Map?) ?? const {};
    return AuthUser(id: json['id'] as String, email: email, displayName: '${metadata['display_name'] ?? email}');
  }
}
