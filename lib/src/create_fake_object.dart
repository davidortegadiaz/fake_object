import 'dart:mirrors';
import 'package:faker/faker.dart';

class CreateFakeObject {
  final _primitives = [int, double, String, bool, DateTime];
  final Faker _faker = Faker();

  bool _isPrimitive(Type type) {
    return _primitives.contains(type);
  }

  ClassMirror _getInstanceMirror(dynamic object) {
    var instanceMirror = reflect(object);
    return instanceMirror.type;
  }

  dynamic setFakeValues(dynamic object) {
    var map = <String, dynamic>{};
    var classMirror = _getInstanceMirror(object);
    for (var v in classMirror.declarations.values) {
      if (v is VariableMirror) {
        if (_isPrimitive(v.type.reflectedType)) {
          var name = MirrorSystem.getName(v.simpleName);
          map[name] = _fakerValue(v.type.reflectedType);
        } else {
          var typeMirror = reflectType(v.type.reflectedType);
          if (typeMirror is ClassMirror) {
            var instance = typeMirror.newInstance(Symbol(''), []).reflectee;
            map['${MirrorSystem.getName(v.simpleName)}'] = setFakeValues(instance);
          }
        }
      }
    }
    return map;
  }

  dynamic _fakerValue(Type type) {
    switch (type) {
      case int:
        return _faker.randomGenerator.integer(100);
        break;
      case double:
        return _faker.randomGenerator.decimal();
        break;
      case String:
        return _faker.lorem.word();
        break;
      case bool:
        return _faker.randomGenerator.boolean();
        break;
      case DateTime:
        return _faker.date;
        break;
      default:
    }
  }
}
