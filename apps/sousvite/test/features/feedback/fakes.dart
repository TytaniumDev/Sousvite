import 'package:sousvite/app/services/feedback_service.dart';

/// Keeps sent reports in memory, or fails with [error] when it is set.
class FakeFeedbackService() implements FeedbackService {
  /// Every report sent, oldest first.
  final List<FeedbackReport> sent = [];

  /// Thrown by [send] instead of sending, when set.
  Exception? error;

  @override
  Future<void> send(FeedbackReport report) async {
    if (error case final error?) throw error;
    sent.add(report);
  }
}
