import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';

/// A safe, user-facing authentication error.
///
/// Raw Supabase exceptions are intentionally not exposed to the UI. They can
/// contain provider details that are useful for logs but are not suitable for
/// displaying to an end user.
class AppAuthException implements Exception {
  const AppAuthException(
    this.message, {
    this.code,
    this.cause,
  });

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult({
    required this.user,
    required this.hasSession,
    this.requiresConfirmation = false,
  });

  final AppUser user;
  final bool hasSession;
  final bool requiresConfirmation;
}

/// Supabase access for authentication and partner discovery.
///
/// Configure Supabase once in `main()` before constructing this service:
///
/// ```dart
/// await Supabase.initialize(
///   url: const String.fromEnvironment('SUPABASE_URL'),
///   anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
/// );
/// ```
///
/// The anon key is safe for a Flutter client when Supabase RLS policies are
/// correctly configured. Never put a service-role key in the application.
class SupabaseService {
  SupabaseService(
    this._client, {
    bool enableMockPartnerFallback = false,
  }) : _enableMockPartnerFallback = enableMockPartnerFallback;

  final SupabaseClient _client;
  final bool _enableMockPartnerFallback;

  Session? get currentSession => _client.auth.currentSession;

  Future<AppUser?> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      return null;
    }

    return _loadApplicationUser(authUser);
  }

  Future<AuthResult> signUp({
    required String identifier,
    required String password,
    required UserRole role,
    required bool isAutoEntrepreneur,
    String? phone,
  }) async {
    final contact = _normalizeIdentifier(identifier);
    final normalizedPhone = phone == null || phone.trim().isEmpty
        ? null
        : _normalizeIdentifier(phone);
    if (normalizedPhone?.isEmail == true) {
      throw const AppAuthException(
        'رقم الهاتف غير صالح.',
        code: 'invalid_phone',
      );
    }
    _validatePassword(password);

    try {
      final response = await _client.auth.signUp(
        email: contact.isEmail ? contact.value : null,
        phone: contact.isEmail ? null : contact.value,
        password: password,
        data: <String, dynamic>{
          'role': role.value,
          'is_auto_entrepreneur': isAutoEntrepreneur,
          if (normalizedPhone != null) 'phone': normalizedPhone.value,
        },
      );

      final authUser = response.user;
      if (authUser == null) {
        throw const AppAuthException(
          'تعذر إنشاء الحساب. يرجى المحاولة مرة أخرى.',
          code: 'missing_user',
        );
      }

      final user = await _loadApplicationUser(
        authUser,
        fallbackRole: role,
        fallbackIsAutoEntrepreneur: isAutoEntrepreneur,
        fallbackPhone: normalizedPhone?.value,
        // Never treat client-supplied auth metadata as an application profile
        // in production. This escape hatch is only for explicit local mock
        // development and is disabled by the provider.
        allowMetadataFallback: _enableMockPartnerFallback,
      );

      return AuthResult(
        user: user,
        hasSession: response.session != null,
        requiresConfirmation: response.session == null,
      );
    } on AppAuthException {
      rethrow;
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    } on PostgrestException catch (error) {
      throw _mapDatabaseException(error);
    } catch (error) {
      throw AppAuthException(
        'تعذر إنشاء الحساب. يرجى المحاولة مرة أخرى.',
        cause: error,
      );
    }
  }

  Future<AppUser> signIn({
    required String identifier,
    required String password,
  }) async {
    final contact = _normalizeIdentifier(identifier);
    _validatePassword(password);

    try {
      final response = await _client.auth.signInWithPassword(
        email: contact.isEmail ? contact.value : null,
        phone: contact.isEmail ? null : contact.value,
        password: password,
      );

      final authUser = response.user;
      if (authUser == null || response.session == null) {
        throw const AppAuthException(
          'تعذر تسجيل الدخول. يرجى التحقق من بياناتك.',
          code: 'missing_session',
        );
      }

      return _loadApplicationUser(authUser);
    } on AppAuthException {
      rethrow;
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    } on PostgrestException catch (error) {
      throw _mapDatabaseException(error);
    } catch (error) {
      throw AppAuthException(
        'تعذر تسجيل الدخول. يرجى المحاولة مرة أخرى.',
        cause: error,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    } catch (error) {
      throw AppAuthException(
        'تعذر تسجيل الخروج. يرجى المحاولة مرة أخرى.',
        cause: error,
      );
    }
  }

  /// Fetches partner profiles once the `profiles` table is available.
  ///
  /// The optional mock fallback is deliberately opt-in. Enable it only for
  /// local UI development; production must use Supabase data and RLS policies.
  Future<List<AppUser>> fetchAvailablePartners({
    UserRole? role,
  }) async {
    try {
      final baseQuery = _client
          .from('profiles')
          .select('id,email,phone,role,is_auto_entrepreneur');
      final query = role == null ? baseQuery : baseQuery.eq('role', role.value);
      final rows = await query;

      return (rows as List)
          .map(
            (row) => AppUser.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(growable: false);
    } on PostgrestException catch (error) {
      if (_enableMockPartnerFallback && _isMissingProfilesTable(error)) {
        return _mockPartners
            .where((partner) => role == null || partner.role == role)
            .toList(growable: false);
      }
      throw _mapDatabaseException(error);
    } on FormatException catch (error) {
      throw AppAuthException(
        'بيانات الشركاء غير صالحة.',
        code: 'invalid_partner_data',
        cause: error,
      );
    } catch (error) {
      throw AppAuthException(
        'تعذر تحميل قائمة الشركاء.',
        code: 'partners_fetch_failed',
        cause: error,
      );
    }
  }

  Future<AppUser> _loadApplicationUser(
    User authUser, {
    UserRole? fallbackRole,
    bool? fallbackIsAutoEntrepreneur,
    String? fallbackPhone,
    bool allowMetadataFallback = false,
  }) async {
    try {
      final profile = await _client
          .from('profiles')
          .select('id,email,phone,role,is_auto_entrepreneur')
          .eq('id', authUser.id)
          .maybeSingle();

      if (profile != null) {
        return AppUser.fromJson(Map<String, dynamic>.from(profile));
      }
    } on PostgrestException catch (error) {
      // A missing table is allowed during first-time local setup. Any other
      // database error must stop the flow rather than silently trusting UI data.
      if (!_isMissingProfilesTable(error)) {
        throw _mapDatabaseException(error);
      }
    } on FormatException catch (error) {
      throw AppAuthException(
        'ملف المستخدم غير صالح.',
        code: 'invalid_profile',
        cause: error,
      );
    }

    // For sign-in/session restoration, never use auth metadata as the source
    // of authorization-sensitive role data. It is user-controlled metadata;
    // the profiles row must exist and be protected by database policies.
    if (!allowMetadataFallback) {
      throw const AppAuthException(
        'ملف المستخدم غير مكتمل. يرجى التواصل مع الدعم.',
        code: 'missing_profile',
      );
    }

    final metadata = authUser.userMetadata ?? const <String, dynamic>{};
    final metadataRole = UserRoleX.tryParse(metadata['role']) ?? fallbackRole;
    if (metadataRole == null) {
      throw const AppAuthException(
        'ملف المستخدم غير مكتمل. يرجى التواصل مع الدعم.',
        code: 'missing_profile',
      );
    }

    return AppUser(
      id: authUser.id,
      email: authUser.email,
      phone: authUser.phone ?? _nullableMetadataString(metadata['phone']) ?? fallbackPhone,
      role: metadataRole,
      isAutoEntrepreneur:
          _readBool(metadata['is_auto_entrepreneur']) ??
          fallbackIsAutoEntrepreneur ??
          false,
    );
  }

  _Contact _normalizeIdentifier(String rawIdentifier) {
    final value = rawIdentifier.trim();
    if (value.isEmpty) {
      throw const AppAuthException(
        'أدخل البريد الإلكتروني أو رقم الهاتف.',
        code: 'missing_identifier',
      );
    }

    if (value.contains('@')) {
      final email = value.toLowerCase();
      final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
      if (!isValid) {
        throw const AppAuthException(
          'أدخل بريداً إلكترونياً صالحاً.',
          code: 'invalid_email',
        );
      }
      return _Contact(email, isEmail: true);
    }

    final digitsOnly = value.replaceAll(RegExp(r'[\s().-]'), '');
    final normalizedPhone = digitsOnly.startsWith('0')
        ? '+213${digitsOnly.substring(1)}'
        : digitsOnly;
    final isValidPhone =
        RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalizedPhone);
    if (!isValidPhone) {
      throw const AppAuthException(
        'أدخل رقم هاتف دولياً صالحاً، مثل ‎+213555123456.',
        code: 'invalid_phone',
      );
    }
    return _Contact(normalizedPhone, isEmail: false);
  }

  void _validatePassword(String password) {
    if (password.length < 8) {
      throw const AppAuthException(
        'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.',
        code: 'weak_password',
      );
    }
  }

  AppAuthException _mapAuthException(AuthException error) {
    final normalized = error.message.toLowerCase();
    final isCredentialError = normalized.contains('invalid login') ||
        normalized.contains('invalid credentials') ||
        normalized.contains('invalid email or password');

    return AppAuthException(
      isCredentialError
          ? 'بيانات الدخول غير صحيحة.'
          : 'تعذر إتمام عملية المصادقة. يرجى المحاولة مرة أخرى.',
      code: error.code,
      cause: error,
    );
  }

  AppAuthException _mapDatabaseException(PostgrestException error) {
    return AppAuthException(
      'تعذر الوصول إلى بيانات الحساب. يرجى المحاولة لاحقاً.',
      code: error.code,
      cause: error,
    );
  }

  bool _isMissingProfilesTable(PostgrestException error) {
    final message = error.message.toLowerCase();
    return error.code == '42P01' ||
        error.code == 'PGRST205' ||
        message.contains('relation') && message.contains('does not exist') ||
        message.contains('table') && message.contains('not found');
  }

  bool? _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    switch (value?.toString().toLowerCase()) {
      case 'true':
      case '1':
        return true;
      case 'false':
      case '0':
        return false;
      default:
        return null;
    }
  }

  String? _nullableMetadataString(Object? value) {
    final stringValue = value?.toString().trim();
    return stringValue == null || stringValue.isEmpty ? null : stringValue;
  }
}

class _Contact {
  const _Contact(this.value, {required this.isEmail});

  final String value;
  final bool isEmail;
}

final List<AppUser> _mockPartners = <AppUser>[
  const AppUser(
    id: 'mock-importer-001',
    email: 'importer@example.invalid',
    phone: '+213555000001',
    role: UserRole.importer,
    isAutoEntrepreneur: true,
  ),
  const AppUser(
    id: 'mock-investor-001',
    email: 'investor@example.invalid',
    phone: '+213555000002',
    role: UserRole.investor,
    isAutoEntrepreneur: false,
  ),
];