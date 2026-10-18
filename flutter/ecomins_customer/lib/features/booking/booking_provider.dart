import 'package:flutter/material.dart';
import '../../core/api.dart';

enum BookingStatus { idle, fetchingPrice, creating, success, error }

class BookingProvider extends ChangeNotifier {
  String? selectedServiceId;
  String? selectedSubService;
  String address = '';
  double? estimatedPrice;
  bool priceFallback = false; // true when ₦500 fallback was used
  BookingStatus status = BookingStatus.idle;
  String? activeJobId;
  String? errorMessage;

  bool get isLoading =>
      status == BookingStatus.fetchingPrice || status == BookingStatus.creating;

  /// Fetches the estimated price for [serviceType] in [zoneId].
  /// On failure, falls back to ₦500 and sets [priceFallback] = true.
  Future<void> fetchPrice(String serviceType, String zoneId) async {
    status = BookingStatus.fetchingPrice;
    priceFallback = false;
    notifyListeners();

    try {
      final price = await Api.getPrice(serviceType, zoneId);
      estimatedPrice = price;
      // Api.getPrice already returns 500.0 on failure, but we detect the
      // fallback by catching exceptions thrown before that path.
    } catch (_) {
      estimatedPrice = 500.0;
      priceFallback = true;
    } finally {
      status = BookingStatus.idle;
      notifyListeners();
    }
  }

  /// Creates a job. Guards against duplicate submissions by returning
  /// immediately if [status] is not [BookingStatus.idle].
  Future<void> createJob({
    required String token,
    required String customerId,
    required String serviceType,
    required String address,
    required String zoneId,
    required double price,
  }) async {
    if (status != BookingStatus.idle) return; // duplicate guard

    status = BookingStatus.creating;
    errorMessage = null;
    notifyListeners();

    try {
      final jobId = await Api.createJob(
        token: token,
        serviceType: serviceType,
        address: address,
        zoneId: zoneId,
        customerId: customerId,
        price: price,
      );
      activeJobId = jobId;
      status = BookingStatus.success;
    } catch (e) {
      status = BookingStatus.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  /// Updates [selectedSubService] and notifies listeners.
  void selectSubService(String? value) {
    selectedSubService = value;
    notifyListeners();
  }
  void reset() {
    selectedServiceId = null;
    selectedSubService = null;
    address = '';
    estimatedPrice = null;
    priceFallback = false;
    status = BookingStatus.idle;
    activeJobId = null;
    errorMessage = null;
    notifyListeners();
  }
}
