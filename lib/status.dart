import 'package:riverpod_annotation/riverpod_annotation.dart';

// This line tells Riverpod to look for the generated file
part 'status.g.dart';

@riverpod
String systemStatus(Ref ref) {
  return "System Online";
}
