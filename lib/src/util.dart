String getExtensionWithDotFromPath(String filePath) {
  var dotIndex = filePath.lastIndexOf('.');
  return dotIndex > 0 && dotIndex < filePath.length - 1 ? filePath.substring(dotIndex) : null;
}

String getNameWithoutExtensionFromPath(String filePath) {
  var slashIndex = filePath.lastIndexOf('/');
  var dotIndex = filePath.lastIndexOf('.');
  return slashIndex >= 0 && dotIndex > 0 && dotIndex < filePath.length - 1 && slashIndex + 1 < dotIndex
      ? filePath.substring(slashIndex + 1, dotIndex) : null;
}