/// The two roles currently supported by TradeSync AI.
enum UserRole {
  importer,
  investor,
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.importer:
        return 'importer';
      case UserRole.investor:
        return 'investor';
    }
  }

  static UserRole? tryParse(Object? value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'importer':
        return UserRole.importer;
      case 'investor':
        return UserRole.investor;
      default:
        return null;
    }
  }

  static UserRole parse(Object? value) {
    final parsed = tryParse(value);
    if (parsed == null) {
      throw FormatException(
        'role must be either "importer" or "investor"',
        value,
      );
    }
    return parsed;
  }
}

/// Application-level user data.
///
/// `email` and `phone` are nullable because Supabase accounts may authenticate
/// through either contact method. The database should enforce that at least one
/// is present and that `role` is one of the two allowed values.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.isAutoEntrepreneur,
  }) : assert(id != '', 'A user id is required');

  final String id;
  final String? email;
  final String? phone;
  final UserRole role;
  final bool isAutoEntrepreneur;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim();
    if (id == null || id.isEmpty) {
      throw const FormatException('User JSON is missing a valid id');
    }

    return AppUser(
      id: id,
      email: _nullableString(json['email']),
      phone: _nullableString(json['phone']),
      role: UserRoleX.parse(json['role']),
      isAutoEntrepreneur: _asBool(json['is_auto_entrepreneur']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'phone': phone,
      'role': role.value,
      'is_auto_entrepreneur': isAutoEntrepreneur,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? phone,
    UserRole? role,
    bool? isAutoEntrepreneur,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isAutoEntrepreneur: isAutoEntrepreneur ?? this.isAutoEntrepreneur,
    );
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, phone: $phone, '
        'role: ${role.value}, isAutoEntrepreneur: $isAutoEntrepreneur)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppUser &&
            other.id == id &&
            other.email == email &&
            other.phone == phone &&
            other.role == role &&
            other.isAutoEntrepreneur == isAutoEntrepreneur;
  }

  @override
  int get hashCode => Object.hash(
        id,
        email,
        phone,
        role,
        isAutoEntrepreneur,
      );
}

String? _nullableString(Object? value) {
  final stringValue = value?.toString().trim();
  return stringValue == null || stringValue.isEmpty ? null : stringValue;
}

bool _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }

  switch (value?.toString().trim().toLowerCase()) {
    case 'true':
    case '1':
    case 'yes':
      return true;
    case 'false':
    case '0':
    case 'no':
    case null:
    case '':
      return false;
    default:
      throw FormatException('is_auto_entrepreneur must be a boolean', value);
  }
}