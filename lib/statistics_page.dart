import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../controllers/statistics_controller.dart';
import '../controllers/audio_controller.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/attempts_bar_chart.dart';

class StatisticsPage extends StatelessWidget {
  final StatisticsController statisticsController;
  final AudioController audioController;

  const StatisticsPage({
    super.key,
    required this.statisticsController,
    required this.audioController,
  });

  Widget _statRow(
    BuildContext context,
    String title,
    String value, {
    required double scale,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(fontSize: 14 * scale),
          ),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16 * scale,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final size = MediaQuery.of(context).size;
    final widthScale = (size.width / 400).clamp(0.8, 1.3);
    final heightScale = (size.height / 700).clamp(0.8, 1.2);
    final scale = math.min(widthScale, heightScale);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Статистика"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            audioController.playClick();
            Navigator.pop(context);
          },
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: statisticsController.notifier,
        builder: (context, stats, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: EdgeInsets.only(bottom: 16 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16 * scale),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16 * scale),
                    child: Column(
                      children: [
                        _statRow(
                          context,
                          "Игр сыграно",
                          stats.gamesPlayed.toString(),
                          scale: scale,
                        ),
                        _statRow(
                          context,
                          "Победы",
                          stats.gamesWon.toString(),
                          scale: scale,
                        ),
                        _statRow(
                          context,
                          "Текущая серия",
                          stats.currentStreak.toString(),
                          scale: scale,
                        ),
                        _statRow(
                          context,
                          "Макс серия",
                          stats.maxStreak.toString(),
                          scale: scale,
                        ),
                        _statRow(
                          context,
                          "Win rate",
                          "${stats.winRate.toStringAsFixed(1)}%",
                          scale: scale,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16 * scale),

                Text(
                  "Победы по количеству попыток",
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: (textTheme.titleLarge?.fontSize ?? 20) * scale,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16 * scale),

                SizedBox(
                  height: 200 * scale,
                  child: AttemptsBarChart(
                    winsByAttempts: stats.winsByAttempts,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),

                SizedBox(height: 32 * scale),

                ElevatedButton(
                  onPressed: () async {
                    audioController.playPop();
                    final confirmed = await showConfirmationDialog(
                      context,
                      "Сбросить статистику",
                      "Данные будут удалены без возможности восстановления.",
                      audioController: audioController,
                    );
                    if (confirmed ?? false) await statisticsController.reset();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                  ),
                  child: Text(
                    "Сбросить статистику",
                    style: TextStyle(fontSize: 16 * scale),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
