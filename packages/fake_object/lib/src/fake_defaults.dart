import 'package:fake_object/src/fake_registry.dart';

void registerDefaultPrimitives(FakeRegistry registry) {
  registry.register<int>((context) => context.intInRange(0, 120));
  registry.register<double>((context) => context.decimal(max: 1000));
  registry.register<String>((context) => context.faker.lorem.word());
  registry.register<bool>((context) => context.random.nextBool());
  registry.register<DateTime>((context) {
    final int year = context.intInRange(1980, 2025);
    final int month = context.intInRange(1, 12);
    final int day = context.intInRange(1, 28);
    final int hour = context.intInRange(0, 23);
    final int minute = context.intInRange(0, 59);
    final int second = context.intInRange(0, 59);

    return DateTime(year, month, day, hour, minute, second);
  });
}
