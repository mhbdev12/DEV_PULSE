// lib/screens/notes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<NoteModel> _notes = [];
  String _selectedTagFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    final box = Hive.box('pulseBox');
    final rawData = box.get('notes', defaultValue: []) as List;
    setState(() {
      _notes = rawData.map((e) => NoteModel.fromMap(Map<String, dynamic>.from(e))).toList();
    });
  }

  void _saveNotesToHive() {
    final box = Hive.box('pulseBox');
    box.put('notes', _notes.map((n) => n.toMap()).toList());
  }

  List<String> _getAllTags() {
    final defaultTags = ['Coding', 'Study', 'Ideas', 'Commands'];
    final existingTags = _notes.map((n) => n.tag).where((t) => t.isNotEmpty).toSet();
    for (var tag in existingTags) {
      if (!defaultTags.contains(tag)) {
        defaultTags.add(tag);
      }
    }
    return defaultTags;
  }

  void _showAddEditNoteDialog({NoteModel? existingNote}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: existingNote?.title ?? '');
    final contentController = TextEditingController(text: existingNote?.content ?? '');
    final customTagController = TextEditingController();

    String? selectedTag = (existingNote?.tag != null && existingNote!.tag.isNotEmpty) ? existingNote.tag : null;
    bool isCustomTagging = false;
    final defaultTags = ['Coding', 'Study', 'Ideas', 'Commands'];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final fieldColor = isDark ? const Color(0xFF0A0D14) : const Color(0xFFF1F5F9);
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
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existingNote == null ? 'Add Quick Note / Snippet ⚡' : 'Edit Note',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Title / Subject',
                      labelStyle: TextStyle(color: subTextColor),
                      filled: true,
                      fillColor: fieldColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please write a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Select Tag (Optional):', style: TextStyle(color: subTextColor, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ...defaultTags.map((tag) {
                        final isSelected = !isCustomTagging && selectedTag == tag;
                        return ChoiceChip(
                          label: Text(tag),
                          selected: isSelected,
                          selectedColor: primaryColor,
                          backgroundColor: fieldColor,
                          labelStyle: TextStyle(
                            color: isSelected ? (isDark ? Colors.black : Colors.white) : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) {
                            setModalState(() {
                              isCustomTagging = false;
                              if (selectedTag == tag) {
                                selectedTag = null;
                              } else {
                                selectedTag = tag;
                              }
                            });
                          },
                        );
                      }),
                      ChoiceChip(
                        label: const Text('+ Custom Tag'),
                        selected: isCustomTagging,
                        selectedColor: primaryColor,
                        backgroundColor: fieldColor,
                        labelStyle: TextStyle(
                          color: isCustomTagging ? (isDark ? Colors.black : Colors.white) : textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setModalState(() {
                            isCustomTagging = !isCustomTagging;
                          });
                        },
                      ),
                    ],
                  ),
                  if (isCustomTagging) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: customTagController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Enter custom tag name',
                        labelStyle: TextStyle(color: subTextColor),
                        filled: true,
                        fillColor: fieldColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contentController,
                    maxLines: 5,
                    style: TextStyle(color: textColor, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      labelText: 'Code or text content...',
                      labelStyle: TextStyle(color: subTextColor),
                      filled: true,
                      fillColor: fieldColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please write content';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final title = titleController.text.trim();
                          final content = contentController.text.trim();

                          final finalTag = isCustomTagging && customTagController.text.trim().isNotEmpty
                              ? customTagController.text.trim()
                              : (selectedTag ?? '');

                          setState(() {
                            if (existingNote == null) {
                              _notes.add(NoteModel(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: title,
                                content: content,
                                tag: finalTag,
                                updatedAt: DateTime.now(),
                              ));
                            } else {
                              final index = _notes.indexWhere((n) => n.id == existingNote.id);
                              if (index != -1) {
                                _notes[index] = NoteModel(
                                  id: existingNote.id,
                                  title: title,
                                  content: content,
                                  tag: finalTag,
                                  updatedAt: DateTime.now(),
                                );
                              }
                            }
                          });
                          _saveNotesToHive();
                          Navigator.pop(context);
                        } else {
                          HapticFeedback.heavyImpact();
                        }
                      },
                      child: Text(existingNote == null ? 'Save Note' : 'Update Note', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((n) => n.id == id);
    });
    _saveNotesToHive();
  }

  @override
  Widget build(BuildContext context) {
    final allAvailableTags = ['All', ..._getAllTags()];
    final filteredNotes = _selectedTagFilter == 'All'
        ? _notes
        : _notes.where((n) => n.tag == _selectedTagFilter).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131823) : Colors.white;
    final innerBoxColor = isDark ? const Color(0xFF0A0D14) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: allAvailableTags.map((tag) {
                final isSelected = _selectedTagFilter == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    backgroundColor: cardColor,
                    labelStyle: TextStyle(
                      color: isSelected ? (isDark ? Colors.black : Colors.white) : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() => _selectedTagFilter = tag),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
              child: Text(
                'No notes or snippets saved yet.\nTap "+" to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(color: subTextColor),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
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
                          Expanded(
                            child: Text(
                              note.title,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                            ),
                          ),
                          if (note.tag.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(note.tag, style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: innerBoxColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note.content,
                          style: TextStyle(color: textColor.withValues(alpha: 0.8), fontFamily: 'monospace', fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: primaryColor),
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: note.content));
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: const Text('📋 Copied to clipboard!'), backgroundColor: primaryColor),
                              );
                            },
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: subTextColor),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                            onPressed: () => _showAddEditNoteDialog(existingNote: note),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _deleteNote(note.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          HapticFeedback.lightImpact();
          _showAddEditNoteDialog();
        },
      ),
    );
  }
}