// lib/models/session_model.dart

class FocusSession {
  final String id;
  final String projectName;
  final int durationMinutes;
  final String taskDescription;
  final DateTime completedAt;

  FocusSession({
    required this.id,
    required this.projectName,
    required this.durationMinutes,
    required this.taskDescription,
    required this.completedAt,
  });

  // Converts the session object into a Map so it can be saved as JSON/Hive data
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectName': projectName,
      'durationMinutes': durationMinutes,
      'taskDescription': taskDescription,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  // Recreates a FocusSession object from saved database map data
  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] ?? '',
      projectName: map['projectName'] ?? 'General',
      durationMinutes: map['durationMinutes'] ?? 25,
      taskDescription: map['taskDescription'] ?? '',
      completedAt: DateTime.parse(map['completedAt']),
    );
  }
}