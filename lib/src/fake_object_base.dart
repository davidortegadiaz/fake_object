import 'package:fake_object/src/create_fake_object.dart';
import 'package:fake_object/src/models/person.dart' as p;

void main() {
  var createFakeObject = CreateFakeObject();
  var person = p.Person();
  var map = createFakeObject.setFakeValues(person);
  var finalPerson = p.Person.fromMap(map);
  print(finalPerson.toString());
}
