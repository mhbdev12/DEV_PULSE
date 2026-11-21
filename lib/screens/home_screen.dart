// lib/screens/home_screen.dart
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../providers/pulse_provider.dart';
import '../services/ad_manager.dart';
import '../widgets/persistent_banner.dart';
import 'ambient_screen.dart';
import 'analytics_screen.dart';
import 'notes_screen.dart';
import 'timer_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0;

  final TextEditingController _projectController =
  TextEditingController(text: 'Deep Work');
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _tagController =
  TextEditingController(text: 'Feature');

  final subtaskControllersList = [TextEditingController()];
  int _selectedDuration = 25;

  final quickSnippetsList = [
    {
      'title': 'Flutter Stateful Widget',
      'code':
      'class MyWidget extends StatefulWidget {\n  @override\n  State<MyWidget> createState() => _MyWidgetState();\n}'
    },
    {
      'title': 'Riverpod Consumer',
      'code': 'final myProvider = Provider((ref) => "Hello");'
    },
    {
      'title': 'HTTP Get Request',
      'code': 'final response = await http.get(Uri.parse(url));'
    },
  ];

  final TextEditingController _snippetTitleController =
  TextEditingController();
  final TextEditingController _snippetCodeController = TextEditingController();

  void _showAddSnippetDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final fieldColor =
    isDark ? const Color(0xFF0A0D14) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Quick Snippet 💻',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _snippetTitleController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Snippet Title',
                  labelStyle: TextStyle(color: textColor.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: fieldColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _snippetCodeController,
                style: TextStyle(color: textColor, fontFamily: 'monospace'),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Code Snippet',
                  labelStyle: TextStyle(color: textColor.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: fieldColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_snippetTitleController.text.isNotEmpty &&
                        _snippetCodeController.text.isNotEmpty) {
                      setState(() {
                        quickSnippetsList.add({
                          'title': _snippetTitleController.text.trim(),
                          'code': _snippetCodeController.text.trim(),
                        });
                      });
                      _snippetTitleController.clear();
                      _snippetCodeController.clear();
                      Navigator.of(context).pop();
                      HapticFeedback.mediumImpact();
                    }
                  },
                  child: const Text('Save Snippet',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStartSessionDialog(BuildContext context) {
    final presets = [15, 25, 50, 60];
    final tags = ['Feature', 'Bugfix', 'Refactor', 'Study'];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final fieldColor =
    isDark ? const Color(0xFF0A0D14) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start Focus Session ⚡',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _projectController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Activity / Project Name',
                    labelStyle: TextStyle(color: subTextColor),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tagController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Category Tag (e.g. Flutter, Backend, Study)',
                    labelStyle: TextStyle(color: subTextColor),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: tags.map((tag) {
                    final isSelected = _tagController.text == tag;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: ChoiceChip(
                          label: Center(
                              child: Text(tag,
                                  style: const TextStyle(fontSize: 11))),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: fieldColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) {
                            HapticFeedback.lightImpact();
                            setModalState(() {
                              _tagController.text = tag;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Select Duration:',
                    style: TextStyle(color: subTextColor, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: presets.map((mins) {
                    final isSelected = _selectedDuration == mins;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Center(child: Text('${mins}m')),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: fieldColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) {
                            HapticFeedback.lightImpact();
                            setModalState(() => _selectedDuration = mins);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _taskController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Overall Goal (Optional)',
                    labelStyle: TextStyle(color: subTextColor),
                    filled: true,
                    fillColor: fieldColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sub-Checklist (Optional):',
                        style: TextStyle(color: subTextColor, fontSize: 13)),
                    TextButton.icon(
                      onPressed: () {
                        setModalState(() {
                          subtaskControllersList.add(TextEditingController());
                        });
                      },
                      icon: Icon(Icons.add, size: 16, color: primaryColor),
                      label: Text('Add Step',
                          style: TextStyle(color: primaryColor)),
                    ),
                  ],
                ),
                ...subtaskControllersList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: TextStyle(color: textColor, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Step ${index + 1}',
                              labelStyle: TextStyle(color: subTextColor),
                              filled: true,
                              fillColor: fieldColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        if (subtaskControllersList.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.redAccent),
                            onPressed: () {
                              setModalState(() {
                                subtaskControllersList.removeAt(index);
                              });
                            },
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final project = _projectController.text.trim();
                      final task = _taskController.text.trim();
                      final tag = _tagController.text.trim();
                      final subTaskTitles = subtaskControllersList
                          .map((c) => c.text.trim())
                          .where((t) => t.isNotEmpty)
                          .toList();

                      if (project.isNotEmpty) {
                        final success = ref
                            .read(pulseProvider.notifier)
                            .startActiveSession(
                          project,
                          _selectedDuration * 60,
                          task.isEmpty ? 'Live Focus Run' : task,
                          tag.isEmpty ? 'Feature' : tag,
                          subTaskTitles,
                        );

                        Navigator.of(context).pop();

                        if (!success) {
                          HapticFeedback.heavyImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '⚠️ An activity or break is already running!'),
                              backgroundColor: Colors.amber,
                            ),
                          );
                        } else {
                          HapticFeedback.mediumImpact();
                          _taskController.clear();
                          subtaskControllersList.clear();
                          subtaskControllersList.add(TextEditingController());

                          // Trigger capped interstitial ad when starting focus session
                          adManager.showInterstitialAd();
                        }
                      }
                    },
                    child: const Text('Start Live Timer',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    final goals = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
    final currentGoal = ref.read(pulseProvider).dailyGoalHours;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Daily Focus Goal',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals.map((hours) {
            final isSelected = currentGoal == hours;
            return ListTile(
              title: Text('${hours.toInt()} Hours / day',
                  style: TextStyle(
                      color: isSelected ? primaryColor : textColor,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal)),
              trailing: isSelected
                  ? Icon(Icons.check, color: primaryColor)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(pulseProvider.notifier).updateDailyGoal(hours);
                Navigator.of(context).pop();

                // Trigger interstitial ad when changing key settings like goals
                adManager.showInterstitialAd();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final pulseState = ref.watch(pulseProvider);
    final notifier = ref.read(pulseProvider.notifier);
    final active = pulseState.activeSession;
    final isBreak = pulseState.isBreakActive;

    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final innerBoxColor =
    isDark ? const Color(0xFF0A0D14) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    int totalMinutes =
    pulseState.sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    double totalHours = totalMinutes / 60;

    int todayMinutes = notifier.todayCompletedMinutes;
    double todayHours = todayMinutes / 60;
    double goalProgress =
    (todayHours / pulseState.dailyGoalHours).clamp(0.0, 1.0);
    int streak = notifier.currentStreakDays;

    final pages = [
      ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Focus Time',
                        style: TextStyle(color: subTextColor, fontSize: 14)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥 ', style: TextStyle(fontSize: 12)),
                              Text('$streak Day Streak',
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.amber
                                          : Colors.amber.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.edit, size: 16, color: primaryColor),
                          tooltip: 'Edit Daily Goal',
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showGoalDialog(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${totalHours.toStringAsFixed(1)} Hours',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today: ${todayHours.toStringAsFixed(1)} / ${pulseState.dailyGoalHours.toStringAsFixed(1)} hrs target',
                      style: TextStyle(
                          color: textColor.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    Text('${(goalProgress * 100).toInt()}%',
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: goalProgress,
                    minHeight: 8,
                    backgroundColor:
                    isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // QUICK CODE SNIPPETS SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('⚡ QUICK CODE SNIPPETS',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 1.2)),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showAddSnippetDialog(context);
                },
                icon: Icon(Icons.add, size: 16, color: primaryColor),
                label: Text('Add', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          quickSnippetsList.isEmpty
              ? Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: primaryColor.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    'No snippets saved. Tap "+ Add" to create one!',
                    style: TextStyle(color: subTextColor, fontSize: 13),
                  ),
                )
              : SizedBox(
                  height: 115,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: quickSnippetsList.length,
                    itemBuilder: (context, index) {
                      final snippet = quickSnippetsList[index];
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: primaryColor.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    snippet['title'] ?? '',
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(
                                            ClipboardData(text: snippet['code'] ?? ''));
                                        HapticFeedback.mediumImpact();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('📋 Copied: ${snippet['title']}'),
                                            backgroundColor: primaryColor,
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.copy,
                                          size: 16, color: primaryColor),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        final title = snippet['title'] ?? 'Snippet';
                                        HapticFeedback.mediumImpact();
                                        setState(() {
                                          quickSnippetsList.removeAt(index);
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('🗑️ Removed: $title'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: const Icon(Icons.delete_outline,
                                          size: 16, color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: innerBoxColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            snippet['code'] ?? '',
                            style: TextStyle(
                                color: textColor.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontFamily: 'monospace'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          if (isBreak) ...[
            const Text('☕ REST & RECHARGE BREAK',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.free_breakfast,
                        color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Break Active',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 2),
                        Text('Paused: ${pulseState.pausedProjectName}',
                            style:
                            TextStyle(color: subTextColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(pulseState.breakSecondsRemaining),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill,
                        color: Colors.amber, size: 28),
                    tooltip: 'Resume Focus Now',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(pulseProvider.notifier).cancelBreak();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (active != null) ...[
            Text('🔥 CURRENT ACTIVITY',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.2)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bolt, color: primaryColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(active.projectName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: textColor)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color:
                                        primaryColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(active.tag,
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(active.taskDescription,
                                style: TextStyle(
                                    color: subTextColor, fontSize: 13)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(active.secondsRemaining),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: subTextColor, size: 20),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(pulseProvider.notifier)
                                  .cancelActiveSession();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber.shade700,
                        side: BorderSide(color: Colors.amber.shade700),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(pulseProvider.notifier).startBreak(5);
                      },
                      icon: const Icon(Icons.coffee, size: 18),
                      label: const Text('Take 5m Break (Pause)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  if (active.subTasks.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text('Sub-Tasks:',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...active.subTasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      return CheckboxListTile(
                        value: task.isCompleted,
                        activeColor: primaryColor,
                        checkColor: isDark ? Colors.black : Colors.white,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          task.title,
                          style: TextStyle(
                            color: task.isCompleted ? subTextColor : textColor,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontSize: 13,
                          ),
                        ),
                        onChanged: (_) {
                          HapticFeedback.selectionClick();
                          ref.read(pulseProvider.notifier).toggleSubTask(index);
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text('Completed Focus History',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          const SizedBox(height: 12),
          pulseState.sessions.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Icon(Icons.timer_outlined,
                      size: 48, color: subTextColor),
                  const SizedBox(height: 12),
                  Text(
                    'No focus sessions completed yet.\nTap "Start Focus" below to begin!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subTextColor),
                  ),
                ],
              ),
            ),
          )
              : Column(
            children: pulseState.sessions.reversed.map((session) {
              return Card(
                color: cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.check_circle_outline,
                        color: secondaryColor),
                  ),
                  title: Text(session.projectName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  subtitle: Text(
                    'Focused for ${session.durationMinutes} mins',
                    style: TextStyle(color: subTextColor),
                  ),
                  trailing: Text(
                    '${session.durationMinutes}m',
                    style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      const TimerScreen(),
      const NotesScreen(),
      const AnalyticsScreen(),
      const AmbientScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
              ),
              child: Icon(
                _currentTab == 0
                    ? Icons.bolt
                    : _currentTab == 1
                    ? Icons.timer_outlined
                    : _currentTab == 2
                    ? Icons.code
                    : _currentTab == 3
                    ? Icons.insights
                    : Icons.headphones,
                size: 18,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _currentTab == 0
                  ? 'DEV PULSE ⚡'
                  : _currentTab == 1
                  ? 'FOCUS TIMER '
                  : _currentTab == 2
                  ? 'SNIPPETS VAULT '
                  : _currentTab == 3
                  ? 'ANALYTICS HUB '
                  : 'NEURAL AMBIANCE 🎧',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.2,
                color: primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: primaryColor,
            ),
            tooltip: themeMode == ThemeMode.dark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(themeModeProvider.notifier).state =
              themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: pages[_currentTab],
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Focus',
            style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          HapticFeedback.lightImpact();
          _showStartSessionDialog(context);
        },
      )
          : null,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PersistentBannerWidget(),
          BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentTab = index);
            },
            backgroundColor: cardColor,
            selectedItemColor: primaryColor,
            unselectedItemColor: subTextColor,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined),
                activeIcon: Icon(Icons.timer),
                label: 'Timer',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.note_alt_outlined),
                activeIcon: Icon(Icons.note_alt),
                label: 'Notes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.headphones_outlined),
                activeIcon: Icon(Icons.headphones),
                label: 'Ambiance',
              ),
            ],
          ),
        ],
      ),
    );
  }
}