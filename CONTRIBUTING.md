# Contributing

Thanks for contributing to the `fake_object` monorepo.

## Repository layout

- `packages/fake_object`: runtime package used by applications/tests.
- `packages/fake_object_annotation`: annotation-only package.
- `packages/fake_object_generator`: `build_runner` generator package.

## Prerequisites

- Dart SDK `>=2.17.0 <4.0.0`
- Optional (recommended): Melos for workspace scripts

```bash
dart pub global activate melos
```

## Local setup

Install dependencies per package:

```bash
cd packages/fake_object_annotation && dart pub get
cd ../fake_object && dart pub get
cd ../fake_object_generator && dart pub get
```

From repository root, you can run:

```bash
melos run analyze
melos run test
```

## Code generation workflow

When changing annotated models or generator behavior, regenerate fake files:

```bash
cd packages/fake_object
dart run build_runner build --delete-conflicting-outputs
```

Generated outputs:

- `packages/fake_object/test/support/fakes/**`
- `packages/fake_object/test/support/fakes.g.dart`

## Contribution guidelines

- Keep changes focused by package (runtime vs annotation vs generator).
- Prefer tests for behavior changes, especially in code generation paths.
- Do not manually edit generated files unless explicitly needed for debugging.
- Keep public APIs backward-compatible unless a breaking change is intentional.

## Pull request checklist

- [ ] `dart analyze` passes in all affected packages
- [ ] `dart test` passes in all affected packages
- [ ] `build_runner` output regenerated when required
- [ ] Documentation updated when APIs or workflows change
