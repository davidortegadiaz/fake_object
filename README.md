# fake_object

Typed fake data generation for Dart projects, built as a monorepo.

The goal is to annotate your domain models once and generate reusable test fakes with `build_runner`, including nested objects and lists.

## Monorepo structure

- `packages/fake_object`: runtime APIs (`FakeRegistry`, `FakeContext`, defaults, `CreateFakeObject`).
- `packages/fake_object_annotation`: annotation package (`@Fakeable`).
- `packages/fake_object_generator`: code generator that emits fake builders into test support files.

## Quick start

### 1) Annotate your models

```dart
import 'package:fake_object/fake_object.dart';

@Fakeable()
class Pet {
  final String name;

  Pet({required this.name});
}

@Fakeable()
class Person {
  final String name;
  final int age;
  final Pet pet;

  Person({required this.name, required this.age, required this.pet});
}
```

### 2) Add dependencies

```yaml
dependencies:
  fake_object: any

dev_dependencies:
  build_runner: any
  fake_object_generator: any
```

### 3) Generate fake builders

```bash
cd packages/fake_object
dart run build_runner build --delete-conflicting-outputs
```

Generated files are emitted into:

- `test/support/fakes/**`
- `test/support/fakes.g.dart` (barrel export)

### 4) Use generated fakes in tests

```dart
import 'package:test/test.dart';

import 'support/fakes.g.dart' as generated;

void main() {
  test('creates person fake', () {
    final person = generated.fakePerson();
    final admin = generated.fakePerson(
      customize: (value, context) => value.copyWith(name: 'Admin', age: 30),
    );

    expect(person.name, isNotEmpty);
    expect(admin.name, 'Admin');
  });
}
```

## Workspace scripts

From repository root:

```bash
melos run analyze
melos run test
```

See `CONTRIBUTING.md` for development workflow and contribution guidelines.
