import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

Builder fakeMirrorBuilder(BuilderOptions options) {
  return _FakeMirrorBuilder();
}

Builder fakeBarrelBuilder(BuilderOptions options) {
  return _FakeBarrelBuilder();
}

class _FakeMirrorBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const <String, List<String>>{
        '^lib/{{}}.dart': <String>['test/support/fakes/{{}}.fake.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    final LibraryElement library = await buildStep.resolver.libraryFor(
      buildStep.inputId,
    );
    final List<ClassElement> fakeableClasses = _fakeableClasses(library);
    if (fakeableClasses.isEmpty) {
      return;
    }

    final AssetId outputId = _fakeOutputFor(buildStep.inputId);
    final String source = _buildFileSource(
      packageName: buildStep.inputId.package,
      libraryPath: buildStep.inputId.path,
      outputPath: outputId.path,
      classes: fakeableClasses,
    );

    await buildStep.writeAsString(outputId, source);
  }
}

class _FakeBarrelBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => const <String, List<String>>{
        r'$package$': <String>['test/support/fakes.g.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final List<String> exports = <String>[];

    await for (final AssetId asset
        in buildStep.findAssets(Glob('lib/**.dart'))) {
      if (!await buildStep.resolver.isLibrary(asset)) {
        continue;
      }

      final LibraryElement library = await buildStep.resolver.libraryFor(asset);
      if (_fakeableClasses(library).isEmpty) {
        continue;
      }

      final String relativeLibPath = asset.path.substring('lib/'.length);
      final String fakePath =
          'fakes/${relativeLibPath.replaceAll('.dart', '.fake.dart')}';
      exports.add(fakePath);
    }

    exports.sort();

    final StringBuffer buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
      ..writeln('// ignore_for_file: directives_ordering')
      ..writeln();

    for (final String exportPath in exports) {
      buffer.writeln("export '$exportPath';");
    }

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, 'test/support/fakes.g.dart'),
      buffer.toString(),
    );
  }
}

List<ClassElement> _fakeableClasses(LibraryElement library) {
  return library.definingCompilationUnit.classes
      .where(_hasFakeableAnnotation)
      .where((ClassElement element) => !element.isAbstract)
      .toList();
}

bool _hasFakeableAnnotation(ClassElement element) {
  for (final ElementAnnotation annotation in element.metadata) {
    final DartObject? object = annotation.computeConstantValue();
    if (object == null) {
      continue;
    }

    final String annotationType = object.type?.getDisplayString(
          withNullability: false,
        ) ??
        '';
    if (annotationType == 'Fakeable') {
      return true;
    }
  }

  return false;
}

AssetId _fakeOutputFor(AssetId inputId) {
  final String relativeLibPath = inputId.path.substring('lib/'.length);
  final String fakePath =
      'test/support/fakes/${relativeLibPath.replaceAll('.dart', '.fake.dart')}';
  return AssetId(inputId.package, fakePath);
}

String _buildFileSource({
  required String packageName,
  required String libraryPath,
  required String outputPath,
  required List<ClassElement> classes,
}) {
  final Set<String> imports = <String>{
    "import 'package:$packageName/${libraryPath.substring('lib/'.length)}';",
    "import 'package:fake_object/src/fake_context.dart';",
    "import 'package:fake_object/src/fake_registry.dart';",
  };

  final StringBuffer body = StringBuffer();

  for (final ClassElement element in classes) {
    final _GeneratedClass generated = _generateForClass(
      packageName: packageName,
      classElement: element,
      currentOutputPath: outputPath,
    );
    imports.addAll(generated.imports);
    body.writeln(generated.source);
  }

  final List<String> orderedImports = imports.toList()..sort();

  final StringBuffer buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln(
      '// ignore_for_file: directives_ordering, lines_longer_than_80_chars',
    )
    ..writeln();

  for (final String importLine in orderedImports) {
    buffer.writeln(importLine);
  }

  buffer
    ..writeln()
    ..writeln(body.toString());

  return '${buffer.toString().trimRight()}\n';
}

