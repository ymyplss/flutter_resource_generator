import 'package:flutter_resource_generator/resource_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

/// Resource generator builder
Builder resourceBuilder(BuilderOptions options) =>
    LibraryBuilder(ResourceGenerator(), generatedExtension: '.resource.dart');
