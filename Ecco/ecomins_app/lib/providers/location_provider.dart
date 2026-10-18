import 'package:flutter/foundation.dart';
import '../data/models/address_model.dart';

class LocationProvider extends ChangeNotifier {
  AddressModel? _currentAddress;
  List<AddressModel> _savedAddresses = [];
  bool _isDetecting = false;

  // ─── Getters ──────────────────────────────────────────
  AddressModel? get currentAddress => _currentAddress;
  List<AddressModel> get savedAddresses => List.unmodifiable(_savedAddresses);
  bool get isDetecting => _isDetecting;
  bool get hasAddress => _currentAddress != null;

  String get displayLocation {
    if (_currentAddress != null) {
      return _currentAddress!.shortDisplay;
    }
    return 'Select Location';
  }

  String get areaName {
    if (_currentAddress != null) {
      return _currentAddress!.label;
    }
    return 'Add Address';
  }

  LocationProvider() {
    // Initialize with mock saved addresses
    _savedAddresses = [
      const AddressModel(
        id: 'addr_1',
        label: 'Home',
        addressLine1: '14, 2nd Cross, Koramangala',
        addressLine2: 'Near Forum Mall',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560034',
        latitude: 12.9352,
        longitude: 77.6245,
        isDefault: true,
      ),
      const AddressModel(
        id: 'addr_2',
        label: 'Office',
        addressLine1: 'WeWork, Embassy Golf Links',
        addressLine2: 'Domlur',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560071',
        latitude: 12.9600,
        longitude: 77.6400,
      ),
      const AddressModel(
        id: 'addr_3',
        label: 'Parents',
        addressLine1: '42, MG Road',
        addressLine2: 'Trinity Circle',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560001',
        latitude: 12.9716,
        longitude: 77.5946,
      ),
    ];

    // Set default address
    _currentAddress = _savedAddresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _savedAddresses.first,
    );
  }

  // ─── Actions ──────────────────────────────────────────
  Future<void> detectLocation() async {
    _isDetecting = true;
    notifyListeners();

    // Simulate GPS detection
    await Future.delayed(const Duration(seconds: 1));

    _currentAddress = const AddressModel(
      id: 'addr_gps',
      label: 'Current Location',
      addressLine1: 'Koramangala 4th Block',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560034',
      latitude: 12.9340,
      longitude: 77.6260,
    );

    _isDetecting = false;
    notifyListeners();
  }

  void selectAddress(AddressModel address) {
    _currentAddress = address;
    notifyListeners();
  }

  void addAddress(AddressModel address) {
    _savedAddresses.add(address);
    notifyListeners();
  }

  void removeAddress(String id) {
    _savedAddresses.removeWhere((a) => a.id == id);
    if (_currentAddress?.id == id) {
      _currentAddress = _savedAddresses.isNotEmpty ? _savedAddresses.first : null;
    }
    notifyListeners();
  }
}
