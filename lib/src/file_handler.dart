import 'dart:io';

import 'package:flutter_resource_generator/resource_config.dart';
import 'package:flutter_resource_generator/src/util.dart';
import 'package:path/path.dart';

class FileHandler {
  final ResourceConfig _config;
  final Set<String> _imageFiles = Set();
  final Set<String> _fontFiles = Set();
  final Map<String, Set<String>> _otherFiles = {};

  FileHandler(this._config);

  Iterable<String> get imageFiles => _imageFiles;

  Iterable<String> get fontFiles => _fontFiles;

  Map<String, Iterable<String>> get otherFiles => _otherFiles;

  void parseFiles() {
    Directory root = Directory(_config.resourcePath);
    if (root.existsSync()) {
      for (var file in root.listSync(recursive: true)) {
        if (file.statSync().type == FileSystemEntityType.file) {
          var path = file.path;
          var extension = getExtensionWithDotFromPath(path).toLowerCase();
          var name = getNameWithoutExtensionFromPath(path);
          if (extension != null && name != null) {
            if (!(_config.ignoreExtensions?.contains(extension) ?? false)) {
              if (ResourceConfig.IMAGE_EXTENSIONS.contains(extension) ||
                  (_config.extraImageExtensions?.contains(extension) ??
                      false)) {
                path = path.replaceAll(
                    RegExp(r'[1-9]\.0x' + (separator == '/' ? '/' : r'\\')),
                    '');
                _imageFiles.add(path);
              } else if (extension == '.ttf') {
                if (_config.handleFontFile) {
                  _fontFiles.add(path);
                }
              } else {
                var filePathList = _otherFiles[extension];
                if (null == filePathList) {
                  filePathList = Set();
                  _otherFiles[extension] = filePathList;
                }
                filePathList.add(path);
              }
            }
          }
        }
      }
    }
  }
}
