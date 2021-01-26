import 'dart:mirrors';
import 'package:faker/faker.dart';
import 'package:intl/intl.dart';

class CreateFakeObject {
  final _primitives = [int, double, String, bool, DateTime];
  final Faker _faker = const Faker();

  bool _isPrimitive(Type type) {
    return _primitives.contains(type);
  }

  ClassMirror _getInstanceMirror(dynamic object) {
    final InstanceMirror instanceMirror = reflect(object);
    return instanceMirror.type;
  }

  bool _isList(TypeMirror type) {
    try {
      if (type is ClassMirror) {
        type.newInstance(const Symbol(''), []).reflectee as List;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  dynamic setFakeValues(dynamic object) {
    final Map<String, dynamic> map = <String, dynamic>{};
    final ClassMirror classMirror = _getInstanceMirror(object);
    for (final v in classMirror.declarations.values) {
      if (v is VariableMirror) {
        if (_isPrimitive(v.type.reflectedType)) {
          final String name = MirrorSystem.getName(v.simpleName);
          map[name] = _fakerValue(v.type.reflectedType);
        } else if (_isList(v.type)) {
          final Type listType = v.type.typeArguments[0].reflectedType;
          if (_isPrimitive(listType)) {
            map[MirrorSystem.getName(v.simpleName)] = List.filled(3, _fakerValue(listType));
          } else {
            final TypeMirror typeMirror = v.type.typeArguments[0];
            if (typeMirror is ClassMirror) {
              final instance = typeMirror.newInstance(const Symbol(''), []).reflectee;
              map[MirrorSystem.getName(v.simpleName)] = List.filled(2, setFakeValues(instance));
            }
          }
        } else {
          final TypeMirror typeMirror = v.type;
          if (typeMirror is ClassMirror) {
            final instance = typeMirror.newInstance(const Symbol(''), []).reflectee;
            map[MirrorSystem.getName(v.simpleName)] = setFakeValues(instance);
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
        return DateFormat('yyyy-MM-dd hh:mm:ss').format(_faker.date.dateTime(maxYear: 2020, minYear: 1980)).toString();
        break;
      default:
        return null;
    }
  }
}
