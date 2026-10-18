import 'package:flutter/material.dart';

enum NotificationType { orderUpdate, achievement, offer, system }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String icon;
  final String title;
  final String body;
  final String time;
  final bool isUnread;
  final String? actionRoute;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.isUnread = false,
    this.actionRoute,
  });

  Color get accentColor {
    switch (type) {
      case NotificationType.orderUpdate: return const Color(0xFF3FE56C);
      case NotificationType.achievement: return const Color(0xFFFFB74D);
      case NotificationType.offer: return const Color(0xFFFF8A65);
      case NotificationType.system: return const Color(0xFF64B5F6);
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotificationType.orderUpdate: return Icons.local_shipping_rounded;
      case NotificationType.achievement: return Icons.emoji_events_rounded;
      case NotificationType.offer: return Icons.local_offer_rounded;
      case NotificationType.system: return Icons.info_outline_rounded;
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType type;
    switch (json['type'] as String?) {
      case 'update': type = NotificationType.orderUpdate; break;
      case 'achievement': type = NotificationType.achievement; break;
      case 'offer': type = NotificationType.offer; break;
      default: type = NotificationType.system;
    }

    return NotificationModel(
      id: json['id'] as String,
      type: type,
      icon: json['icon'] as String? ?? '🔔',
      title: json['title'] as String,
      body: json['body'] as String,
      time: json['time'] as String,
      isUnread: json['unread'] as bool? ?? false,
      actionRoute: json['actionRoute'] as String?,
    );
  }
}
