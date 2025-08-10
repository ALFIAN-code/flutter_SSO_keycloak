import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server/tools/api_response_helper.dart';
// import 'package:server/tools/tools.dart';
import 'package:uuid/uuid.dart';

import 'package:http/http.dart' as ht;

import '../../secret.dart';

final Map<String, AuthSession> sessions = {};

class AuthSession {
  final String sessionId;
  // final String codeVerifier;
  final String state;
  String? accessToken;
  String? refreshToken;
  DateTime? TokenExpiry;

  AuthSession({
    required this.sessionId,
    // required this.codeVerifier,
    required this.state,
    this.accessToken,
    this.refreshToken,
    this.TokenExpiry,
  });

  Map<String, String?> toJson() {
    return {
      'session_id': sessionId,
      // 'code_verifier': codeVerifier,
      'state': state,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_expiry': TokenExpiry?.toIso8601String(),
    };
  }
}

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getLoginUrl(),
    HttpMethod.post => await _handleCallback(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Response _getLoginUrl() {
  final sessionId = const Uuid().v4();
  final state = const Uuid().v4();

  sessions[sessionId] = AuthSession(
    sessionId: sessionId,
    state: state,
  );

  final loginUrl = Uri.parse('$keycloakBaseUrl/auth').replace(
    queryParameters: {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'openid profile email',
      'state': state,
    },
  );

  return successResponse(
    message: 'Login URL generated successfully',
    data: {
      'session_id': sessionId,
      // 'code_verifier': codeVerifier,
      'login_url': loginUrl.toString(),
    },
  );
}

Future<Response> _handleCallback(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final sessionId = body['session_id'] as String?;
    final code = body['code'] as String?;
    final state = body['state'] as String?;

    if (sessionId == null || state == null) {
      // return Response.json(
      //   body: {'error': 'Missing required parameters'},
      //   statusCode: HttpStatus.badRequest,
      // );
      return errorResponse(
        message: 'Missing required parameters',
        statusCode: HttpStatus.badRequest,
        details: 'Please provide session_id and state.',
      );
    }

    final session = sessions[sessionId];
    if (session == null || state != session.state) {
      // return Response.json(
      //   body: {'error': 'Invalid session ID'},
      //   statusCode: HttpStatus.badRequest,
      // );
      return errorResponse(
        message: 'Invalid session ID or state',
        details: 'Please initiate the login process again.',
      );
    }

    final tokens = await _exchangeCodeForTokens(code!);

    session.accessToken = tokens['access_token'] as String?;
    session.refreshToken = tokens['refresh_token'] as String?;
    session.TokenExpiry = DateTime.now().add(
      Duration(seconds: tokens['expires_in'] as int),
    );

    return successResponse(
      message: 'Login successful',
      data: {
        'access_token': session.accessToken,
        'token_type': 'Bearer',
        'expires_in': session.TokenExpiry?.toIso8601String(),
        'session_id': session.sessionId,
      },
    );
  } catch (e) {
    return errorResponse(
      message: 'Failed to handle callback: $e',
      statusCode: HttpStatus.internalServerError,
      details: e.toString(),
    );
  }
}

// menukar kode otorisasi (authorization code) dari Keycloak dengan access token dan refresh token.
Future<Map<String, dynamic>> _exchangeCodeForTokens(
  String code,
) async {
  try {
    final response = await ht.post(Uri.parse('$keycloakBaseUrl/token'), body: {
      'grant_type': 'authorization_code',
      'client_id': clientId,
      'client_secret': secret,
      'code': code,
      'redirect_uri': redirectUri,
      // 'code_verifier': codeVerifier,
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to exchange code for tokens: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  } catch (e) {
    throw Exception('Error exchanging code for tokens: $e');
  }
}
