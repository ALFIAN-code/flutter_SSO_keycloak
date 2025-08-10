import 'package:equatable/equatable.dart';

enum loginStatus { initial, loading, success, failure, authenticated }

class LoginState extends Equatable {
  String? token;
  loginStatus status;
  String? errorMessage;
  String? url;
  String? sessionId;
  bool isLoading;

  LoginState({
    this.token,
    this.status = loginStatus.initial,
    this.errorMessage,
    this.isLoading = false,
    this.url,
    this.sessionId,
  });

  LoginState copyWith({
    String? token,
    loginStatus? status,
    String? errorMessage,
    bool? isLoading,
    String? url,
    String? sessionId,
  }) {
    return LoginState(
      token: token ?? this.token,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      url: url ?? this.url,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [
    token,
    status,
    errorMessage,
    isLoading,
    url,
    sessionId,
  ];
}
