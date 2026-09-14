import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../services/supabase_service.dart';

enum AuthStatus {
  unknown,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.message,
    this.requiresConfirmation = false,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  const AuthState.unauthenticated({
    String? message,
    bool requiresConfirmation = false,
  }) : this(
          status: AuthStatus.unauthenticated,
          message: message,
          requiresConfirmation: requiresConfirmation,
        );

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.authenticated(AppUser user)
      : this(
          status: AuthStatus.authenticated,
          user: user,
        );

  const AuthState.error(String message)
      : this(
          status: AuthStatus.error,
          message: message,
        );

  final AuthStatus status;
  final AppUser? user;
  final String? message;
  final bool requiresConfirmation;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._service) : super(const AuthState.unknown()) {
    initialize();
  }

  final SupabaseService _service;
  bool _initializationStarted = false;

  Future<void> initialize() async {
    if (_initializationStarted) {
      return;
    }
    _initializationStarted = true;

    try {
      final user = await _service.getCurrentUser();
      if (!mounted) {
        return;
      }
      state = user == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(user);
    } on AppAuthException catch (error) {
      if (mounted) {
        state = AuthState.error(error.message);
      }
    } catch (_) {
      if (mounted) {
        state = const AuthState.error(
          'تعذر استعادة جلسة الدخول. يرجى المحاولة مرة أخرى.',
        );
      }
    }
  }

  Future<void> signUp({
    required String identifier,
    required String password,
    required UserRole role,
    required bool isAutoEntrepreneur,
    String? phone,
  }) async {
    state = const AuthState.loading();
    try {
      final result = await _service.signUp(
        identifier: identifier,
        password: password,
        role: role,
        isAutoEntrepreneur: isAutoEntrepreneur,
          phone: phone,
      );

      if (!mounted) {
        return;
      }
      state = result.hasSession
          ? AuthState.authenticated(result.user)
          : AuthState.unauthenticated(
              message: 'تم إنشاء الحساب. تحقق من بياناتك لإكمال التسجيل.',
              requiresConfirmation: result.requiresConfirmation,
            );
    } on AppAuthException catch (error) {
      if (mounted) {
        state = AuthState.error(error.message);
      }
    } catch (_) {
      if (mounted) {
        state = const AuthState.error(
          'تعذر إنشاء الحساب. يرجى المحاولة مرة أخرى.',
        );
      }
    }
  }

  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _service.signIn(
        identifier: identifier,
        password: password,
      );
      if (mounted) {
        state = AuthState.authenticated(user);
      }
    } on AppAuthException catch (error) {
      if (mounted) {
        state = AuthState.error(error.message);
      }
    } catch (_) {
      if (mounted) {
        state = const AuthState.error(
          'تعذر تسجيل الدخول. يرجى المحاولة مرة أخرى.',
        );
      }
    }
  }

  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _service.signOut();
      if (mounted) {
        state = const AuthState.unauthenticated();
      }
    } on AppAuthException catch (error) {
      if (mounted) {
        state = AuthState.error(error.message);
      }
    } catch (_) {
      if (mounted) {
        state = const AuthState.error(
          'تعذر تسجيل الخروج. يرجى المحاولة مرة أخرى.',
        );
      }
    }
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(
    Supabase.instance.client,
    // Keep this false in production. Set it true only for local UI work while
    // the profiles table is being created.
    enableMockPartnerFallback: false,
  );
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(supabaseServiceProvider));
});