import '../models/types.dart';

class GameEvent {
  final String? error;
  final GameStatus status;
  GameEvent({this.error, required this.status});
}