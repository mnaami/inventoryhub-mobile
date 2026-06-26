import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/customer.dart';

List<String> _decodePhones(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  final decoded = jsonDecode(raw);
  return (decoded as List).map((e) => e.toString()).toList();
}

Customer toCustomer(CustomerRow r) => Customer(
      id: r.id,
      organizationId: r.organizationId,
      name: r.name,
      email: r.email,
      phones: _decodePhones(r.phones),
      address: r.address,
      paymentTerms: r.paymentTerms,
      creditLimit: r.creditLimit,
      imagePath: r.imagePath,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

CustomersCompanion toInsertCompanion(Customer c) => CustomersCompanion.insert(
      id: c.id,
      organizationId: c.organizationId,
      name: c.name,
      email: Value(c.email),
      phones: Value(c.phones.isEmpty ? null : jsonEncode(c.phones)),
      address: Value(c.address),
      paymentTerms: Value(c.paymentTerms),
      creditLimit: Value(c.creditLimit),
      imagePath: Value(c.imagePath),
      isActive: Value(c.isActive),
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
    );

CustomersCompanion toUpdateCompanion(Customer c) => CustomersCompanion(
      id: Value(c.id),
      organizationId: Value(c.organizationId),
      name: Value(c.name),
      email: Value(c.email),
      phones: Value(c.phones.isEmpty ? null : jsonEncode(c.phones)),
      address: Value(c.address),
      paymentTerms: Value(c.paymentTerms),
      creditLimit: Value(c.creditLimit),
      imagePath: Value(c.imagePath),
      isActive: Value(c.isActive),
      updatedAt: Value(c.updatedAt),
    );
