import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Response successResponse({
  String message = 'OK',
  dynamic data,
  int statusCode = HttpStatus.ok,
}) {
  return Response.json(
    statusCode: statusCode,
    body: {
      'success': true,
      'message': message,
      'data': data,
      'error': null,
    },
    headers: {'Content-Type': 'application/json'},
  );
}

Response errorResponse({
  String message = 'Error',
  int statusCode = HttpStatus.badRequest,
  dynamic details,
}) {
  return Response.json(
    statusCode: statusCode,
    body: {
      'success': false,
      'message': message,
      'data': null,
      'error': {
        'code': statusCode,
        'details': details,
      },
    },
    headers: {'Content-Type': 'application/json'},
  );
}
