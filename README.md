## Overview

Import resource file into pubspec.yaml and generate resource class automatically by build runner

## Getting Started

For example, there are some image files under your asset folder named `assets` which is located in the root folder of your project
```
project root/
    assets/
        iamge_a.jpg
        image_b.jpg
```

Firstly, add `flutter_resource_generator` and [build_runner](https://pub.dev/packages/build_runner) under `dev_dependency` in your pubspec.yaml
```
dev_dependencies:
  build_runner: ^1.8.1
  flutter_resource_generator: ^0.0.1
```
Then add `ResourceConfig` annotation on your app class
```
@ResourceConfig(resourcePath: 'assets/')
class MyApp extends StatelessWidget {}
```
Finally, run build runner command
```
flutter packages pub run build_runner build --delete-conflicting-outputs
```
After build runner finished, image file items have been added into pubsepc.yaml
```
flutter:
  assets:
    - assets/image_a.jpg
    - assets/image_b.jpg
```
and resource class has been create along with dart file which your app class located in, for example the dart
file is main.dart, then the generated resource class dart file will be main.resource.dart.

The content of the resource class will be some thing like
```
abstract class R_Image {
  static const String IMAGE_A = "assets/image_a.jpg"
  static const String IMAGE_B = "assets/image_b.jpg"
}
```
Then you can use `R_Image.IMAGE_A` to access this image at anywhere you want

## ResourceConfig
You can use ResourceConfig class to customize how to handle resource file, here is all the parameters you can modify:

* String resourcePath: The relative path of your asset file folder, for example 'assets/', must `NOT` be empty

* String imageClassName: The name of image resource class, by default, it is `R_Image`, can be null

* String fontClassName: The name of font resource class, by default, it is `R_Font`, can be null

* bool handleFontFile: Whether font file will be handled, by default, it is `false`, can be null

* List&lt;String&gt; ignoreExtensions: The file with extension existed in this list will be ignored, can be null

* List&lt;String&gt; extraImageExtensions: The file with extension existed in [".png", ".jpg", ".jpeg",
".gif", ".webp", ".icon", ".bmp", ".wbmp", ".svg"] or extraImageExtensions will be treat as image, can be null

* Map&lt;String, String&gt; extensionClassNameMapping: By default, the class name of other files will be
R_${extension}, for example, the resource class of json files will be `R_Json`. if you want customize the class
name of json file, like `JsonRes`, you can pass {".json", "JsonRes"}, can be null

## Font
Since font conifguration is very complex, family, weight and style can be set for each font file. You need to
set these paramters for every single font file to generate font resource information, the workload is the same
as directly add this parameters into pubspec file. So by default, we don't handle font file, if you set
`handleFontFile` to true, we will add every font file into pubspec file as separate font family, and the original
font section in pubspec file will be `OVERWRITE`.

For example, you have three font files in your resource folder
```
project root/
    assets/
        font_a.ttf
        font_b.ttf
        font_c.ttf
```
the generated font section in pubspec file will be something like
```
fonts:
    - family: font_a
      fonts:
        - asset: assets/font_a.ttf
    - family: font_b
      fonts:
        - asset: assets/font_b.ttf
    - family: font_c
      fonts:
        - asset: assets/font_c.ttf
```
No matter whether `handleFontFile` is true or false, font family resource class will be generated by parsing
every family item under fonts section in pubspec file, as the font section showed before, the generated font
class will be something like this
```
abstract class R_Font {
  static const String FONT_A = "assets/font_a.jpg"
  static const String FONT_B = "assets/font_b.jpg"
  static const String FONT_C = "assets/font_c.jpg"
}
```

## Ilegal char
Some char is legal for file name but ilegal for class or varaiable name, such as '-', these ilegal char will
be replaced by '_' in class name and variable name in generated resource class. And number 0-9 is ilegal as
first char for class and variable name, so if resource file name is start by number, '$' will be added as prefix.

## FAQ
Q. I add new resource file into project, then run build runner command, why new file is not added into pubsepc
file and resource class?
A. You need run 'flutter packages pub run build_runner clean' first

## Contact Info
ymyplss@hotmail.com