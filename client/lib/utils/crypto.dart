import 'package:uuid/uuid.dart';

String generateGameId() {
  return const Uuid().v4().substring(0, 8); // First 8 chars of UUID
}
