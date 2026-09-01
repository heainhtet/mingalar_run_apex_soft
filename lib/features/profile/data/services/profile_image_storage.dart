import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ProfileImageStorage {
  Future<String> persist(String temporaryPath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}profile_images',
    );
    await imageDirectory.create(recursive: true);

    final extension = _fileExtension(temporaryPath);
    final destination = File(
      '${imageDirectory.path}${Platform.pathSeparator}'
      'avatar_${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    return File(temporaryPath).copy(destination.path).then((file) => file.path);
  }

  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  String _fileExtension(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final extensionIndex = fileName.lastIndexOf('.');
    return extensionIndex <= 0 ? '.jpg' : fileName.substring(extensionIndex);
  }
}
