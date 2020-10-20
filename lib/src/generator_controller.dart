import 'package:flutter_resource_generator/resource_config.dart';
import 'package:flutter_resource_generator/src/class_handler.dart';
import 'package:flutter_resource_generator/src/file_handler.dart';
import 'package:flutter_resource_generator/src/pubspec_handler.dart';

class GeneratorController {
  final ResourceConfig config;

  GeneratorController(this.config);

  String generateAll() {
    return _generateImpl(false);
  }

  String generateFonts() {
    return _generateImpl(true);
  }

  String _generateImpl(bool onlyUpdateFont) {
    var pubSpecHandler = PubSpecHandler(config);
    pubSpecHandler.parseContent();
    var fileHandler = FileHandler(config);
    fileHandler.parseFiles();
    if (!onlyUpdateFont) {
      pubSpecHandler.addAssetsThenWriteBack(fileHandler.fontFiles,
          fileHandler.imageFiles, fileHandler.otherFiles);
    }
    var classHandler = ClassHandler(config);
    return classHandler.generateClasses(pubSpecHandler.fontFamilies,
        fileHandler.imageFiles, fileHandler.otherFiles);
  }
}
