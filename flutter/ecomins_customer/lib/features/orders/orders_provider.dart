import 'package:flutter/material.dart';

import '../../core/api.dart';
import '../tracking/tracking_provider.dart';

// ── Job model ────────────────────────────────────────────────────────────────

class Job {
  final String id;
  final String serviceType;
  final String address;
  final JobStatus status;

  Job({
    required this.id,
    required this.serviceType,
    required this.address,
    required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String? ?? json['job_id'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
      address:
          (json['location'] as Map<String, dynamic>?)?['address'] as String? ??
              '',
      status:
          JobStatus.fromString(json['status'] as String? ?? 'pending') ??
              JobStatus.pending,
    );
  }

  bool get isActive =>
      status != JobStatus.completed && status != JobStatus.cancelled;
}

// ── OrdersProvider ───────────────────────────────────────────────────────────

class OrdersProvider extends ChangeNotifier {
  List<Job> jobs = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadJobs(String token, String customerId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final raw = await Api.getJobs(token, customerId);
      jobs = raw.map((j) => Job.fromJson(j)).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String token, String customerId) =>
      loadJobs(token, customerId);
}
