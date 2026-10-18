// ignore_for_file: constant_identifier_names

/// Backend base URLs and app-wide constants.
///
/// Platform detection is done at runtime via [AppConstants.baseUrl*] helpers.
/// For local development:
///   - Android emulator  → 10.0.2.2  (maps to host loopback)
///   - iOS simulator     → localhost
///   - Production        → set PROD_HOST env or update [_prodHost]
class AppConstants {
  AppConstants._();

  // ── Production host ──────────────────────────────────────────────────────
  static const String _prodHost = 'api.ecomins.com';

  // ── Android emulator host (maps to host machine's 127.0.0.1) ─────────────
  static const String _androidHost = '10.0.2.2';

  // ── iOS simulator host ────────────────────────────────────────────────────
  static const String _iosHost = 'localhost';

  // ── Service ports ─────────────────────────────────────────────────────────
  static const int authPort     = 3001;
  static const int bookingPort  = 3002;
  static const int pricingPort  = 3004;
  static const int rewardsPort  = 3005;
  static const int trackingPort = 3006;

  // ── Base URLs (Android emulator) ──────────────────────────────────────────
  static const String authBaseUrlAndroid     = 'http://$_androidHost:$authPort';
  static const String bookingBaseUrlAndroid  = 'http://$_androidHost:$bookingPort';
  static const String pricingBaseUrlAndroid  = 'http://$_androidHost:$pricingPort';
  static const String rewardsBaseUrlAndroid  = 'http://$_androidHost:$rewardsPort';
  static const String trackingBaseUrlAndroid = 'http://$_androidHost:$trackingPort';

  // ── Base URLs (iOS simulator) ─────────────────────────────────────────────
  static const String authBaseUrlIos     = 'http://$_iosHost:$authPort';
  static const String bookingBaseUrlIos  = 'http://$_iosHost:$bookingPort';
  static const String pricingBaseUrlIos  = 'http://$_iosHost:$pricingPort';
  static const String rewardsBaseUrlIos  = 'http://$_iosHost:$rewardsPort';
  static const String trackingBaseUrlIos = 'http://$_iosHost:$trackingPort';

  // ── Base URLs (Production) ────────────────────────────────────────────────
  static const String authBaseUrlProd     = 'https://$_prodHost:$authPort';
  static const String bookingBaseUrlProd  = 'https://$_prodHost:$bookingPort';
  static const String pricingBaseUrlProd  = 'https://$_prodHost:$pricingPort';
  static const String rewardsBaseUrlProd  = 'https://$_prodHost:$rewardsPort';
  static const String trackingBaseUrlProd = 'https://$_prodHost:$trackingPort';

  // ── WebSocket URL for live tracking (Android emulator default) ────────────
  static const String trackingWsUrlAndroid = 'ws://$_androidHost:$trackingPort';
  static const String trackingWsUrlIos     = 'ws://$_iosHost:$trackingPort';
  static const String trackingWsUrlProd    = 'wss://$_prodHost:$trackingPort';

  // ── Default zone ──────────────────────────────────────────────────────────
  static const String defaultZoneId = 'zone-lagos-1';

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const Duration requestTimeout    = Duration(seconds: 10);
  static const int wsReconnectMaxAttempts = 5;
  static const Duration wsReconnectDelay  = Duration(seconds: 3);
}
