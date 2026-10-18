import 'package:flutter/foundation.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/service_model.dart';
import '../data/models/address_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  AddressModel? _deliveryAddress;
  DateTime _scheduledTime = DateTime.now().add(const Duration(minutes: 10));
  bool _isAsap = true;
  String? _promoCode;
  double _promoDiscount = 0;

  // ─── Getters ──────────────────────────────────────────
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  AddressModel? get deliveryAddress => _deliveryAddress;
  DateTime get scheduledTime => _scheduledTime;
  bool get isAsap => _isAsap;
  String? get promoCode => _promoCode;

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  double get gst => subtotal * 0.18;

  double get deliveryFee {
    if (subtotal >= 499) return 0; // Free for orders above ₹499
    return 29.0;
  }

  double get promoDiscount => _promoDiscount;

  double get total => subtotal + gst + deliveryFee - _promoDiscount;

  String get estimatedTime => _isAsap ? '10 min' : _formatTime(_scheduledTime);

  bool get hasServiceRequiringImage =>
      _items.any((item) => item.service.requiresImage);

  // ─── Cart Operations ─────────────────────────────────
  void addService(ServiceModel service, ServiceOptionModel option) {
    final existingIdx = _items.indexWhere((i) => i.service.id == service.id);
    if (existingIdx >= 0) {
      _items[existingIdx] = _items[existingIdx].copyWith(
        selectedOption: option,
      );
    } else {
      _items.add(CartItem(service: service, selectedOption: option));
    }
    notifyListeners();
  }

  void removeService(String serviceId) {
    _items.removeWhere((i) => i.service.id == serviceId);
    if (_items.isEmpty) {
      _promoCode = null;
      _promoDiscount = 0;
    }
    notifyListeners();
  }

  void updateItemOption(String serviceId, ServiceOptionModel option) {
    final idx = _items.indexWhere((i) => i.service.id == serviceId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(selectedOption: option);
      notifyListeners();
    }
  }

  void updateItemNotes(String serviceId, String notes) {
    final idx = _items.indexWhere((i) => i.service.id == serviceId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(notes: notes);
      notifyListeners();
    }
  }

  void setImageUploaded(String serviceId, bool uploaded) {
    final idx = _items.indexWhere((i) => i.service.id == serviceId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(imageUploaded: uploaded);
      notifyListeners();
    }
  }

  bool isInCart(String serviceId) =>
      _items.any((i) => i.service.id == serviceId);

  CartItem? getCartItem(String serviceId) {
    final idx = _items.indexWhere((i) => i.service.id == serviceId);
    return idx >= 0 ? _items[idx] : null;
  }

  // ─── Address ──────────────────────────────────────────
  void setAddress(AddressModel address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  // ─── Schedule ─────────────────────────────────────────
  void setAsap() {
    _isAsap = true;
    _scheduledTime = DateTime.now().add(const Duration(minutes: 10));
    notifyListeners();
  }

  void setScheduledTime(DateTime time) {
    _isAsap = false;
    _scheduledTime = time;
    notifyListeners();
  }

  // ─── Promo Code ───────────────────────────────────────
  bool applyPromo(String code) {
    // Mock promo codes
    final promos = {
      'ECO30': 0.30,
      'GREEN50': 0.50,
      'FIRST100': 100.0,
      'OZOMIN20': 0.20,
    };

    final upperCode = code.toUpperCase();
    if (promos.containsKey(upperCode)) {
      _promoCode = upperCode;
      final value = promos[upperCode]!;
      if (value < 1) {
        _promoDiscount = subtotal * value;
      } else {
        _promoDiscount = value;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromo() {
    _promoCode = null;
    _promoDiscount = 0;
    notifyListeners();
  }

  // ─── Clear ────────────────────────────────────────────
  void clearCart() {
    _items.clear();
    _promoCode = null;
    _promoDiscount = 0;
    _isAsap = true;
    _scheduledTime = DateTime.now().add(const Duration(minutes: 10));
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min $amPm';
  }
}
