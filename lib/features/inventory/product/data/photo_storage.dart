import 'dart:io';
import '../../../../core/id/id_generator.dart';
import '../../../../core/result/app_exception.dart';

class PhotoStorage {
  PhotoStorage(this._baseDir, this._ids);
  final Directory _baseDir;
  final IdGenerator _ids;

  Future<String> save(File source) async {
    try {
      final dir = Directory('${_baseDir.path}/product_photos');
      await dir.create(recursive: true);
      final dest = File('${dir.path}/${_ids.newId()}.jpg');
      await source.copy(dest.path);
      return dest.path;
    } on FileSystemException catch (e) {
      throw StorageException('Could not save photo: ${e.message}');
    }
  }

  Future<void> delete(String path) async {
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }
}
