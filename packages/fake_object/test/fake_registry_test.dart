import 'package:fake_object/fake_object.dart';
import 'package:test/test.dart';

void main() {
  test('creates primitive values with defaults', () {
    final FakeRegistry registry = FakeRegistry.withDefaults(seed: 42);

    final int intValue = registry.make<int>();
    final double doubleValue = registry.make<double>();
    final String stringValue = registry.make<String>();
    final bool boolValue = registry.make<bool>();
    final DateTime dateValue = registry.make<DateTime>();

    expect(intValue, inInclusiveRange(0, 120));
    expect(doubleValue, inInclusiveRange(0, 1000));
    expect(stringValue, isNotEmpty);
    expect(boolValue, anyOf(isTrue, isFalse));
    expect(dateValue.year, inInclusiveRange(1980, 2025));
  });
}
