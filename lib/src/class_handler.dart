import 'package:flutter_resource_generator/resource_config.dart';
import 'package:flutter_resource_generator/src/util.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart';

class ClassHandler {
  final ResourceConfig _config;
  final Map<String, List<String>> _classMemberMap = {};

  ClassHandler(this._config);

  String generateClasses(Iterable<String> fontFamilies,
      Iterable<String> imageFiles, Map<String, Iterable<String>> otherFiles) {
    var fileContent = '';
    if (fontFamilies?.isNotEmpty ?? false) {
      var classContent = _generateClass(_config.fontClassName, fontFamilies,
          fontFamilies.map((e) => e.toUpperCase()));
      fileContent = '$fileContent$classContent\n';
    }

    if (imageFiles?.isNotEmpty ?? false) {
      var pathNameMap = _makeSureAssetsNameUnique(imageFiles);
      var classContent = _generateClass(
          _config.imageClassName, pathNameMap.keys, pathNameMap.values);
      fileContent = '$fileContent$classContent\n';
    }

    if (otherFiles?.isNotEmpty ?? false) {
      for (var entry in otherFiles.entries) {
        var className =
            (_config.extensionClassNameMapping?.containsKey(entry.key) ?? false)
                ? _config.extensionClassNameMapping[entry.key]
                : 'R_' +
                    entry.key.substring(1, 2).toUpperCase() +
                    entry.key.substring(2);
        var pathNameMap = _makeSureAssetsNameUnique(entry.value);
        var classContent =
            _generateClass(className, pathNameMap.keys, pathNameMap.values);
        fileContent = '$fileContent$classContent\n';
      }
    }
    return fileContent;
  }

  String _generateClass(
      String className, Iterable<String> pathList, Iterable<String> nameList) {
    className = _validateClassName(className);
    var memberContent = '';
    for (int i = 0; i < pathList.length; i++) {
      var path = pathList.elementAt(i);
      var memberName = nameList.elementAt(i);
      memberName = _validateMemberName(className, memberName);
      memberContent =
          '''$memberContent  static const String $memberName = '$path';\n''';
    }
    return 'abstract class $className {\n'
        '$memberContent'
        '}\n';
  }

  String _validateClassName(String className) {
    className = _makeSureLegalChar(className);
    className = _makeSureUnique(className, _classMemberMap.keys);
    _classMemberMap[className] = [];
    return className;
  }

  String _validateMemberName(String className, String memberName) {
    memberName = _makeSureLegalChar(memberName);
    memberName = _makeSureUnique(memberName, _classMemberMap[className]);
    _classMemberMap[className].add(memberName);
    return memberName;
  }

  String _makeSureLegalChar(String name) {
    name = name.replaceAll(RegExp(r'[^\w$]'), '_');
    if (name.startsWith(RegExp(r'[0-9]'))) {
      name = '\$$name';
    }
    return name;
  }

  String _makeSureUnique(String name, Iterable<String> existed) {
    var result = name;
    int suffixIndex = 1;
    while (existed?.contains(result) ?? false) {
      result = '${name}_$suffixIndex';
      suffixIndex++;
    }
    return result;
  }

  Map<String, String> _makeSureAssetsNameUnique(Iterable<String> assetPaths) {
    Map<String, String> result = {};
    var namePathMap = groupBy(assetPaths,
        (path) => getNameWithoutExtensionFromPath(path).toUpperCase());
    for (var entry in namePathMap.entries) {
      if (entry.value.length > 1) {
        for (var path in entry.value) {
          var name = path
              .substring(0, path.lastIndexOf('.'))
              .split(separator)
              .reversed
              .join('_')
              .toUpperCase();
          result[path] = name;
        }
      } else {
        result[entry.value[0]] = entry.key;
      }
    }
    return result;
  }
}
