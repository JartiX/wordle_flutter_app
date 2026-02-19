import 'package:flutter/foundation.dart';
import '../models/statistics_model.dart';
import '../services/statistics_service.dart';

class StatisticsController {
  final StatisticsService _service;

  late final StatisticsModel _statistics;

  final ValueNotifier<StatisticsModel> notifier = ValueNotifier<StatisticsModel>(
    StatisticsModel.initial(),
  );

  StatisticsModel get statistics => _statistics;

  StatisticsController(this._service);

  Future<void> load() async {
    _statistics = await _service.load();
    notifier.value = _statistics;
  }

  Future<void> recordGame({required bool won, int? attempts}) async {
    _statistics.recordGame(won: won, attempts: attempts);
    notifier.value = _statistics.copy();
    await _service.save(_statistics);
  }

  Future<void> reset() async {
    _statistics.reset();
    notifier.value = _statistics.copy();
    await _service.save(_statistics);
  }

  void dispose() {
    notifier.dispose();
  }
}
