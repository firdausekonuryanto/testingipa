class Task {
  final int id;
  final int taskId;
  final String taskName;
  final String taskDesc;
  final String location;
  final String assignDate;
  final String status;
  final TaskProgress progress;

  Task({
    required this.id,
    required this.taskId,
    required this.taskName,
    required this.taskDesc,
    required this.location,
    required this.assignDate,
    required this.status,
    required this.progress,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      taskId: json['task_asign_id'],
      taskName: json['task_name'],
      taskDesc: json['task_description'],
      location: json['location'],
      assignDate: json['assign_date'],
      status: json['status'],
      progress: TaskProgress.fromJson(json['progress']),
    );
  }

  // Override toString() untuk debugging
  @override
  String toString() {
    return 'Task(id: $id, taskId: $taskId, taskName: "$taskName", taskDesc:"$taskDesc", location: "$location", assignDate: "$assignDate", status: "$status", progress: $progress)';
  }
}

class TaskProgress {
  final int total;
  final int completed;
  final int percentage;

  TaskProgress({
    required this.total,
    required this.completed,
    required this.percentage,
  });

  factory TaskProgress.fromJson(Map<String, dynamic> json) {
    return TaskProgress(
      total: json['total'],
      completed: json['completed'],
      percentage: json['percentage'],
    );
  }
  @override
  String toString() {
    return 'TaskProgress(total: $total, completed: $completed, percentage: $percentage%)';
  }
}
