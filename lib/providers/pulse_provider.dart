// lib/providers/pulse_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/session_model.dart';
import '../services/notification_service.dart';

class SubTask {
  final String title;
  bool isCompleted;

  SubTask({required this.title, this.isCompleted = false});
}

class ActiveSession {
  final String projectName;
  final int totalMinutes;
  int secondsRemaining;
  final String taskDescription;
  final String tag;
  final List<SubTask> subTasks;

  ActiveSession({
    required this.projectName,
    required this.totalMinutes,
    required this.secondsRemaining,
    required this.taskDescription,
    this.tag = 'Feature',
    required this.subTasks,
  });
}

class PulseState {
  final List<FocusSession> sessions;
  final ActiveSession? activeSession;
  final double dailyGoalHours;
  final int autoCleanupMonths;
  final String? activeAmbientSound;
  final bool isAmbientPlaying;
  final bool isBreakMode;
  final bool isBreakActive;
  final int breakSecondsRemaining;
  final int pausedFocusSecondsRemaining;
  final String pausedProjectName;
  final String pausedTaskDescription;
  final String pausedTag;
  final bool isAutoIntervalMode;
  final int intervalBreakMinutes;
  final int lastFocusDurationSeconds;

  PulseState({
    required this.sessions,
    this.activeSession,
    this.dailyGoalHours = 2.0,
    this.autoCleanupMonths = 1,
    this.activeAmbientSound,
    this.isAmbientPlaying = false,
    this.isBreakMode = false,
    this.isBreakActive = false,
    this.breakSecondsRemaining = 0,
    this.pausedFocusSecondsRemaining = 0,
    this.pausedProjectName = 'Deep Work',
    this.pausedTaskDescription = '',
    this.pausedTag = 'Feature',
    this.isAutoIntervalMode = false,
    this.intervalBreakMinutes = 5,
    this.lastFocusDurationSeconds = 15 * 60,
  });

  PulseState copyWith({
    List<FocusSession>? sessions,
    ActiveSession? activeSession,
    double? dailyGoalHours,
    int? autoCleanupMonths,
    bool clearActive = false,
    String? activeAmbientSound,
    bool? isAmbientPlaying,
    bool clearAmbient = false,
    bool? isBreakMode,
    bool? isBreakActive,
    int? breakSecondsRemaining,
    int? pausedFocusSecondsRemaining,
    String? pausedProjectName,
    String? pausedTaskDescription,
    String? pausedTag,
    bool? isAutoIntervalMode,
    int? intervalBreakMinutes,
    int? lastFocusDurationSeconds,
  }) {
    return PulseState(
      sessions: sessions ?? this.sessions,
      activeSession: clearActive ? null : (activeSession ?? this.activeSession),
      dailyGoalHours: dailyGoalHours ?? this.dailyGoalHours,
      autoCleanupMonths: autoCleanupMonths ?? this.autoCleanupMonths,
      activeAmbientSound: clearAmbient ? null : (activeAmbientSound ?? this.activeAmbientSound),
      isAmbientPlaying: isAmbientPlaying ?? this.isAmbientPlaying,
      isBreakMode: isBreakMode ?? this.isBreakMode,
      isBreakActive: isBreakActive ?? this.isBreakActive,
      breakSecondsRemaining: breakSecondsRemaining ?? this.breakSecondsRemaining,
      pausedFocusSecondsRemaining: pausedFocusSecondsRemaining ?? this.pausedFocusSecondsRemaining,
      pausedProjectName: pausedProjectName ?? this.pausedProjectName,
      pausedTaskDescription: pausedTaskDescription ?? this.pausedTaskDescription,
      pausedTag: pausedTag ?? this.pausedTag,
      isAutoIntervalMode: isAutoIntervalMode ?? this.isAutoIntervalMode,
      intervalBreakMinutes: intervalBreakMinutes ?? this.intervalBreakMinutes,
      lastFocusDurationSeconds: lastFocusDurationSeconds ?? this.lastFocusDurationSeconds,
    );
  }
}

class PulseNotifier extends StateNotifier<PulseState> {
  Timer? _ticker;
  Timer? _breakTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  PulseNotifier() : super(PulseState(sessions: [])) {
    _loadSessions();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _ticker?.cancel();
    _breakTimer?.cancel();
    super.dispose();
  }

