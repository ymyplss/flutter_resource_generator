import 'dart:io';

import 'package:flutter_resource_generator/resource_config.dart';
import 'package:flutter_resource_generator/src/util.dart';

class PubSpecHandler {
  static final RegExp _anyNewRootSection = RegExp(r'^\w.*:.*$');
  static final RegExp _anyNewSubSection = RegExp(r'^  \w.*:.*$');
  static final RegExp _flutterSection = RegExp(r'^flutter *: *(#+.*|$)$');
  static final RegExp _assetsSection = RegExp(r'^  assets *: *(#+.*|$)$');
  static final RegExp _fontsSection = RegExp(r'^  fonts *: *(#+.*|$)$');
  static final RegExp _fontFamilySection =
      RegExp(r'^    - family *: +([^# ][^#]*) *(?:#+.*|$)$');

  final ResourceConfig _config;
  final File _pubSpecFile = File('pubspec.yaml');

  String _content = '';
  String _flutterSectionContent = '';
  List<String> _fontFamilies = [];

  PubSpecHandler(this._config);

  List<String> get fontFamilies => _fontFamilies;

  void parseContent() {
    var linesIterator = _pubSpecFile.readAsLinesSync().iterator;
    while (linesIterator.moveNext()) {
      var line = linesIterator.current;
      if (_flutterSection.hasMatch(line.trimRight())) {
        _flutterSectionContent = '$_flutterSectionContent$line\n';
        line = _parseFlutterSectionContent(linesIterator);
      }
      if (null != line) {
        _content = '$_content$line\n';
      }
    }
  }

  String _parseFlutterSectionContent(Iterator<String> linesIterator) {
    String line;
    while (null != line || linesIterator.moveNext()) {
      line ??= linesIterator.current;
      if (_assetsSection.hasMatch(line.trimRight())) {
        line = _skipToNextRootOrSubSection(linesIterator);
      } else if (_fontsSection.hasMatch(line.trimRight())) {
        if (_config.handleFontFile) {
          line = _skipToNextRootOrSubSection(linesIterator);
        } else {
          _flutterSectionContent = '$_flutterSectionContent$line\n';
          line = _getAllFontFamilies(linesIterator);
        }
      } else {
        if (_anyNewRootSection.hasMatch(line.trimRight())) {
          return line;
        } else {
          _flutterSectionContent = '$_flutterSectionContent$line\n';
          line = null;
        }
      }
    }
    return null;
  }

  String _skipToNextRootOrSubSection(Iterator<String> linesIterator) {
    while (linesIterator.moveNext()) {
      var line = linesIterator.current;
      if (_anyNewRootSection.hasMatch(line.trimRight()) ||
          _anyNewSubSection.hasMatch(line.trimRight())) {
        return line;
      }
    }
    return null;
  }

  String _getAllFontFamilies(Iterator<String> linesIterator) {
    while (linesIterator.moveNext()) {
      var line = linesIterator.current;
      if (_anyNewRootSection.hasMatch(line.trimRight()) ||
          _anyNewSubSection.hasMatch(line.trimRight())) {
        return line;
      } else {
        _flutterSectionContent = '$_flutterSectionContent$line\n';
        var family = _fontFamilySection
            .firstMatch(line.trimRight())
            ?.group(1)
            ?.trimRight();
        if (null != family) {
          _fontFamilies.add(family);
        }
      }
    }
    return null;
  }

  void addAssetsThenWriteBack(Iterable<String> fontFiles,
      Iterable<String> imageFiles, Map<String, Iterable<String>> otherFiles) {
    _flutterSectionContent = '$_flutterSectionContent' +
        (_flutterSectionContent.endsWith('\n\n') ? '' : '\n');
    if (fontFiles?.isNotEmpty ?? false) {
      String fontsSection = '  fonts:\n';
      for (var filePath in fontFiles) {
        var name = getNameWithoutExtensionFromPath(filePath);
        var fontSection =
            '    - family: $name\n      fonts:\n        - asset: $filePath';
        fontsSection = '$fontsSection$fontSection\n';
        _fontFamilies.add(name);
      }
      _flutterSectionContent = '$_flutterSectionContent$fontsSection\n';
    }

    if ((imageFiles?.isNotEmpty ?? false) ||
        (otherFiles?.isNotEmpty ?? false)) {
      _flutterSectionContent = '$_flutterSectionContent  assets:\n';
      if (imageFiles?.isNotEmpty ?? false) {
        _flutterSectionContent = '$_flutterSectionContent    #Image\n';
        _flutterSectionContent =
            '$_flutterSectionContent${_generateAssetList(imageFiles)}';
      }

      if (otherFiles?.isNotEmpty ?? false) {
        for (var entry in otherFiles.entries) {
          var extensionWithoutDot =
              entry.key.substring(1, 2).toUpperCase() + entry.key.substring(2);
          _flutterSectionContent =
              '$_flutterSectionContent    #$extensionWithoutDot\n';
          _flutterSectionContent =
              '$_flutterSectionContent${_generateAssetList(entry.value)}';
        }
      }
    }

    _content = '$_content' + (_content.endsWith('\n\n') ? '' : '\n');
    _pubSpecFile.writeAsString('$_content$_flutterSectionContent', flush: true);
  }

  String _generateAssetList(Iterable<String> assetFiles) {
    String result = "";
    List<String> addedFolder = [];
    for (var filePath in assetFiles) {
      if (_config.onlyAddFolder) {
        var folder = getParentFolderFromPath(filePath);
        if (!addedFolder.contains(folder)) {
          addedFolder.add(folder);
          result = '$result    - $folder\n';
        }
      } else {
        result = '$result    - $filePath\n';
      }
    }
    return result;
  }
}
