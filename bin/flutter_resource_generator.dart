import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:flutter_resource_generator/resource_config.dart';
import 'package:flutter_resource_generator/src/generator_controller.dart';

/// Resource class file generator script
void main(List<String> args) {
  ArgParser parser = _createParser();
  ArgResults results = parser.parse(args);
  if (results['help'] as bool) {
    print(parser.usage);
  } else {
    ResourceConfig config = ResourceConfig.fromArgs(results);
    if (null != config) {
      var monitor = results['monitor'] as bool;
      var target = results['target'] as String;
      var worker = _Worker(config, monitor, target);
      worker.start();
    }
  }
}

ArgParser _createParser() {
  ArgParser parser = ArgParser();
  parser
    ..addFlag('help', abbr: 'h', help: 'Show usage', defaultsTo: false)
    ..addFlag('monitor',
        abbr: 'm',
        help:
            'Continue to monitor asset folder after execution of generating resource file, default is true',
        defaultsTo: true)
    ..addOption('target',
        abbr: 't',
        help: 'Relative path of generated resource class file',
        defaultsTo: 'lib/resource.dart')
    ..addOption(
      'resource-path',
      abbr: 'r',
      help: 'Root folder of all assets, must NOT be null',
    )
    ..addOption('image-class-name',
        abbr: 'i', help: 'Image resource class name', defaultsTo: 'R_Image')
    ..addOption('font-class-name',
        abbr: 'f', help: 'Font resource class name', defaultsTo: 'R_Font')
    ..addFlag('handle-font-file',
        abbr: 'a',
        help: 'Handle font file asset, default is false',
        defaultsTo: false)
    ..addFlag('only-add-folder',
        abbr: 'o',
        help:
            'Only add folder path in assets section instead of adding full file path, default is true',
        defaultsTo: true)
    ..addOption(
      'ignore-extensions',
      abbr: 'g',
      help:
          r'The file with extension existed in this list will be ignored, can be null, separated by ",", e.g. ".txt,.exe"',
    )
    ..addOption(
      'extra-image-extensions',
      abbr: 'x',
      help:
          r'The file with extension existed in [".png", ".jpg", ".jpeg",".gif", ".webp", ".icon", ".bmp", ".wbmp", ".svg"] or this list will be treat as image, can be null, separated by ",", e.g. ".tif,.eps"',
    )
    ..addOption(
      'extension-class-name-mapping',
      abbr: 'c',
      help:
          r'By default, the class name of other files will be R_${extension}, for example, the resource class of json files will be "R_Json". if you want customize the class name of json file, like "JsonRes", you can pass ".json:JsonRes", can be null, separated by ",", e.g. ".json:JsonRes,.xml:XmlRes"',
    );
  return parser;
}

class _Worker {
  static const String CLASS_CONTENT_HEADER =
      '// **************************************************************************\n'
      '//\n'
      '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
      '//\n'
      '// **************************************************************************\n\n';

  final ResourceConfig config;
  final bool monitor;
  final GeneratorController _controller;
  final File _resourceFile;
  final List<StreamSubscription<FileSystemEvent>> _watchList = [];

  _Worker(this.config, this.monitor, String target)
      : _controller = GeneratorController(config),
        _resourceFile = File(target);

  void start() {
    print('Start to generate resource class');
    _runWorkerOnce();
    if (monitor && FileSystemEntity.isWatchSupported) {
      print('Start to monitor resource folder and pubspec file');
    }
  }

  void _runWorkerOnce([bool onlyUpdateFont = false]) {
    _stopWatch();
    var classContent = onlyUpdateFont
        ? _controller.generateFonts()
        : _controller.generateAll();
    _resourceFile.writeAsStringSync('$CLASS_CONTENT_HEADER$classContent',
        flush: true);
    if (monitor) {
      _startWatch();
    }
  }

  void _startWatch() {
    if (FileSystemEntity.isWatchSupported) {
      File pubSpec = File('pubspec.yaml');
      _watch(pubSpec, true);
      Directory root = Directory(config.resourcePath);
      if (root.existsSync()) {
        _watch(root);
        for (var file in root.listSync(recursive: true)) {
          if (file.statSync().type == FileSystemEntityType.directory) {
            _watch(file);
          }
        }
      }
    } else {
      print("File watch is not supported by this system, exit");
    }
  }

  void _stopWatch() {
    for (var watch in _watchList) {
      watch.cancel();
    }
    _watchList.clear();
  }

  void _watch(FileSystemEntity file, [bool onlyUpdateFont = false]) {
    var subscription = file.watch().listen((event) {
      //print('type:${event.type} path:${event.path}');
      if (event.type == FileSystemEvent.create && event.isDirectory) {
        _watch(Directory(event.path));
      } else {
        _runWorkerOnce(onlyUpdateFont);
      }
    });
    if (null != subscription) {
      _watchList.add(subscription);
    }
  }
}
