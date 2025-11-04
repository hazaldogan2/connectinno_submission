class Note {
  final String id;
  final String title;
  final String content;
  final bool pinned;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.pinned,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> j) => Note(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    content: j['content'] as String? ?? '',
    pinned: (j['pinned'] as bool?) ?? false,
    updatedAt: DateTime.tryParse(j['updated_at']?.toString() ?? '') ??
        DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'pinned': pinned,
    'updated_at': updatedAt.toIso8601String(),
  };

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? pinned,
    DateTime? updatedAt,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        pinned: pinned ?? this.pinned,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
