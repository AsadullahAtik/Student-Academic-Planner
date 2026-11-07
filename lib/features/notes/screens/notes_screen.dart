import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../app/theme/app_colors.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String searchQuery = '';

  void _showAddEditNoteDialog([Note? existing]) {
    final subjects = ref.read(subjectsProvider);
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a subject first!')),
      );
      return;
    }

    String subjectId = existing?.subjectId ?? subjects.first.id;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Create Note' : 'Edit Note'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: subjectId,
                      decoration: const InputDecoration(labelText: 'Subject'),
                      items: subjects.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text('${s.code} - ${s.name}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => subjectId = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Note Title',
                        hintText: 'Critical Sections & Semaphores',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentCtrl,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Note Content / Summary / Formulas',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final now = DateTime.now();
                    final id = existing?.id ?? now.millisecondsSinceEpoch.toString();

                    final note = Note(
                      id: id,
                      subjectId: subjectId,
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      createdAt: existing?.createdAt ?? now,
                      updatedAt: now,
                    );

                    if (existing == null) {
                      ref.read(notesProvider.notifier).add(note);
                    } else {
                      ref.read(notesProvider.notifier).update(note);
                    }

                    Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'Save' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final subjects = ref.watch(subjectsProvider);

    final filteredNotes = notes.where((n) {
      final q = searchQuery.toLowerCase();
      return n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
    }).toList();

    Subject getSubject(String id) {
      return subjects.firstWhere(
        (s) => s.id == id,
        orElse: () => const Subject(
          id: '?',
          name: 'General',
          code: 'GEN',
          teacher: '',
          credit: 0,
          semester: '',
          colorHex: '#4F46E5',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_rounded),
            tooltip: 'New Note',
            onPressed: () => _showAddEditNoteDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes by keyword...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),

          // Notes List
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.speaker_notes_off_rounded,
                          size: 54,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No notes found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to create a lecture note.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final n = filteredNotes[index];
                      final sub = getSubject(n.subjectId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showAddEditNoteDialog(n),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 5,
                                          backgroundColor: sub.color,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          sub.code,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: sub.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      n.updatedAt.toLocal().toString().split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  n.title,
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  n.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.danger, size: 18),
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'Delete Note',
                                    onPressed: () {
                                      ref.read(notesProvider.notifier).delete(n.id);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New Note',
        onPressed: () => _showAddEditNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
