import 'package:fake_object/src/example/person.dart';
import 'package:test/test.dart';

import 'support/fakes.g.dart' as generated;

void main() {
  test('build_runner generates fake builders in test/support', () {
    final Person person = generated.fakePerson();

    expect(person.name, isNotEmpty);
    expect(person.age, inInclusiveRange(0, 120));
    expect(person.pet.name, isNotEmpty);
  });
}