  void _loadSessions() {
    final box = Hive.box('pulseBox');
    final rawData = box.get('sessions', defaultValue: []) as List<dynamic>;
    final loadedSessions = rawData.map((e) => FocusSession.fromMap(Map<String, dynamic>.from(e))).toList();
    final goal = box.get('dailyGoalHours', defaultValue: 2.0) as double;
    final cleanupMonths = box.get('autoCleanupMonths', defaultValue: 1) as int;
    final isAutoInterval = box.get('isAutoIntervalMode', defaultValue: false) as bool;
    final breakMins = box.get('intervalBreakMinutes', defaultValue: 5) as int;

    state = state.copyWith(
      sessions: loadedSessions,
      dailyGoalHours: goal,
      autoCleanupMonths: cleanupMonths,
      isAutoIntervalMode: isAutoInterval,
      intervalBreakMinutes: breakMins,
    );

    // Run initial cleanup on startup based on set retention policy
    if (cleanupMonths > 0) {
      cleanOldHistory(cleanupMonths);
    }
  }

  void updateDailyGoal(double newGoal) {
    state = state.copyWith(dailyGoalHours: newGoal);
    final box = Hive.box('pulseBox');
    box.put('dailyGoalHours', newGoal);
  }

  void toggleAutoIntervalMode(bool enabled) {
    state = state.copyWith(isAutoIntervalMode: enabled);
    final box = Hive.box('pulseBox');
    box.put('isAutoIntervalMode', enabled);
  }

  void setIntervalBreakMinutes(int minutes) {
    state = state.copyWith(intervalBreakMinutes: minutes);
    final box = Hive.box('pulseBox');
    box.put('intervalBreakMinutes', minutes);
  }

  /// Updates the auto-cleanup policy setting (e.g., 1 month, 3 months, or Never)
  void updateAutoCleanupPolicy(int months) {
    state = state.copyWith(autoCleanupMonths: months);
    final box = Hive.box('pulseBox');
    box.put('autoCleanupMonths', months);

    if (months > 0) {
      cleanOldHistory(months);
    }
  }

  /// Filters out and deletes sessions older than the specified number of months
  void cleanOldHistory(int months) {
    if (months <= 0) return;

    final cutoffDate = DateTime.now().subtract(Duration(days: months * 30));
    final filteredSessions = state.sessions.where((s) => s.completedAt.isAfter(cutoffDate)).toList();

    if (filteredSessions.length != state.sessions.length) {
      state = state.copyWith(sessions: filteredSessions);
      final box = Hive.box('pulseBox');
      box.put('sessions', filteredSessions.map((s) => s.toMap()).toList());
    }
  }

  /// Manually wipes all session history
  void clearAllHistory() {
    state = state.copyWith(sessions: []);
    final box = Hive.box('pulseBox');
    box.put('sessions', []);
  }

