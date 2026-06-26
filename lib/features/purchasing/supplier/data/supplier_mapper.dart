import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/db/app_database.dart';
import '../domain/supplier.dart';

List<String> _decodePhones(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  final decoded = jsonDecode(raw);
  return (decoded as List).map((e) => e.toString()).toList();
}

Supplier toSupplier(SupplierRow r) => Supplier(
      id: r.id,
      organizationId: r.organizationId,
      name: r.name,
      contactPerson: r.contactPerson,
      email: r.email,
      phones: _decodePhones(r.phones),
      address: r.address,
      paymentTerms: r.paymentTerms,
      creditLimit: r.creditLimit,
      isActive: r.isActive,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );

SuppliersCompanion toInsertCompanion(Supplier s) => SuppliersCompanion.insert(
      id: s.id,
      organizationId: s.organizationId,
      name: s.name,
      contactPerson: Value(s.contactPerson),
      email: Value(s.email),
      phones: Value(s.phones.isEmpty ? null : jsonEncode(s.phones)),
      address: Value(s.address),
      paymentTerms: Value(s.paymentTerms),
      creditLimit: Value(s.creditLimit),
      isActive: Value(s.isActive),
      createdAt: s.createdAt,
      updatedAt: s.updatedAt,
    );

SuppliersCompanion toUpdateCompanion(Supplier s) => SuppliersCompanion(
      id: Value(s.id),
      organizationId: Value(s.organizationId),
      name: Value(s.name),
      contactPerson: Value(s.contactPerson),
      email: Value(s.email),
      phones: Value(s.phones.isEmpty ? null : jsonEncode(s.phones)),
      address: Value(s.address),
      paymentTerms: Value(s.paymentTerms),
      creditLimit: Value(s.creditLimit),
      isActive: Value(s.isActive),
      updatedAt: Value(s.updatedAt),
    );
