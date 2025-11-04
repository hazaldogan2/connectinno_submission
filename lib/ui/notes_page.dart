import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/note.dart';
import '../logic/notes_cubit.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ilk açılışta cache'i göster, sonra sunucudan çek
    final cubit = context.read<NotesCubit>();
    cubit.initCache().then((_) => cubit.fetch());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotesCubit, NotesState>(
      listener: (context, state) {
        if (state.error != null && state.error != 'Offline mode') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    context.read<NotesCubit>().fetch(q: _search.text),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56 + 24),
              child: Column(
                children: [
                  // 🔸 OFFLINE BANNER (sarı şerit)
                  if (state.offline)
                    Container(
                      width: double.infinity,
                      color: Colors.amber.shade300,
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 12),
                      child: const Text(
                        'Offline mode — showing cached notes',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: 'Search in title/content',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _search.clear();
                            context.read<NotesCubit>().fetch(q: '');
                            setState(() {});
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (v) =>
                          context.read<NotesCubit>().fetch(q: v),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.notes.isEmpty
              ? const Center(child: Text('No notes yet'))
              : ListView.separated(
            itemCount: state.notes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = state.notes[i];
              return ListTile(
                title: Text(n.title.isEmpty ? '(Untitled)' : n.title),
                subtitle: Text(
                  n.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: IconButton(
                  icon: Icon(n.pinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined),
                  onPressed: () =>
                      context.read<NotesCubit>().togglePin(n),
                  tooltip: n.pinned ? 'Unpin' : 'Pin',
                ),
                onTap: () => _editDialog(context, n),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await context.read<NotesCubit>().delete(n);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Note deleted'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () => context
                                .read<NotesCubit>()
                                .undoDelete(),
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _addDialog(BuildContext context) async {
    final title = TextEditingController();
    final content = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(
                controller: content,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 4),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<NotesCubit>().add(title.text, content.text);
    }
  }

  Future<void> _editDialog(BuildContext context, Note n) async {
    final title = TextEditingController(text: n.title);
    final content = TextEditingController(text: n.content);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(
                controller: content,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 6),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context
          .read<NotesCubit>()
          .update(n, title: title.text, content: content.text);
    }
  }
}
