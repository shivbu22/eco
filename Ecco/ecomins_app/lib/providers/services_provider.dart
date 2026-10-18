import 'package:flutter/foundation.dart';
import '../data/models/service_model.dart';
import '../data/repositories/eco_repository.dart';
import 'dart:async';

class ServicesProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  StreamSubscription<List<ServiceModel>>? _servicesSubscription;

  // ─── Categories ───────────────────────────────────────
  static const List<Map<String, dynamic>> categories = [
    {'label': 'All', 'icon': '🏠', 'color': 0xFF3FE56C},
    {'label': 'Cleaning', 'icon': '🧹', 'color': 0xFF64B5F6},
    {'label': 'Recycling', 'icon': '♻️', 'color': 0xFF4CAF50},
    {'label': 'Garden', 'icon': '🌱', 'color': 0xFF81C784},
    {'label': 'Solar', 'icon': '☀️', 'color': 0xFFFFB74D},
    {'label': 'Water', 'icon': '💧', 'color': 0xFF42A5F5},
    {'label': 'Waste', 'icon': '🗑️', 'color': 0xFFFF8A65},
    {'label': 'Security', 'icon': '🔒', 'color': 0xFFAB47BC},
  ];

  // ─── Getters ──────────────────────────────────────────
  List<ServiceModel> get services => _filteredServices;
  List<ServiceModel> get allServices => List.unmodifiable(_services);
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  int get serviceCount => _filteredServices.length;

  List<ServiceModel> get popularServices =>
      _services.where((s) => s.rating >= 4.7).toList();

  List<ServiceModel> get availableNowServices =>
      _services.where((s) => s.isAvailableNow).toList();

  ServicesProvider() {
    _initServices();
  }

  void _initServices() {
    _isLoading = true;
    _servicesSubscription?.cancel();
    
    _servicesSubscription = EcoRepository().watchServices().listen((servicesList) {
      _services = servicesList;
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _servicesSubscription?.cancel();
    super.dispose();
  }

  // ─── Search & Filter ─────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredServices = _services.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.displayTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCategory =
          _selectedCategory == 'All' || s.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  ServiceModel? getServiceById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ServiceModel> getServicesByCategory(String category) {
    return _services.where((s) => s.category == category).toList();
  }
}
