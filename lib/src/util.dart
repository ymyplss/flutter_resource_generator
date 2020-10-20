import 'package:path/path.dart';

String getExtensionWithDotFromPath(String filePath) {
  var dotIndex = filePath.lastIndexOf('.');
  return dotIndex > 0 && dotIndex < filePath.length - 1
      ? filePath.substring(dotIndex)
      : null;
}

String getNameWithoutExtensionFromPath(String filePath) {
  var pathSeparatorIndex = filePath.lastIndexOf(separator);
  var dotIndex = filePath.lastIndexOf('.');
  return pathSeparatorIndex >= 0 &&
          dotIndex > 0 &&
          dotIndex < filePath.length - 1 &&
          pathSeparatorIndex + 1 < dotIndex
      ? filePath.substring(pathSeparatorIndex + 1, dotIndex)
      : null;
}

String getParentFolderFromPath(String filePath) {
  var pathSeparatorIndex = filePath.lastIndexOf(separator);
  return pathSeparatorIndex >= 0 && pathSeparatorIndex < filePath.length - 1
      ? filePath.substring(0, pathSeparatorIndex + 1)
      : null;
}