  Future<void> toggleAmbientSound(String soundName) async {
    if (state.activeAmbientSound == soundName && state.isAmbientPlaying) {
      await _audioPlayer.stop();
      state = state.copyWith(isAmbientPlaying: false);
    } else {
      String assetPath = '';
      switch (soundName) {
        case 'Rain Ambiance':
          assetPath = 'audio/rain.wav';
          break;
        case 'Relaxing Melody':
          assetPath = 'audio/relax.mp3';
          break;
        case 'Soft Water':
          assetPath = 'audio/soft_water.wav';
          break;
        default:
          assetPath = 'audio/rain.wav';
      }

      try {
        await _audioPlayer.stop();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource(assetPath));

        state = state.copyWith(activeAmbientSound: soundName, isAmbientPlaying: true);
      } catch (e) {
        state = state.copyWith(activeAmbientSound: soundName, isAmbientPlaying: false);
      }
    }
  }

  Future<void> stopAmbientSound() async {
    await _audioPlayer.stop();
    state = state.copyWith(isAmbientPlaying: false, clearAmbient: true);
  }

  bool startActiveSession(String project, int totalSeconds, String task, String tag, List<String> taskTitles) {
    if (state.activeSession != null || state.isBreakActive) {
      return false;
    }

    _ticker?.cancel();

    final int minutes = (totalSeconds / 60).ceil();
    final subTasksList = taskTitles.map((t) => SubTask(title: t)).toList();

    final newActive = ActiveSession(
      projectName: project,
      totalMinutes: minutes > 0 ? minutes : 1,
      secondsRemaining: totalSeconds,
      taskDescription: task,
      tag: tag.trim().isEmpty ? 'General' : tag.trim(),
      subTasks: subTasksList,
    );

    state = state.copyWith(
      activeSession: newActive,
      isBreakActive: false,
      lastFocusDurationSeconds: totalSeconds,
      pausedProjectName: project,
      pausedTaskDescription: task,
      pausedTag: tag,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.activeSession == null) {
        timer.cancel();
        return;
      }

      if (state.activeSession!.secondsRemaining > 1) {
        final remaining = state.activeSession!.secondsRemaining - 1;

        if (remaining <= 10) {
          try {
            final tickPlayer = AudioPlayer();
            tickPlayer.play(AssetSource('audio/beep.mp3'));
          } catch (_) {}
        }

        final updatedActive = ActiveSession(
          projectName: state.activeSession!.projectName,
          totalMinutes: state.activeSession!.totalMinutes,
          secondsRemaining: remaining,
          taskDescription: state.activeSession!.taskDescription,
          tag: state.activeSession!.tag,
          subTasks: state.activeSession!.subTasks,
        );
        state = state.copyWith(activeSession: updatedActive);
      } else {
        completeActiveSession();
      }
    });

    return true;
  }

  void startBreak(int minutes) {
    final currentActive = state.activeSession;

    _ticker?.cancel();

    if (currentActive != null) {
      state = state.copyWith(
        pausedFocusSecondsRemaining: currentActive.secondsRemaining,
        pausedProjectName: currentActive.projectName,
        pausedTaskDescription: currentActive.taskDescription,
        pausedTag: currentActive.tag,
        activeSession: null,
        isBreakActive: true,
        breakSecondsRemaining: minutes * 60,
      );
    } else {
      state = state.copyWith(
        clearActive: true,
        isBreakActive: true,
        breakSecondsRemaining: minutes * 60,
      );
    }

    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.breakSecondsRemaining > 1) {
        final remainingBreak = state.breakSecondsRemaining - 1;

        if (remainingBreak <= 10) {
          try {
            final tickPlayer = AudioPlayer();
            tickPlayer.play(AssetSource('audio/beep.mp3'));
          } catch (_) {}
        }

        state = state.copyWith(breakSecondsRemaining: remainingBreak);
      } else {
        _breakTimer?.cancel();
        _onBreakFinished();
      }
    });
  }

  Future<void> _onBreakFinished() async {
    try {
      final beepPlayer = AudioPlayer();
      await beepPlayer.play(AssetSource('audio/beep.mp3'));
    } catch (_) {}

    final project = state.pausedProjectName.isEmpty ? 'Deep Work' : state.pausedProjectName;
    final durationSecs = state.lastFocusDurationSeconds > 0 ? state.lastFocusDurationSeconds : 15 * 60;
    final durationMins = (durationSecs / 60).round();

    try {
      NotificationService.showTimerCompleteNotification(
        title: '⚡ Break Over — Focus Started Automatically!',
        body: 'Your break is over. Focus session "$project" (${durationMins}m) has automatically started!',
      );
    } catch (_) {}

    state = state.copyWith(isBreakActive: false, breakSecondsRemaining: 0);
    _resumeFocusAfterBreak();
  }

  void cancelBreak() {
    _breakTimer?.cancel();
    _resumeFocusAfterBreak();
  }

  void _resumeFocusAfterBreak() {
    final remaining = state.pausedFocusSecondsRemaining > 0 ? state.pausedFocusSecondsRemaining : 25 * 60;
    final int minutes = (remaining / 60).ceil();

    final restoredSession = ActiveSession(
      projectName: state.pausedProjectName,
      totalMinutes: minutes > 0 ? minutes : 1,
      secondsRemaining: remaining,
      taskDescription: state.pausedTaskDescription,
      tag: state.pausedTag,
      subTasks: [],
    );

    state = state.copyWith(
      isBreakActive: false,
      breakSecondsRemaining: 0,
      activeSession: restoredSession,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.activeSession == null) {
        timer.cancel();
        return;
      }

      if (state.activeSession!.secondsRemaining > 1) {
        final remainingSecs = state.activeSession!.secondsRemaining - 1;

        if (remainingSecs <= 10) {
          try {
            final tickPlayer = AudioPlayer();
            tickPlayer.play(AssetSource('audio/beep.mp3'));
          } catch (_) {}
        }

        final updatedActive = ActiveSession(
          projectName: state.activeSession!.projectName,
          totalMinutes: state.activeSession!.totalMinutes,
          secondsRemaining: remainingSecs,
          taskDescription: state.activeSession!.taskDescription,
          tag: state.activeSession!.tag,
          subTasks: state.activeSession!.subTasks,
        );
        state = state.copyWith(activeSession: updatedActive);
      } else {
        completeActiveSession();
      }
    });
  }

  void toggleSubTask(int index) {
    if (state.activeSession == null) return;
    final subTasks = state.activeSession!.subTasks;
    if (index >= 0 && index < subTasks.length) {
      subTasks[index].isCompleted = !subTasks[index].isCompleted;
      state = state.copyWith(
        activeSession: ActiveSession(
          projectName: state.activeSession!.projectName,
          totalMinutes: state.activeSession!.totalMinutes,
          secondsRemaining: state.activeSession!.secondsRemaining,
          taskDescription: state.activeSession!.taskDescription,
          tag: state.activeSession!.tag,
          subTasks: [...subTasks],
        ),
      );
    }
  }

  Future<void> completeActiveSession() async {
    _ticker?.cancel();
    _breakTimer?.cancel();
    if (state.activeSession == null) return;

    try {
      final beepPlayer = AudioPlayer();
      await beepPlayer.play(AssetSource('audio/beep.mp3'));
    } catch (_) {}

    final completed = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectName: '${state.activeSession!.projectName} [${state.activeSession!.tag}]',
      durationMinutes: state.activeSession!.totalMinutes,
      completedAt: DateTime.now(),
      taskDescription: state.activeSession!.taskDescription,
    );

    final updatedList = [...state.sessions, completed];
    final box = Hive.box('pulseBox');
    box.put('sessions', updatedList.map((s) => s.toMap()).toList());

    final isInterval = state.isAutoIntervalMode;
    final breakMins = state.intervalBreakMinutes;
    final focusSecs = state.activeSession!.totalMinutes * 60;
    final project = state.activeSession!.projectName;
    final task = state.activeSession!.taskDescription;
    final tag = state.activeSession!.tag;

    state = PulseState(
      sessions: updatedList,
      activeSession: null,
      dailyGoalHours: state.dailyGoalHours,
      autoCleanupMonths: state.autoCleanupMonths,
      isBreakActive: false,
      isAutoIntervalMode: isInterval,
      intervalBreakMinutes: breakMins,
      lastFocusDurationSeconds: focusSecs,
      pausedProjectName: project,
      pausedTaskDescription: task,
      pausedTag: tag,
    );

    try {
      NotificationService.showTimerCompleteNotification(
        title: '☕ Focus Complete — Break Started Automatically!',
        body: isInterval
            ? 'Great job! Focus session "$project" is complete. Starting $breakMins min break automatically...'
            : 'Great job! Your focus session "$project" is complete.',
      );
    } catch (_) {}

    if (isInterval) {
      startBreak(breakMins);
    }
  }

  void cancelActiveSession() {
    _ticker?.cancel();
    _breakTimer?.cancel();
    state = state.copyWith(clearActive: true, isBreakActive: false, breakSecondsRemaining: 0);
  }

  String exportUserDataAsJson() {
    final sessionsData = state.sessions.map((s) => s.toMap()).toList();
    List<dynamic> rawNotes = [];
    if (Hive.isBoxOpen('notesBox')) {
      final notesBox = Hive.box('notesBox');
      rawNotes = notesBox.get('notes', defaultValue: []) as List<dynamic>;
    }

    final exportMap = {
      'appName': 'Dev Pulse',
      'exportDate': DateTime.now().toIso8601String(),
      'dailyGoalHours': state.dailyGoalHours,
      'sessions': sessionsData,
      'notes': rawNotes,
    };

    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  int get todayCompletedMinutes {
    final now = DateTime.now();
    return state.sessions
        .where((s) =>
    s.completedAt.year == now.year &&
        s.completedAt.month == now.month &&
        s.completedAt.day == now.day)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int get currentStreakDays {
    if (state.sessions.isEmpty) return 0;

    final dates = state.sessions
        .map((s) => DateTime(s.completedAt.year, s.completedAt.month, s.completedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (!dates.contains(today) && !dates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = dates.contains(today) ? today : yesterday;

    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int getMinutesForDate(DateTime date) {
    return state.sessions
        .where((s) =>
    s.completedAt.year == date.year &&
        s.completedAt.month == date.month &&
        s.completedAt.day == date.day)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  List getWeeklyChartData() {
    final now = DateTime.now();
    final weekData = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final minutes = getMinutesForDate(day);

      String dayLabel = '';
      switch (day.weekday) {
        case 1: dayLabel = 'Mon'; break;
        case 2: dayLabel = 'Tue'; break;
        case 3: dayLabel = 'Wed'; break;
        case 4: dayLabel = 'Thu'; break;
        case 5: dayLabel = 'Fri'; break;
        case 6: dayLabel = 'Sat'; break;
        case 7: dayLabel = 'Sun'; break;
      }

      weekData.add({
        'label': dayLabel,
        'date': day,
        'hours': minutes / 60.0,
        'minutes': minutes,
      });
    }

    return weekData;
  }
}

final pulseProvider = StateNotifierProvider<PulseNotifier, PulseState>((ref) {
  return PulseNotifier();
});