import 'package:flutter_riverpod/legacy.dart';

// Models
class ImporterProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final List<String> travelCountries;  // China, Turkey, UAE, Egypt
  final double commissionPerKg;
  final double cargoCapacityKg;
  final bool isVerified;
  final String? verificationBadgeUrl;
  final DateTime createdAt;

  ImporterProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.travelCountries,
    required this.commissionPerKg,
    required this.cargoCapacityKg,
    required this.isVerified,
    this.verificationBadgeUrl,
    required this.createdAt,
  });
}

class ClientProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final double totalSpentDZD;
  final DateTime createdAt;

  ClientProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.totalSpentDZD,
    required this.createdAt,
  });
}

class ImportRequest {
  final String id;
  final String clientId;
  final String importerId;
  final String productDescription;
  final double quantityKg;
  final String originCountry;
  final double estimatedUnitPriceUSD;
  final String status;  // pending, accepted, in_transit, completed
  final DateTime createdAt;

  ImportRequest({
    required this.id,
    required this.clientId,
    required this.importerId,
    required this.productDescription,
    required this.quantityKg,
    required this.originCountry,
    required this.estimatedUnitPriceUSD,
    required this.status,
    required this.createdAt,
  });
}

// Riverpod Providers
final userRoleProvider = StateProvider<String?>((ref) => null);

final userAuthProvider = StateProvider<Map<String, String>?>((ref) => null);

final importerProfileProvider = StateProvider<ImporterProfile?>((ref) => null);

final clientProfileProvider = StateProvider<ClientProfile?>((ref) => null);

final importRequestsProvider = StateProvider<List<ImportRequest>>((ref) => []);
