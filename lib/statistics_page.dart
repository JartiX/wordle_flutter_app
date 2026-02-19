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

  Widget _statRow(BuildContext context, String title, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textTheme.bodyMedium),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _statRow(
                          context,
                          "Игр сыграно",
                          stats.gamesPlayed.toString(),
                        ),
                        _statRow(context, "Победы", stats.gamesWon.toString()),
                        _statRow(
                          context,
                          "Текущая серия",
                          stats.currentStreak.toString(),
                        ),
                        _statRow(
                          context,
                          "Макс серия",
                          stats.maxStreak.toString(),
                        ),
                        _statRow(
                          context,
                          "Win rate",
                          "${stats.winRate.toStringAsFixed(1)}%",
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Победы по количеству попыток",
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  child: AttemptsBarChart(
                    winsByAttempts: stats.winsByAttempts,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    maxHeight: 120,
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () async {
                    audioController.playPop();
                    final confirmed = await showConfirmationDialog(
                      context,
                      "Сбросить статистику",
                      "Данные будут удалены без возможности восстановления.",
                      audioController: audioController,
                    );

                    if (confirmed ?? false) {
                      await statisticsController.reset();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Сбросить статистику"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
