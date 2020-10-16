import 'dart:io';

import 'package:flutter_resource_generator/resource_config.dart';
import 'package:flutter_resource_generator/src/util.dart';

class FileHandler {

  final ResourceConfig _config;
  final List<String> _imageFiles = [];
  final List<String> _fontFiles = [];
  final Map<String, List<String>> _otherFiles = {};

  FileHandler(this._config);

  List<String> get imageFiles => _imageFiles;

  List<String> get fontFiles => _fontFiles;

  Map<String, List<String>> get otherFiles => _otherFiles;

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
              if (ResourceConfig.IMAGE_EXTENSIONS.contains(extension) || (_config.extraImageExtensions?.contains(extension) ?? false)) {
                path = path.replaceAll(RegExp(r'[1-9]\.0x/'), '');
                _imageFiles.add(path);
              } else if (extension == '.ttf') {
                if (_config.handleFontFile) {
                  _fontFiles.add(path);
                }
              } else {
                var filePathList = _otherFiles[extension];
                if (null == filePathList) {
                  filePathList = [];
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