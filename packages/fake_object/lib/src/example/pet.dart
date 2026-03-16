import 'package:fake_object/fake_object.dart';

@Fakeable()
class Pet {
  final String name;

  Pet({required this.name});

  Pet copyWith({String? name}) {
    return Pet(name: name ?? this.name);
  }
}
