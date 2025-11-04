import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../data/api_client.dart';
import '../data/note.dart';
import '../data/local_storage.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final ApiClient api;
  final LocalStorage cache = LocalStorage();

  Note? _lastDeleted;

  NotesCubit(this.api) : super(NotesState.initial());

  Future<void> initCache() async {
    await cache.init();
    final cached = cache.loadAll();
    if (cached.isNotEmpty) {
      emit(state.copyWith(notes: _sorted(cached)));
    }
  }

  Future<void> fetch({String? q}) async {
    emit(state.copyWith(loading: true, query: q, offline: false, error: null));
    try {
      final list = await api.listNotes(q: q);
      final onlineNotes =
      list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
      await cache.saveAll(onlineNotes);
      await sync();

      final afterSync = await api.listNotes(q: q);
      final notes =
      afterSync.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
      await cache.saveAll(notes);

      emit(state.copyWith(
        loading: false,
        notes: _sorted(notes),
        offline: false,
        error: null,
      ));
    } catch (_) {
      final offlineNotes = cache.loadAll();
      emit(state.copyWith(
        loading: false,
        notes: _sorted(offlineNotes),
        offline: true,
        error: 'Offline mode',
      ));
    }
  }

  /// Kuyruğa alınmış (offline) işlemleri online olunca uygular.
  Future<void> sync() async {
    final ops = cache.pending();
    if (ops.isEmpty) return;

    try {
      for (final op in ops) {
        final type = op['type'] as String;
        if (type == 'create') {
          await api.createNote(
            title: op['title'] as String? ?? '',
            content: op['content'] as String? ?? '',
            pinned: (op['pinned'] as bool?) ?? false,
          );
        } else if (type == 'update') {
          await api.updateNote(
            id: op['id'] as String,
            title: op['title'] as String?,
            content: op['content'] as String?,
            pinned: op['pinned'] as bool?,
          );
        } else if (type == 'delete') {
          await api.deleteNote(op['id'] as String);
        }
      }
      await cache.clearPending();
    } catch (_) {
      // Online olsak da herhangi bir op patladıysa kuyruk kalsın; sonra tekrar denenecek.
      rethrow;
    }
  }

  /// Create (offline destekli)
  Future<void> add(String title, String content) async {
    try {
      final createdJson = await api.createNote(title: title, content: content);
      final created = Note.fromJson(createdJson);
      final updated = [created, ...state.notes];
      await cache.saveAll(updated);
      emit(state.copyWith(notes: _sorted(updated), offline: false));
    } catch (_) {
      final temp = Note(
        id: 'tmp_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        content: content,
        pinned: false,
        updatedAt: DateTime.now(),
      );
      final updated = [temp, ...state.notes];
      await cache.saveAll(updated);
      await cache.enqueue({
        'type': 'create',
        'title': title,
        'content': content,
        'pinned': false,
      });
      emit(state.copyWith(notes: _sorted(updated), offline: true));
    }
  }

  /// Pin/Unpin (offline destekli, optimistic)
  Future<void> togglePin(Note n) async {
    final optimistic = state.notes
        .map((x) => x.id == n.id ? x.copyWith(pinned: !n.pinned) : x)
        .toList();
    emit(state.copyWith(notes: _sorted(optimistic)));

    try {
      await api.updateNote(id: n.id, pinned: !n.pinned);
      await cache.saveAll(_sorted(optimistic));
    } catch (_) {
      await cache.enqueue({
        'type': 'update',
        'id': n.id,
        'pinned': !n.pinned,
      });
      emit(state.copyWith(offline: true));
    }
  }

  /// Update (offline destekli, optimistic)
  Future<void> update(
      Note n, {
        required String title,
        required String content,
      }) async {
    final optimistic = state.notes
        .map((x) =>
    x.id == n.id ? n.copyWith(title: title, content: content) : x)
        .toList();
    emit(state.copyWith(notes: _sorted(optimistic)));

    try {
      await api.updateNote(id: n.id, title: title, content: content);
      await cache.saveAll(_sorted(optimistic));
    } catch (_) {
      await cache.enqueue({
        'type': 'update',
        'id': n.id,
        'title': title,
        'content': content,
      });
      emit(state.copyWith(offline: true));
    }
  }

  /// Delete (offline destekli)
  Future<void> delete(Note n) async {
    _lastDeleted = n;
    final afterRemove = state.notes.where((x) => x.id != n.id).toList();
    emit(state.copyWith(notes: _sorted(afterRemove)));

    try {
      await api.deleteNote(n.id);
      await cache.saveAll(afterRemove);
    } catch (_) {
      await cache.saveAll(afterRemove);
      await cache.enqueue({'type': 'delete', 'id': n.id});
      emit(state.copyWith(offline: true));
    }
  }

  Future<void> undoDelete() async {
    final n = _lastDeleted;
    if (n == null) return;
    _lastDeleted = null;
    await add(n.title, n.content);
  }

  List<Note> _sorted(List<Note> list) {
    list.sort((a, b) {
      if (a.pinned != b.pinned) return b.pinned ? 1 : -1; // pinned önce
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return List.unmodifiable(list);
  }
}

