class TaskReport {
  final int id;
  final String content;
  final String? reasonNotCompleted;
  final String createdAt;
  final TaskReportImages images;

  TaskReport({
    required this.id,
    required this.content,
    this.reasonNotCompleted,
    required this.createdAt,
    required this.images,
  });

  factory TaskReport.fromJson(Map<String, dynamic> json) {
    return TaskReport(
      id: json['id'],
      content: json['content'] ?? '',
      reasonNotCompleted: json['reason_not_completed'],
      createdAt: json['created_at'] ?? '',
      images: TaskReportImages.fromJson(json['images'] ?? {}),
    );
  }

  @override
  String toString() {
    return '''
TaskReport(
  id: $id,
  content: $content,
  reasonNotCompleted: $reasonNotCompleted,
  createdAt: $createdAt,
  images: $images
)
''';
  }
}

class TaskReportImages {
  final List<String> before;
  final List<String> after;

  TaskReportImages({
    required this.before,
    required this.after,
  });

  factory TaskReportImages.fromJson(Map<String, dynamic> json) {
    return TaskReportImages(
      before: List<String>.from(json['before'] ?? []),
      after: List<String>.from(json['after'] ?? []),
    );
  }

  @override
  String toString() {
    return '''
TaskReportImages(
  before: $before,
  after: $after
)
''';
  }
}
