import 'package:client/pages/bloc/login_cubit.dart';
import 'package:client/pages/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main(List<String> args) {
  // This is the entry point of the Flutter application.
  // You can initialize your app here, set up dependencies, or run any startup logic.

  // For example, you might want to run the app with a specific widget:
  runApp(MyApp());
}

final storage = FlutterSecureStorage();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = LoginCubit();
        return cubit;
      },
      child: MaterialApp(title: 'SSO Login Example', home: const LoginPage()),
    );
  }
}
