import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server/tools/api_response_helper.dart';

import 'login.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getToken(context),
    HttpMethod.post => await _refreshToken(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Response _getToken(RequestContext context) {
  final sessionId = context.request.headers['session_id'];

  if (sessionId == null) {
    // return Response.json(
    //   body: {'error': 'Session ID is required'},
    //   statusCode: HttpStatus.badRequest,
    // );
    return errorResponse(
      message: 'Session ID is required',
      statusCode: HttpStatus.badRequest,
      details: 'Please provide a valid session ID.',
    );
  }

  final session = sessions[sessionId];

  if (session == null) {
    // return Response.json(
    //   body: {'error': 'Invalid session ID'},
    //   statusCode: HttpStatus.unauthorized,
    // );
    return errorResponse(
      message: 'Invalid session ID',
      statusCode: HttpStatus.unauthorized,
      details: 'Please login again.',
    );
  }

  if (session.accessToken == null) {
    // return Response.json(
    //   body: {'error': 'Access token not found'},
    //   statusCode: HttpStatus.unauthorized,
    // );
    return errorResponse(
      message: 'Access token not found',
      statusCode: HttpStatus.unauthorized,
      details: 'Please login again to obtain a valid access token.',
    );
  }

  if (session.TokenExpiry == null ||
      DateTime.now().isAfter(session.TokenExpiry!)) {
    return errorResponse(
      message: 'Token expired or invalid',
      statusCode: HttpStatus.unauthorized,
      details: 'Please refresh your token or login again.',
    );
    // return Response.json(
    //   body: {'error': 'Token expired or invalid'},
    //   statusCode: HttpStatus.unauthorized,
    // );
  }

  return successResponse(
    message: 'Token retrieved successfully',
    data: {
      'access_token': session.accessToken,
      'token_type': 'Bearer',
      'expires_in': session.TokenExpiry?.toIso8601String(),
      'session_id': session.sessionId,
    },
  );
}

Future<Response> _refreshToken(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final sessionId = body['session_id'] as String?;

    if (sessionId == null) {
      // return Response.json(
      //   body: {'error': 'Session ID is required'},
      //   statusCode: HttpStatus.badRequest,
      // );
      return errorResponse(
        message: 'Session ID is required',
        statusCode: HttpStatus.badRequest,
        details: 'Please provide a valid session ID.',
      );
    }

    final session = sessions[sessionId];

    if (session == null || session.refreshToken == null) {
      // return Response.json(
      //   body: {'error': 'Invalid session or no refresh token'},
      //   statusCode: HttpStatus.unauthorized,
      // );
      return errorResponse(
        message: 'Invalid session or no refresh token',
        statusCode: HttpStatus.unauthorized,
        details: 'Please login again.',
      );
    }

    // return Response.json(
    //   body: {
    //     'success': true,
    //     'message': 'Token refreshed successfully',
    //   },
    // );
    return successResponse(
      message: 'Token refreshed successfully',
    );
  } catch (e) {
    // return Response.json(
    //   body: {'error': 'Failed to refresh token: $e'},
    //   statusCode: HttpStatus.internalServerError,
    // );
    return errorResponse(
      message: 'Failed to refresh token: $e',
      statusCode: HttpStatus.internalServerError,
      details: 'An error occurred while refreshing the token.',
    );
  }
}
