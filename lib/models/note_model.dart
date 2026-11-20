// lib/models/note_model.dart
class NoteModel {
  final String id;
  final String title;
  final String content;
  final String tag;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tag': tag,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      tag: map['tag'] ?? 'Snippet',
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}