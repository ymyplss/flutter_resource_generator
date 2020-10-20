library flutter_resource_generator;

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:flutter_resource_generator/resource_config.dart';
import 'package:flutter_resource_generator/src/generator_controller.dart';
import 'package:source_gen/source_gen.dart';

/**
 * Resource class content generator
 */
class ResourceGenerator extends GeneratorForAnnotation<ResourceConfig> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    var config = ResourceConfig.fromAnnotation(annotation);
    if (config != null) {
      var fileContentHeader =
          '// **************************************************************************\n'
          '// if you add new resource file, recommend to run clean first：\n'
          '// flutter packages pub run build_runner clean \n'
          '// \n'
          '// run following command to generate resource class：\n'
          '// flutter packages pub run build_runner build --delete-conflicting-outputs \n'
          '// **************************************************************************\n\n';
      return '$fileContentHeader${GeneratorController(config).generateAll()}';
    } else {
      return null;
    }
  }
}
