import 'package:app_links/app_links.dart';
import 'package:bloc/bloc.dart';
import 'package:client/main.dart';
import 'package:client/pages/bloc/login_state.dart';
import 'package:client/service/auth_service.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState()) {
    _initDeepLinks();
  }

  late AppLinks _appLinks;

  AuthService authService = AuthService();

  Future<void> getUrl() async {
    emit(state.copyWith(status: loginStatus.loading, isLoading: true));
    var data = await authService.getUrl();
    emit(
      state.copyWith(
        status: loginStatus.success,
        isLoading: false,
        url: data['login_url'],
        sessionId: data['session_id'],
      ),
    );
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Listen untuk incoming links saat app sudah berjalan
    _appLinks.uriLinkStream.listen(
      (Uri uri) {
        print('=== DEEP LINK RECEIVED ===');
        print('URI: $uri');
        print('Scheme: ${uri.scheme}');
        print('Host: ${uri.host}');
        print('Path: ${uri.path}');
        print('Query: ${uri.query}');
        print('Query Parameters: ${uri.queryParameters}');

        _handleDeepLink(uri);
      },
      onError: (error) {
        print('Error handling deep link: $error');
        emit(
          state.copyWith(
            status: loginStatus.failure,
            errorMessage: 'Deep link error: $error',
            isLoading: false,
          ),
        );
      },
    );

    // Check untuk initial link saat app dibuka dari deep link
    _checkInitialLink();
  }

  void _checkInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('Initial deep link: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    print('=== PROCESSING DEEP LINK ===');

    // Cek apakah ini callback dari Keycloak
    if (uri.scheme == 'com.belajar.sso' &&
        (uri.host == 'login-callback' || uri.path.contains('login-callback'))) {
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      final currentSessionId = this.state.sessionId;

      print('Callback parameters:');
      print('- Code: $code');
      print('- State: $state');
      print('- Session ID: $currentSessionId');

      if (code != null && state != null && currentSessionId != null) {
        print('Processing callback...');
        _handleCallback(code, currentSessionId, state);
      } else {
        print('Missing callback parameters!');
        emit(
          this.state.copyWith(
            status: loginStatus.failure,
            errorMessage:
                'Missing callback parameters: code=$code, state=$state, sessionId=$currentSessionId',
            isLoading: false,
          ),
        );
      }
    } else {
      print('Unknown deep link: $uri');
    }
  }

  Future<void> _handleCallback(
    String code,
    String sessionId,
    String state,
  ) async {
    print('=== HANDLING CALLBACK ===');
    emit(this.state.copyWith(status: loginStatus.loading, isLoading: true));

    try {
      print('Calling authService.handleCallback...');
      final authSession = await authService.handleCallback(
        code,
        sessionId,
        state,
      );

      print('Callback successful, saving tokens...');
      await storage.write(key: 'auth_token', value: authSession.accessToken);
      await storage.write(key: 'session_id', value: authSession.sessionId);

      print('Authentication successful!');
      emit(
        this.state.copyWith(
          status: loginStatus.authenticated,
          token: authSession.accessToken,
          sessionId: authSession.sessionId,
          isLoading: false,
        ),
      );
    } catch (e) {
      print('Error in handleCallback: $e');
      emit(
        this.state.copyWith(
          status: loginStatus.failure,
          isLoading: false,
          errorMessage: 'Callback failed: $e',
        ),
      );
    }
  }
}
