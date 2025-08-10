import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server/tools/api_response_helper.dart';

import 'login.dart';

Response onRequest(RequestContext context) {
  return switch (context.request.method) {
    HttpMethod.post => _logout(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Response _logout(RequestContext context) {
  final sessionId = context.request.headers['session_id'];
  try {
    if (sessionId == null) {
      // return Response.json(
      //   body: {'error': 'Session ID is required'},
      //   statusCode: HttpStatus.badRequest,
      // );
      return errorResponse(
        message: 'Session ID is required',
        details: 'Please provide a valid session ID.',
      );
    }

    if (!sessions.containsKey(sessionId)) {
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

    sessions.remove(sessionId);

    // return Response.json(
    //   body: {'success': true, 'message': 'Logout successful'},
    //   headers: {'Content-Type': 'application/json'},
    // );
    return successResponse(
      message: 'Logout successful',
    );
  } catch (e) {
    return Response.json(
      body: {'error': 'Failed to logout: $e'},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
