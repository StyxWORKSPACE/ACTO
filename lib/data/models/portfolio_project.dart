enum ProjectStatus {
  inProgress,
  completed,
  delayed
}

class PortfolioProject {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? deadline;
  final ProjectStatus status;
  final int completionPercentage;

  PortfolioProject({
    required this.title,
    required this.description,
    required this.startDate,
    this.deadline,
    required this.status,
    required this.completionPercentage,
  });

  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && status != ProjectStatus.completed;
  }
} 