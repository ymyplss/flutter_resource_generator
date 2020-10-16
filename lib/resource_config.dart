import 'package:source_gen/source_gen.dart';

class ResourceConfig {

  static const List<String> IMAGE_EXTENSIONS = [".png", ".jpg", ".jpeg", ".gif", ".webp", ".icon", ".bmp", ".wbmp", ".svg"];

  final String resourcePath;
  final String imageClassName;
  final String fontClassName;
  final bool handleFontFile;
  final List<String> ignoreExtensions;
  final List<String> extraImageExtensions;
  final Map<String, String> extensionClassNameMapping;

  const ResourceConfig({
    this.resourcePath,
    this.imageClassName,
    this.fontClassName,
    this.handleFontFile = false,
    this.ignoreExtensions,
    this.extraImageExtensions,
    this.extensionClassNameMapping,
  }) :  assert(null != resourcePath);

  static fromAnnotation(ConstantReader annotation) {
    var resourcePath = annotation.peek('resourcePath')?.stringValue;
    if (resourcePath?.isNotEmpty ?? false) {
      var imageClassName = annotation.peek('imageClassName')?.stringValue ?? 'R_Image';
      var fontClassName = annotation.peek('fontClassName')?.stringValue ?? 'R_Font';
      var handleFontFile = annotation.peek('handleFontFile')?.boolValue ?? false;
      var ignoreExtensions = annotation.peek('ignoreExtensions')?.listValue?.cast<String>();
      ignoreExtensions = ignoreExtensions?.map((extension) => extension.startsWith('.') ? extension.toLowerCase() : '.$extension'.toLowerCase())?.toList();
      var extraImageExtensions = annotation.peek('extraImageExtensions')?.listValue?.cast<String>();
      extraImageExtensions = extraImageExtensions?.map((extension) => extension.startsWith('.') ? extension.toLowerCase() : '.$extension'.toLowerCase())?.toList();
      var extensionClassNameMapping = annotation.peek('extensionClassNameMapping')?.mapValue?.cast<String, String>();
      extensionClassNameMapping?.keys?.toList()?.forEach((key) {
        var value = extensionClassNameMapping.remove(key);
        var finalKey = key.startsWith('.') ? key.toLowerCase() : '.$key'.toLowerCase();
        extensionClassNameMapping[finalKey] = value;
      });
      return ResourceConfig(
        resourcePath: resourcePath,
        imageClassName: imageClassName,
        fontClassName: fontClassName,
        handleFontFile: handleFontFile,
        ignoreExtensions: ignoreExtensions,
        extraImageExtensions: extraImageExtensions,
        extensionClassNameMapping: extensionClassNameMapping,);
    } else {
      return null;
    }
  }

}