part of 'notes_cubit.dart';

@immutable
class NotesState {
  final bool loading;
  final bool offline;      // Offline banner için
  final List<Note> notes;
  final String? error;
  final String? query;

  const NotesState({
    required this.loading,
    required this.offline,
    required this.notes,
    this.error,
    this.query,
  });

  factory NotesState.initial() => const NotesState(
    loading: false,
    offline: false,
    notes: <Note>[],
  );

  NotesState copyWith({
    bool? loading,
    bool? offline,
    List<Note>? notes,
    String? error,
    String? query,
  }) {
    return NotesState(
      loading: loading ?? this.loading,
      offline: offline ?? this.offline,
      notes: notes ?? this.notes,
      error: error,
      query: query ?? this.query,
    );
  }
}
