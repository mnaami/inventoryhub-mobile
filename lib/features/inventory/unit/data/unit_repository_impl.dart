import 'package:drift/native.dart'; // SqliteException is exported here, not from drift.dart
import '../../../../core/result/app_exception.dart';
import '../data/unit_dao.dart';
import '../domain/unit.dart';
import '../domain/unit_repository.dart';
import 'unit_mapper.dart';

class UnitRepositoryImpl implements UnitRepository {
  UnitRepositoryImpl(this._dao);
  final UnitDao _dao;

  @override
  Future<List<Unit>> listActive(String organizationId) async =>
      (await _dao.activeForOrg(organizationId)).map(toUnit).toList();

  @override
  Future<List<Unit>> baseUnits(String organizationId) async =>
      (await _dao.baseUnits(organizationId)).map(toUnit).toList();

  @override
  Future<Unit?> getById(String id) async {
    final r = await _dao.byId(id);
    return r == null ? null : toUnit(r);
  }

  @override
  Future<Unit> create(Unit unit) async {
    try {
      await _dao.insertRow(toCompanion(unit));
      return unit;
    } on SqliteException {
      throw ConflictException('A unit named "${unit.name}" or symbol "${unit.symbol}" already exists.');
    }
  }

  @override
  Future<Unit> update(Unit unit) async {
    try {
      await _dao.updateRow(toCompanion(unit));
      return unit;
    } on SqliteException {
      throw ConflictException('A unit named "${unit.name}" or symbol "${unit.symbol}" already exists.');
    }
  }

  @override
  Future<void> softDelete(String id) => _dao.softDelete(id, DateTime.now().toUtc());
}
