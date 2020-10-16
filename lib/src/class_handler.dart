import 'package:flutter_resource_generator/resource_config.dart';
import 'package:flutter_resource_generator/src/util.dart';

typedef _MemberNameGenerator = String Function(String value);

class ClassHandler {

  final ResourceConfig _config;
  final Map<String, List<String>> _classMemberMap = {};

  ClassHandler(this._config);

  String generateClasses(List<String> fontFamilies, List<String> imageFiles, Map<String, List<String>> otherFiles) {
    var fileContent = '';
    if (fontFamilies?.isNotEmpty ?? false) {
      var classContent = _generateClass(_config.fontClassName, fontFamilies, (value) => value.toUpperCase());
      fileContent = '$fileContent$classContent\n';
    }

    if (imageFiles?.isNotEmpty ?? false) {
      var classContent = _generateClass(_config.imageClassName, imageFiles, (value) => getNameWithoutExtensionFromPath(value).toUpperCase());
      fileContent = '$fileContent$classContent\n';
    }

    if (otherFiles?.isNotEmpty ?? false) {
      for (var entry in otherFiles.entries) {
        var className = (_config.extensionClassNameMapping?.containsKey(entry.key) ?? false)
            ? _config.extensionClassNameMapping[entry.key] : 'R_' + entry.key.substring(1, 2).toUpperCase() + entry.key.substring(2);
        var classContent = _generateClass(className, entry.value, (value) => getNameWithoutExtensionFromPath(value).toUpperCase());
        fileContent = '$fileContent$classContent\n';
      }
    }
    return fileContent;
  }

  String _generateClass(String className, List<String> valueList, _MemberNameGenerator nameGenerator) {
    className = _validateClassName(className);
    var memberContent = '\n';
    for (var value in valueList) {
      var memberName = nameGenerator.call(value);
      memberName = _validateMemberName(className, memberName);
      memberContent = '''$memberContent  static const String $memberName = '$value';\n''';
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

}