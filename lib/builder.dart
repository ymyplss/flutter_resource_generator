import 'package:flutter_resource_generator/flutter_resource_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

Builder resourceBuilder(BuilderOptions options) =>
    LibraryBuilder(ResourceGenerator(), generatedExtension: '.resource.dart');