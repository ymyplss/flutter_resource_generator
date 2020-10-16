library flutter_resource_generator;

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_resource_generator/resource_config.dart';
import 'package:flutter_resource_generator/src/class_handler.dart';
import 'package:flutter_resource_generator/src/file_handler.dart';
import 'package:flutter_resource_generator/src/pubspec_handler.dart';
import 'package:source_gen/source_gen.dart';

class ResourceGenerator extends GeneratorForAnnotation<ResourceConfig> {

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    var config = ResourceConfig.fromAnnotation(annotation);
    if (config != null) {
      var pubSpecHandler = PubSpecHandler(config.handleFontFile);
      pubSpecHandler.parseContent();
      var fileHandler = FileHandler(config);
      fileHandler.parseFiles();
      pubSpecHandler.addAssetsThenWriteBack(fileHandler.fontFiles, fileHandler.imageFiles, fileHandler.otherFiles);
      var classHandler = ClassHandler(config);
      return classHandler.generateClasses(pubSpecHandler.fontFamilies, fileHandler.imageFiles, fileHandler.otherFiles);
    } else {
      return null;
    }
  }

}
