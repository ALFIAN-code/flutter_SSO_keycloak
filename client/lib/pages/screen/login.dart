import 'package:client/pages/bloc/login_cubit.dart';
import 'package:client/pages/bloc/login_state.dart';
import 'package:client/pages/screen/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Auto-load URL saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginCubit>().getUrl();
    });
  }

  Future<void> launch(String url) async {
    try {
      print('Launching URL: $url');
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('URL launched successfully');
      } else {
        throw 'Cannot launch URL: $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open browser: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSO Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LoginCubit>().getUrl();
            },
          ),
        ],
      ),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          print('=== STATE CHANGE ===');
          print('Status: ${state.status}');
          print('Loading: ${state.isLoading}');
          print('Error: ${state.errorMessage}');

          if (state.status == loginStatus.authenticated) {
            print('Authentication successful! Navigating to homepage...');

            // Ensure navigation happens after current build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Homepage()),
              );
            });
          } else if (state.status == loginStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${state.errorMessage ?? "Unknown error"}',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<LoginCubit>().getUrl();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height - 100,
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.security, size: 80, color: Colors.blue),
                      const SizedBox(height: 20),
                      const Text(
                        'Single Sign-On Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Show error message
                      if (state.status == loginStatus.failure &&
                          state.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red.shade600),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Login button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(250, 50),
                          backgroundColor: state.url != null
                              ? Colors.blue
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: state.url != null
                            ? () {
                                launch(state.url!);
                              }
                            : null,
                        icon: const Icon(Icons.login),
                        label: Text(
                          state.url != null ? 'Login with SSO' : 'Loading...',
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Get URL button if URL is null
                      if (state.url == null &&
                          state.status != loginStatus.loading)
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<LoginCubit>().getUrl();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Get Login URL'),
                        ),

                      const SizedBox(height: 30),

                      // Debug information
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Debug Info:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Status: ${state.status}'),
                            if (state.sessionId != null)
                              Text('Session ID: ${state.sessionId}'),
                            if (state.url != null)
                              const Text(
                                'URL Ready: ✓',
                                style: TextStyle(color: Colors.green),
                              )
                            else
                              const Text(
                                'URL: Not loaded',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
