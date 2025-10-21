class Report {
  final String id;
  final String postId;
  final String reporterId;
  final String reporterName;
  final String reason;
  final String? details;
  final DateTime timestamp;

  Report({
    required this.id,
    required this.postId,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reason': reason,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      postId: json['postId'],
      reporterId: json['reporterId'],
      reporterName: json['reporterName'],
      reason: json['reason'],
      details: json['details'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}