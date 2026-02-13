import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Counter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'AI-Powered Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // ── AI Prediction State ──────────────────────────────────────────
  /// Stores the timestamp of every tap to learn the user's tapping pattern.
  final List<DateTime> _tapTimestamps = [];

  /// The predicted time (in seconds) until the next tap.
  double? _predictedNextTapIn;

  /// A live countdown that ticks toward the predicted next tap.
  double? _countdown;

  /// Timer that updates the countdown display every 100 ms.
  Timer? _countdownTimer;

  /// Minimum number of taps before the AI starts predicting.
  static const int _minTapsForPrediction = 5;

  // ── Core Logic ───────────────────────────────────────────────────

  void _incrementCounter() {
    final now = DateTime.now();

    setState(() {
      _counter++;
      _tapTimestamps.add(now);

      // Recalculate prediction after recording the new tap.
      _predictedNextTapIn = _calculatePrediction();
      _countdown = _predictedNextTapIn;
    });

    // Restart the live countdown timer.
    _startCountdownTimer();
  }

  /// Uses a **weighted moving average** of recent tap intervals to predict
  /// how many seconds until the user will tap again.
  ///
  /// More recent intervals are weighted more heavily so the model adapts
  /// quickly to changes in tapping speed — a simple but effective approach
  /// that mirrors the core idea behind exponential smoothing in time-series
  /// forecasting.
  double? _calculatePrediction() {
    if (_tapTimestamps.length < _minTapsForPrediction) return null;

    // Use the last 10 intervals (or fewer if not enough taps yet).
    final recentCount = (_tapTimestamps.length - 1).clamp(0, 10);
    if (recentCount == 0) return null;

    double weightedSum = 0;
    double totalWeight = 0;

    for (int i = 0; i < recentCount; i++) {
      final idx = _tapTimestamps.length - 1 - i;
      final interval =
          _tapTimestamps[idx]
              .difference(_tapTimestamps[idx - 1])
              .inMilliseconds /
          1000.0;

      // Weight: most recent interval gets the highest weight.
      final weight = (recentCount - i).toDouble();
      weightedSum += interval * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
  }

  /// Starts (or restarts) a periodic timer that decrements [_countdown]
  /// every 100 ms so the UI shows a live ticking prediction.
  void _startCountdownTimer() {
    _countdownTimer?.cancel();

    if (_predictedNextTapIn == null) return;

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        if (_countdown != null && _countdown! > 0) {
          _countdown = (_countdown! - 0.1).clamp(0.0, double.infinity);
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── UI Helpers ───────────────────────────────────────────────────

  /// Builds the AI prediction card shown below the counter.
  Widget _buildPredictionCard(BuildContext context) {
    if (_tapTimestamps.length < _minTapsForPrediction) {
      final remaining = _minTapsForPrediction - _tapTimestamps.length;
      return _infoCard(
        icon: Icons.psychology_outlined,
        title: 'AI is learning...',
        subtitle:
            'Tap $remaining more time${remaining == 1 ? '' : 's'} '
            'to activate prediction',
        color: Colors.grey.shade600,
      );
    }

    final prediction = _predictedNextTapIn;
    final countdown = _countdown;

    if (prediction == null) return const SizedBox.shrink();

    return _infoCard(
      icon: Icons.auto_awesome,
      title: 'AI Prediction',
      subtitle: countdown != null && countdown > 0
          ? 'Next tap in ${countdown.toStringAsFixed(1)}s '
                '(avg ${prediction.toStringAsFixed(1)}s)'
          : 'Waiting for your tap... '
                '(predicted ${prediction.toStringAsFixed(1)}s)',
      color: countdown != null && countdown > 0
          ? Colors.deepPurple
          : Colors.orange,
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows how many taps the AI has recorded.
  Widget _buildTapHistoryChip() {
    if (_tapTimestamps.isEmpty) return const SizedBox.shrink();

    return Chip(
      avatar: const Icon(Icons.timeline, size: 18),
      label: Text('${_tapTimestamps.length} taps recorded'),
    );
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _buildPredictionCard(context),
            const SizedBox(height: 8),
            _buildTapHistoryChip(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
