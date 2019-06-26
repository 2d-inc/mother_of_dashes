import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Get a local data directory where we can read/write files.
Future<Directory> dataDirectory(String dirName) async {
  String path;
  if (Platform.isMacOS || Platform.isLinux) {
    path = '${Platform.environment['HOME']}/.config/$dirName';
  } else if (Platform.isWindows) {
    path = '${Platform.environment['UserProfile']}\\.config\\$dirName';
  } else {
    var directory = await getApplicationDocumentsDirectory();
    path = "${directory.path}/$dirName";
  }
  var dir = Directory(path);
  if (!await dir.exists()) {
    dir = await dir.create();
  }
  return dir;
}
