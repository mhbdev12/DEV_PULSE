// lib/screens/timer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pulse_provider.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  final _activityController = TextEditingController(text: 'Deep Work');
  int _selectedSeconds = 25 * 60; // Default 25 mins

  void _startTimer() {
    if (_selectedSeconds <= 0) return;

    final projectName = _activityController.text.trim().isEmpty ? 'Deep Work' : _activityController.text.trim();

    if (ref.read(pulseProvider).activeSession != null) {
      ref.read(pulseProvider.notifier).cancelActiveSession();
    }

    final success = ref.read(pulseProvider.notifier).startActiveSession(
      projectName,
      _selectedSeconds,
      'Live Timer Session',
      'Feature',
      [],
    );

    if (!success) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Could not start session.'),
          backgroundColor: Colors.amber,
        ),
      );
    }
  }

  void _setPreset(int minutes) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedSeconds = minutes * 60;
    });
  }

  void _showCustomTimeDialog() {
    final controller = TextEditingController(text: (_selectedSeconds ~/ 60).toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final fieldColor = isDark ? const Color(0xFF0A0D14) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Custom Duration (Minutes)', style: TextStyle(color: textColor, fontSize: 16)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Enter minutes (e.g. 45 or 120)',
            labelStyle: TextStyle(color: subTextColor),
            filled: true,
            fillColor: fieldColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: subTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: isDark ? Colors.black : Colors.white),
            onPressed: () {
              final mins = int.tryParse(controller.text.trim()) ?? 25;
              if (mins > 0) {
                setState(() {
                  _selectedSeconds = mins * 60;
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('Set Time', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Widget _buildQuickAmbianceBar(BuildContext context, WidgetRef ref) {
    final pulseState = ref.watch(pulseProvider);
    final isPlaying = pulseState.isAmbientPlaying;
    final activeSound = pulseState.activeAmbientSound ?? 'Rain Ambiance';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isPlaying ? Icons.headphones : Icons.headphones_outlined,
                color: isPlaying ? primaryColor : subTextColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isPlaying ? 'Playing: $activeSound' : 'Ambiance Paused',
                style: TextStyle(color: isPlaying ? primaryColor : subTextColor, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: primaryColor,
              size: 28,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(pulseProvider.notifier).toggleAmbientSound(activeSound);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pulseState = ref.watch(pulseProvider);
    final active = pulseState.activeSession;
    final isRunning = active != null;
    final isBreak = pulseState.isBreakActive;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;

    int currentSeconds = isBreak
        ? pulseState.breakSecondsRemaining
        : (isRunning ? active.secondsRemaining : _selectedSeconds);

    int totalSecs = isBreak
        ? (5 * 60)
        : (isRunning ? (active.totalMinutes * 60) : _selectedSeconds);

    double progress = totalSecs > 0 ? currentSeconds / totalSecs : 0.0;
    bool isUrgent = (isRunning || isBreak) && currentSeconds <= 10 && currentSeconds > 0;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _activityController,
              enabled: !isRunning && !isBreak,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Activity / Project Name',
                labelStyle: TextStyle(color: subTextColor),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 10),

            // Quick Ambiance Player Bar
            _buildQuickAmbianceBar(context, ref),

            const SizedBox(height: 10),

            // Circular Countdown Display
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: cardColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUrgent
                          ? Colors.redAccent
                          : (isBreak ? Colors.amberAccent : primaryColor),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(currentSeconds),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isUrgent ? Colors.redAccent : textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBreak ? '☕ BREAK TIME' : (isRunning ? active.projectName : 'READY'),
                      style: TextStyle(
                        color: isUrgent ? Colors.redAccent : (isBreak ? Colors.amberAccent : subTextColor),
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            if (!isRunning && !isBreak) ...[
              Text('Quick Presets', style: TextStyle(color: subTextColor, fontSize: 14)),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip('15m', 15, isDark, cardColor, textColor, primaryColor),
                  _presetChip('25m', 25, isDark, cardColor, textColor, primaryColor),
                  _presetChip('50m', 50, isDark, cardColor, textColor, primaryColor),
                  _presetChip('60m', 60, isDark, cardColor, textColor, primaryColor),
                  ActionChip(
                    label: const Text('∞ Custom'),
                    backgroundColor: cardColor,
                    labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showCustomTimeDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ] else if (isRunning && !isBreak) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amberAccent,
                    side: const BorderSide(color: Colors.amberAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref.read(pulseProvider.notifier).startBreak(5);
                  },
                  icon: const Icon(Icons.coffee),
                  label: const Text('Take 5m Break (Pause Session)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBreak
                      ? Colors.amberAccent.withValues(alpha: 0.2)
                      : (isRunning ? Colors.redAccent.withValues(alpha: 0.2) : primaryColor),
                  foregroundColor: isBreak
                      ? Colors.amberAccent
                      : (isRunning ? Colors.redAccent : (isDark ? Colors.black : Colors.white)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(
                    color: isBreak ? Colors.amberAccent : (isRunning ? Colors.redAccent : Colors.transparent),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  if (isBreak) {
                    ref.read(pulseProvider.notifier).cancelBreak();
                  } else if (isRunning) {
                    ref.read(pulseProvider.notifier).cancelActiveSession();
                  } else {
                    _startTimer();
                  }
                },
                child: Text(
                  isBreak
                      ? 'Resume Focus Session Now ⚡'
                      : (isRunning ? 'Cancel Timer' : 'Start Focus Session ⚡'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(String label, int minutes, bool isDark, Color cardColor, Color textColor, Color primaryColor) {
    final isSelected = _selectedSeconds == minutes * 60;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primaryColor,
      backgroundColor: cardColor,
      labelStyle: TextStyle(
        color: isSelected ? (isDark ? Colors.black : Colors.white) : textColor,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => _setPreset(minutes),
    );
  }
}