import 'address_model.dart';

enum BookingStatus {
  pending,
  confirmed,
  workerAssigned,
  enRoute,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.pending: return 'Pending';
      case BookingStatus.confirmed: return 'Confirmed';
      case BookingStatus.workerAssigned: return 'Worker Assigned';
      case BookingStatus.enRoute: return 'En Route';
      case BookingStatus.inProgress: return 'In Progress';
      case BookingStatus.completed: return 'Completed';
      case BookingStatus.cancelled: return 'Cancelled';
    }
  }

  bool get isActive => this != BookingStatus.completed && this != BookingStatus.cancelled;
}

class BookingModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String serviceEmoji;
  final String? serviceImage;
  final String userId;
  final String? workerId;
  final String? workerName;
  final double workerRating;
  final BookingStatus status;
  final DateTime scheduledAt;
  final AddressModel address;
  final String selectedOption;
  final double subtotal;
  final double gst;
  final double total;
  final double carbonSaved;
  final String? notes;
  final String? imageUrl;
  final int? etaMinutes;
  final double? workerLatitude;
  final double? workerLongitude;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceEmoji,
    this.serviceImage,
    required this.userId,
    this.workerId,
    this.workerName,
    this.workerRating = 0,
    required this.status,
    required this.scheduledAt,
    required this.address,
    required this.selectedOption,
    required this.subtotal,
    required this.gst,
    required this.total,
    this.carbonSaved = 0,
    this.notes,
    this.imageUrl,
    this.etaMinutes,
    this.workerLatitude,
    this.workerLongitude,
    required this.createdAt,
  });

  bool get isActive => status.isActive;
  String get statusDisplay => status.displayName;

  BookingModel copyWith({
    BookingStatus? status,
    String? workerId,
    String? workerName,
    double? workerRating,
    int? etaMinutes,
    double? workerLatitude,
    double? workerLongitude,
  }) {
    return BookingModel(
      id: id,
      serviceId: serviceId,
      serviceName: serviceName,
      serviceEmoji: serviceEmoji,
      serviceImage: serviceImage,
      userId: userId,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerRating: workerRating ?? this.workerRating,
      status: status ?? this.status,
      scheduledAt: scheduledAt,
      address: address,
      selectedOption: selectedOption,
      subtotal: subtotal,
      gst: gst,
      total: total,
      carbonSaved: carbonSaved,
      notes: notes,
      imageUrl: imageUrl,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      workerLatitude: workerLatitude ?? this.workerLatitude,
      workerLongitude: workerLongitude ?? this.workerLongitude,
      createdAt: createdAt,
    );
  }
}