_GeneratedClass _generateForClass({
  required String packageName,
  required ClassElement classElement,
  required String currentOutputPath,
}) {
  ConstructorElement? constructor;
  for (final ConstructorElement constructorElement
      in classElement.constructors) {
    if (constructorElement.name.isEmpty && !constructorElement.isFactory) {
      constructor = constructorElement;
      break;
    }
  }

  if (constructor == null) {
    throw StateError(
      'Class ${classElement.displayName} must declare a simple unnamed constructor.',
    );
  }

  if (classElement.typeParameters.isNotEmpty) {
    throw StateError(
      'Generic classes are not supported in Fakeable MVP: ${classElement.displayName}.',
    );
  }

  final Set<String> imports = <String>{};
  final Set<ClassElement> dependencies = <ClassElement>{};

  final String className = classElement.displayName;
  final String registerName = 'register${className}Fake';
  final String fakeName = 'fake$className';

  final StringBuffer argsBuffer = StringBuffer();
  for (final ParameterElement parameter in constructor.parameters) {
    if (parameter.isOptionalPositional || parameter.isRequiredPositional) {
      throw StateError(
        'Only named constructor parameters are supported in Fakeable MVP. '
        'Class: $className.',
      );
    }

    final String expression = _expressionForType(parameter.type);

    final ClassElement? dependency = _dependencyFromType(
      parameter.type,
      classElement,
    );
    if (dependency != null) {
      dependencies.add(dependency);
      final String? dependencyImport = _dependencyImportPath(
        packageName: packageName,
        currentOutputPath: currentOutputPath,
        dependencyClass: dependency,
      );
      if (dependencyImport != null) {
        imports.add("import '$dependencyImport';");
      }

      final String? dependencyModelImport = _dependencyModelImport(
        packageName: packageName,
        dependencyClass: dependency,
      );
      if (dependencyModelImport != null) {
        imports.add("import '$dependencyModelImport';");
      }
    }

    argsBuffer.writeln('      ${parameter.name}: $expression,');
  }

  final List<ClassElement> orderedDependencies = dependencies.toList()
    ..sort(
      (ClassElement a, ClassElement b) =>
          a.displayName.compareTo(b.displayName),
    );

  final StringBuffer dependencyBuffer = StringBuffer();
  for (final ClassElement dependency in orderedDependencies) {
    final String dependencyName = dependency.displayName;
    if (dependencyName == className) {
      continue;
    }

    dependencyBuffer
      ..writeln('  if (!registry.hasFactory<$dependencyName>()) {')
      ..writeln('    register${dependencyName}Fake(registry);')
      ..writeln('  }');
  }

  final String source = '''
void $registerName(FakeRegistry registry) {
  if (registry.hasFactory<$className>()) {
    return;
  }
$dependencyBuffer  registry.register<$className>((FakeContext context) {
    return $className(
$argsBuffer    );
  });
}

$className $fakeName({
  FakeRegistry? registry,
  $className Function($className value, FakeContext context)? customize,
}) {
  final FakeRegistry activeRegistry = registry ?? FakeRegistry.withDefaults();
  $registerName(activeRegistry);

  final FakeContext context = FakeContext.internal(activeRegistry, 0);
  final $className value = activeRegistry.make<$className>();

  if (customize != null) {
    return customize(value, context);
  }

  return value;
}
''';

  return _GeneratedClass(source: source, imports: imports);
}

String _expressionForType(DartType type) {
  final DartType normalizedType = _withoutNullability(type);

  if (normalizedType is InterfaceType && normalizedType.isDartCoreList) {
    if (normalizedType.typeArguments.length != 1) {
      throw StateError(
        'Only List<T> with one generic argument is supported.',
      );
    }

    final DartType itemType =
        _withoutNullability(normalizedType.typeArguments.first);
    final String itemTypeCode =
        itemType.getDisplayString(withNullability: false);
    return 'context.listOf<$itemTypeCode>()';
  }

  if (normalizedType is InterfaceType &&
      normalizedType.element is EnumElement) {
    final String enumName =
        normalizedType.getDisplayString(withNullability: false);
    return 'context.pick<$enumName>($enumName.values)';
  }

  final String typeCode =
      normalizedType.getDisplayString(withNullability: false);
  return 'context.make<$typeCode>()';
}

DartType _withoutNullability(DartType type) {
  return type;
}

ClassElement? _dependencyFromType(DartType type, ClassElement owner) {
  final DartType normalizedType = _withoutNullability(type);

  if (normalizedType is InterfaceType && normalizedType.isDartCoreList) {
    if (normalizedType.typeArguments.length != 1) {
      return null;
    }

    return _dependencyFromType(normalizedType.typeArguments.first, owner);
  }

  if (normalizedType is! InterfaceType) {
    return null;
  }

  if (normalizedType.element.library.isDartCore) {
    return null;
  }

  if (normalizedType.element is EnumElement) {
    return null;
  }

  final Element element = normalizedType.element;
  if (element is! ClassElement) {
    return null;
  }

  if (element == owner) {
    return element;
  }

  if (!_hasFakeableAnnotation(element)) {
    return null;
  }

  return element;
}

String? _dependencyImportPath({
  required String packageName,
  required String currentOutputPath,
  required ClassElement dependencyClass,
}) {
  final Uri uri = dependencyClass.librarySource.uri;

  if (uri.scheme != 'package') {
    return null;
  }

  final List<String> segments = uri.pathSegments;
  if (segments.isEmpty || segments.first != packageName) {
    return null;
  }

  final String relativeLibPath = segments.skip(1).join('/');
  final String dependencyFakePath =
      'test/support/fakes/${relativeLibPath.replaceAll('.dart', '.fake.dart')}';

  return path.posix.relative(
    dependencyFakePath,
    from: path.posix.dirname(currentOutputPath),
  );
}

String? _dependencyModelImport({
  required String packageName,
  required ClassElement dependencyClass,
}) {
  final Uri uri = dependencyClass.librarySource.uri;
  if (uri.scheme != 'package') {
    return null;
  }

  final List<String> segments = uri.pathSegments;
  if (segments.isEmpty) {
    return null;
  }

  if (segments.first == packageName) {
    final String relativePath = segments.skip(1).join('/');
    return 'package:$packageName/$relativePath';
  }

  return 'package:${uri.path}';
}

class _GeneratedClass {
  final String source;
  final Set<String> imports;

  _GeneratedClass({required this.source, required this.imports});
}
