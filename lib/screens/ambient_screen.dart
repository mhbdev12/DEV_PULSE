// lib/screens/ambient_screen.dart
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pulse_provider.dart';

class AmbientScreen extends ConsumerWidget {
  const AmbientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulseState = ref.watch(pulseProvider);
    final notifier = ref.read(pulseProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final sounds = [
      {'name': 'Rain Ambiance', 'icon': Icons.water_drop, 'desc': 'Natural rainfall for focus'},
      {'name': 'Relaxing Melody', 'icon': Icons.music_note, 'desc': 'Calm harmonic tones'},
      {'name': 'Soft Water', 'icon': Icons.water, 'desc': 'Gentle stream ambiance'},
    ];

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.headphones, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Neural Ambiance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 4),
                      Text('Select soundscapes to enhance your focus state', style: TextStyle(color: subTextColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Integrated Volume Slider Card
          const _VolumeSliderCard(),
          const SizedBox(height: 4),

          // Sound Cards List
          ...sounds.map((sound) {
            final name = sound['name'] as String;
            final isPlaying = pulseState.activeAmbientSound == name && pulseState.isAmbientPlaying;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPlaying ? primaryColor : primaryColor.withValues(alpha: 0.15),
                  width: isPlaying ? 2 : 1,
                ),
                boxShadow: isPlaying
                    ? [BoxShadow(color: primaryColor.withValues(alpha: 0.25), blurRadius: 12)]
                    : [],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Icon(
                  sound['icon'] as IconData,
                  color: isPlaying ? primaryColor : subTextColor,
                  size: 28,
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPlaying ? primaryColor : textColor,
                  ),
                ),
                subtitle: Text(
                  sound['desc'] as String,
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: primaryColor,
                    size: 36,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    notifier.toggleAmbientSound(name);
                  },
                ),
              ),
            );
          }),

          if (pulseState.isAmbientPlaying) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  notifier.stopAmbientSound();
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop Soundscape'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VolumeSliderCard extends StatefulWidget {
  const _VolumeSliderCard();

  @override
  State<_VolumeSliderCard> createState() => _VolumeSliderCardState();
}

class _VolumeSliderCardState extends State<_VolumeSliderCard> {
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Consumer(
      builder: (context, ref, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Soundscape Volume', style: TextStyle(color: subTextColor, fontSize: 13)),
                  Text('${(_volume * 100).toInt()}%', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                activeColor: primaryColor,
                inactiveColor: isDark ? Colors.white24 : Colors.black12,
                onChanged: (val) {
                  setState(() => _volume = val);
                  ref.read(pulseProvider.notifier).setVolume(val);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}