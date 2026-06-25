import 'package:uuid/uuid.dart';

class IdGenerator {
  const IdGenerator();
  static const _uuid = Uuid();
  String newId() => _uuid.v4();
}
