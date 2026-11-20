// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/pulse_provider.dart';
import '../screens/legal_screen.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulseState = ref.watch(pulseProvider);
    final notifier = ref.read(pulseProvider.notifier);
    final weeklyData = notifier.getWeeklyChartData();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    int totalMinutesEver = pulseState.sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    double totalHoursEver = totalMinutesEver / 60;

    double maxDayHours = weeklyData.fold(0.0, (max, day) => day['hours'] > max ? day['hours'] : max);
    if (maxDayHours < 2.0) maxDayHours = 2.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total Sessions', '${pulseState.sessions.length}', textColor, subTextColor, primaryColor),
                Container(width: 1, height: 40, color: dividerColor),
                _buildStatColumn('Total Hours', '${totalHoursEver.toStringAsFixed(1)}h', textColor, subTextColor, primaryColor),
                Container(width: 1, height: 40, color: dividerColor),
                _buildStatColumn('Daily Target', '${pulseState.dailyGoalHours.toStringAsFixed(1)}h', textColor, subTextColor, primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Weekly Breakdown Bar Chart Section
          Text(
            'Weekly Focus Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Your focus hours over the last 7 days',
            style: TextStyle(color: subTextColor, fontSize: 13),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
            ),
            child: SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weeklyData.map((dayData) {
                  final double hours = dayData['hours'];
                  final String label = dayData['label'];
                  final double heightFactor = (hours / maxDayHours).clamp(0.05, 1.0);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${hours.toStringAsFixed(1)}h',
                        style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 24,
                        height: 120 * heightFactor,
                        decoration: BoxDecoration(
                          color: hours > 0 ? primaryColor : (isDark ? Colors.white10 : Colors.black12),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: hours > 0
                              ? [BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 8)]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        label,
                        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Vault & History Backup Card
          _buildExportVaultCard(context, ref, cardColor, textColor, subTextColor, primaryColor, isDark),
          const SizedBox(height: 24),

          // History Auto-Cleanup Settings Card
          _buildHistoryCleanupCard(context, ref, cardColor, textColor, subTextColor, primaryColor, isDark),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, Color textColor, Color subTextColor, Color primaryColor) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: subTextColor, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildExportVaultCard(BuildContext context, WidgetRef ref, Color cardColor, Color textColor, Color subTextColor, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📦 Vault & History Export',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Directly share your completed sessions, stats, and notes backup with other apps.',
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      final jsonBackup = ref.read(pulseProvider.notifier).exportUserDataAsJson();
                      Clipboard.setData(ClipboardData(text: jsonBackup));

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('⚡ JSON copied to clipboard!'),
                          backgroundColor: primaryColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_all, size: 18),
                    label: const Text('Copy', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final jsonBackup = ref.read(pulseProvider.notifier).exportUserDataAsJson();

                      if (Theme.of(context).platform == TargetPlatform.android ||
                          Theme.of(context).platform == TargetPlatform.iOS) {
                        await Share.share(
                          jsonBackup,
                          subject: 'Dev Pulse Vault Backup (${DateTime.now().toLocal().toString().split(' ')[0]})',
                        );
                      } else {
                        Clipboard.setData(ClipboardData(text: jsonBackup));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('⚡ Vault JSON copied to clipboard (Desktop/Web fallback)!'),
                            backgroundColor: primaryColor,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share App', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCleanupCard(BuildContext context, WidgetRef ref, Color cardColor, Color textColor, Color subTextColor, Color primaryColor, bool isDark) {
    final pulseState = ref.watch(pulseProvider);
    final currentMonths = pulseState.autoCleanupMonths;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧹 History Auto-Cleanup',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Automatically purge old focus logs to keep your storage light and responsive.',
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Auto-Delete Older Than:', style: TextStyle(color: textColor, fontSize: 13)),
              DropdownButton<int>(
                dropdownColor: cardColor,
                value: currentMonths,
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                underline: Container(height: 1, color: primaryColor),
                items: [
                  DropdownMenuItem(value: 1, child: Text('1 Month', style: TextStyle(color: textColor))),
                  DropdownMenuItem(value: 3, child: Text('3 Months', style: TextStyle(color: textColor))),
                  DropdownMenuItem(value: 6, child: Text('6 Months', style: TextStyle(color: textColor))),
                  DropdownMenuItem(value: 0, child: Text('Keep Forever', style: TextStyle(color: textColor))),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    HapticFeedback.lightImpact();
                    ref.read(pulseProvider.notifier).updateAutoCleanupPolicy(newValue);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          newValue > 0
                              ? '⚡ Retention updated: Deleting sessions older than $newValue month(s).'
                              : '⚡ Auto-cleanup disabled. Keeping all history.',
                        ),
                        backgroundColor: primaryColor,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF5252),
                side: const BorderSide(color: Color(0xFFFF5252)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: cardColor,
                    title: Text('Clear All Session History?', style: TextStyle(color: textColor)),
                    content: Text(
                      'This will permanently delete all logged focus sessions. Make sure you exported a backup first!',
                      style: TextStyle(color: subTextColor),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Cancel', style: TextStyle(color: subTextColor)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5252)),
                        onPressed: () {
                          ref.read(pulseProvider.notifier).clearAllHistory();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🗑️ All focus history deleted.'),
                              backgroundColor: Color(0xFFFF5252),
                            ),
                          );
                        },
                        child: const Text('Delete All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Purge History Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // --- Privacy Policy Button ---
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LegalScreen(
                    title: 'Privacy Policy',
                    content: privacyPolicyText,
                  ),
                ),
              );
            },
          ),

          // --- Terms & Conditions Button ---
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LegalScreen(
                    title: 'Terms & Conditions',
                    content: termsConditionsText,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}