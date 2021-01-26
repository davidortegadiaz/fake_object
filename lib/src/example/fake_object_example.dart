import 'package:fake_object/src/create_fake_object.dart';
import 'package:fake_object/src/example/models/person.dart' as p;

void main() {
  final CreateFakeObject createFakeObject = CreateFakeObject();
  final p.Person person = p.Person();
  final Map<String, dynamic> map = createFakeObject.setFakeValues(person) as Map<String, dynamic>;
  final finalPerson = p.Person.fromMap(map);
  // ignore: avoid_print
  print(finalPerson.toString());
}
