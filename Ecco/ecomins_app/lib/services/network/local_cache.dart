import 'dart:convert';

/// A high-performance local cache service acting as our local storage buffer.
/// Facilitates instant, zero-flicker UI fetches by servicing queries synchronously.
class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._internal();
  factory LocalCacheService() => _instance;
  LocalCacheService._internal();

  // Simple reactive key-value buffer
  final Map<String, String> _cacheStore = {};

  /// Writes data to the cache buffer.
  void write(String key, dynamic value) {
    try {
      final String jsonStr = jsonEncode(value);
      _cacheStore[key] = jsonStr;
    } catch (e) {
      // Fail-safe logging
      print("[LOCAL CACHE] [ERROR] Failed to serialize entry for key $key: $e");
    }
  }

  /// Synchronously retrieves data from the cache buffer.
  dynamic read(String key) {
    if (!_cacheStore.containsKey(key)) return null;
    try {
      final String jsonStr = _cacheStore[key]!;
      return jsonDecode(jsonStr);
    } catch (e) {
      print("[LOCAL CACHE] [ERROR] Failed to deserialize entry for key $key: $e");
      return null;
    }
  }

  /// Clears cache for a specific key
  void invalidate(String key) {
    _cacheStore.remove(key);
  }

  /// Clears all cached buffers
  void clearAll() {
    _cacheStore.clear();
  }
}
