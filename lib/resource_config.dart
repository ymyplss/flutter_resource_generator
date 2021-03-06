import 'package:source_gen/source_gen.dart';
import 'package:args/args.dart';

class ResourceConfig {
  /// Default image file extensions
  static const List<String> IMAGE_EXTENSIONS = [
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".webp",
    ".icon",
    ".bmp",
    ".wbmp",
    ".svg"
  ];

  /// The relative path of your asset file folder, for example 'assets/', must `NOT` be empty
  final String resourcePath;

  /// The name of image resource class, by default, it is `R_Image`, can be null
  final String imageClassName;

  /// The name of font resource class, by default, it is `R_Font`, can be null
  final String fontClassName;

  /// Whether font file will be handled, by default, it is `false`, can be null
  ///
  /// Since font conifguration is very complex, family, weight and style can be set for each font file. You need to
  /// set these paramters for every single font file to generate font resource information, the workload is the same
  /// as directly add this parameters into pubspec file. So by default, we don't handle font file, if you set
  /// `handleFontFile` to true, we will add every font file into pubspec file as separate font family, and the original
  /// font section in pubspec file will be `OVERWRITE`.
  ///
  /// For example, you have three font files in your resource folder
  ///     project root/
  ///       assets/
  ///         font_a.ttf
  ///         font_b.ttf
  ///         font_c.ttf
  /// the generated font section in pubspec file will be something like
  ///     fonts:
  ///       -- family: font_a
  ///       fonts:
  ///         -- asset: assets/font_a.ttf
  ///       -- family: font_b
  ///        fonts:
  ///          -- asset: assets/font_b.ttf
  ///       -- family: font_c
  ///         fonts:
  ///           -- asset: assets/font_c.ttf
  ///
  /// No matter whether `handleFontFile` is true or false, font family resource class will be generated by parsing
  /// every family item under fonts section in pubspec file, as the font section showed before, the generated font
  /// class will be something like this
  ///     abstract class R_Font {
  ///          static const String FONT_A = "font_a"
  ///          static const String FONT_B = "font_b"
  ///          static const String FONT_C = "font_c"
  ///     }
  final bool handleFontFile;

  /// Whether only add folder path of asset file instead of full file path, by default, it is `true`,
  /// can be null. Why not always set this flag to true? Because if you added resolution-aware image assets, for example, 2.0x
  /// or 3.0x, but you don't provide main assets(1.0x, which is rarely used), you MUST add full file path under assets section
  /// in pubspec file, otherwise these image assets can't be used in your project!
  final bool onlyAddFolder;

  /// The file with extension existed in this list will be ignored, can be null
  final List<String> ignoreExtensions;

  /// The file with extension existed in [".png", ".jpg", ".jpeg",
  /// ".gif", ".webp", ".icon", ".bmp", ".wbmp", ".svg"] or extraImageExtensions will be treat as image, can be null
  final List<String> extraImageExtensions;

  /// By default, the class name of other files will be
  /// R_${extension}, for example, the resource class of json files will be `R_Json`. if you want customize the class
  /// name of json file, like `JsonRes`, you can pass {".json", "JsonRes"}, can be null
  final Map<String, String> extensionClassNameMapping;

  /// Default constructor
  const ResourceConfig({
    this.resourcePath,
    this.imageClassName,
    this.fontClassName,
    this.handleFontFile = false,
    this.onlyAddFolder = true,
    this.ignoreExtensions,
    this.extraImageExtensions,
    this.extensionClassNameMapping,
  }) : assert(null != resourcePath, 'Resource path is null');

  /// Create resource config from annotation
  static ResourceConfig fromAnnotation(ConstantReader annotation) {
    var resourcePath = annotation.peek('resourcePath')?.stringValue;
    if (resourcePath?.isNotEmpty ?? false) {
      var imageClassName =
          annotation.peek('imageClassName')?.stringValue ?? 'R_Image';
      var fontClassName =
          annotation.peek('fontClassName')?.stringValue ?? 'R_Font';
      var handleFontFile =
          annotation.peek('handleFontFile')?.boolValue ?? false;
      var onlyAddFolder = annotation.peek('onlyAddFolder')?.boolValue ?? true;
      var ignoreExtensions = annotation
          .peek('ignoreExtensions')
          ?.listValue
          ?.cast<String>()
          ?.checkDot();
      var extraImageExtensions = annotation
          .peek('extraImageExtensions')
          ?.listValue
          ?.cast<String>()
          ?.checkDot();
      var extensionClassNameMapping = annotation
          .peek('extensionClassNameMapping')
          ?.mapValue
          ?.cast<String, String>();
      extensionClassNameMapping?.keys?.toList()?.forEach((key) {
        var value = extensionClassNameMapping.remove(key);
        var finalKey =
            key.startsWith('.') ? key.toLowerCase() : '.$key'.toLowerCase();
        extensionClassNameMapping[finalKey] = value;
      });
      return ResourceConfig(
        resourcePath: resourcePath,
        imageClassName: imageClassName,
        fontClassName: fontClassName,
        handleFontFile: handleFontFile,
        onlyAddFolder: onlyAddFolder,
        ignoreExtensions: ignoreExtensions,
        extraImageExtensions: extraImageExtensions,
        extensionClassNameMapping: extensionClassNameMapping,
      );
    } else {
      throw Exception('Resource path is empty');
    }
  }

  /// Create resource config from command line args
  static ResourceConfig fromArgs(ArgResults results) {
    if (results.wasParsed('resource-path')) {
      var resourcePath = results['resource-path'] as String;
      var imageClassName = results['image-class-name'] as String;
      var fontClassName = results['font-class-name'] as String;
      var handleFontFile = results['handle-font-file'] as bool;
      var onlyAddFolder = results['only-add-folder'] as bool;
      var ignoreExtensions =
          (results['ignore-extensions'] as String)?.split(',')?.checkDot();
      var extraImageExtensions =
          (results['extra-image-extensions'] as String)?.split(',')?.checkDot();
      var extensionClassNameMappingEntries =
          (results['extension-class-name-mapping'] as String)
              ?.split(',')
              ?.map((item) {
        var keyValue = item.trim().split(':');
        if (keyValue.length == 2) {
          var key = keyValue[0].trim();
          key = key.startsWith('.') ? key.toLowerCase() : '.$key'.toLowerCase();
          var value = keyValue[1].trim();
          return MapEntry(key, value);
        } else {
          throw Exception(
              'Invalid extension class name mapping value $keyValue');
        }
      });
      var extensionClassNameMapping = null != extensionClassNameMappingEntries
          ? Map.fromEntries(extensionClassNameMappingEntries)
          : null;
      return ResourceConfig(
        resourcePath: resourcePath,
        imageClassName: imageClassName,
        fontClassName: fontClassName,
        handleFontFile: handleFontFile,
        onlyAddFolder: onlyAddFolder,
        ignoreExtensions: ignoreExtensions,
        extraImageExtensions: extraImageExtensions,
        extensionClassNameMapping: extensionClassNameMapping,
      );
    } else {
      throw Exception('Resource path is empty');
    }
  }
}

extension _ExtensionDotChecker on List<String> {
  List<String> checkDot() {
    return map((extension) {
      extension = extension.trim();
      return extension.startsWith('.')
          ? extension.toLowerCase()
          : '.$extension'.toLowerCase();
    }).toList();
  }
}
