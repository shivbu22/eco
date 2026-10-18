import 'package:flutter/material.dart';

class ServiceOptionModel {
  final String label;
  final double price;

  const ServiceOptionModel({required this.label, required this.price});

  factory ServiceOptionModel.fromJson(Map<String, dynamic> json) {
    return ServiceOptionModel(
      label: json['label'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'price': price};
}

class ServiceModel {
  final String id;
  final String title;
  final String emoji;
  final String? image;
  final double basePrice;
  final double rating;
  final String duration;
  final String category;
  final List<String> tags;
  final int ecoScore;
  final List<String> ecoImpact;
  final bool requiresImage;
  final String? suggestion;
  final List<ServiceOptionModel> options;
  final bool isAvailableNow;
  final String? nextAvailableSlot;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.emoji,
    this.image,
    required this.basePrice,
    required this.rating,
    required this.duration,
    required this.category,
    this.tags = const [],
    this.ecoScore = 80,
    this.ecoImpact = const [],
    this.requiresImage = false,
    this.suggestion,
    this.options = const [],
    this.isAvailableNow = true,
    this.nextAvailableSlot,
  });

  /// Clean title without linebreaks
  String get displayTitle => title.replaceAll('\n', ' ');

  /// Icon mapping from emoji
  IconData get iconData {
    switch (emoji) {
      case '🧹': return Icons.cleaning_services_rounded;
      case '♻️': return Icons.recycling_rounded;
      case '💧': return Icons.water_drop_rounded;
      case '☀️': return Icons.solar_power_rounded;
      case '🗑️': return Icons.delete_outline_rounded;
      case '🌱': return Icons.energy_savings_leaf_rounded;
      case '🗃️': return Icons.inventory_2_rounded;
      case '🚛': return Icons.local_shipping_rounded;
      case '✨': return Icons.auto_awesome_rounded;
      case '🔒': return Icons.security_rounded;
      case '🪣': return Icons.wash_rounded;
      case '🌬️': return Icons.air_rounded;
      case '🪴': return Icons.yard_rounded;
      default: return Icons.eco_rounded;
    }
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final features = json['features'] as Map<String, dynamic>? ?? {};
    final optionsList = features['options'] as List<dynamic>? ?? [];

    return ServiceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      image: json['image'] as String?,
      basePrice: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      duration: json['duration'] as String,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      ecoScore: features['ecoScore'] as int? ?? 80,
      ecoImpact: List<String>.from(features['ecoImpact'] ?? []),
      requiresImage: features['requiresImage'] as bool? ?? false,
      suggestion: features['suggestion'] as String?,
      options: optionsList
          .map((o) => ServiceOptionModel.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  ServiceModel copyWith({
    bool? isAvailableNow,
    String? nextAvailableSlot,
  }) {
    return ServiceModel(
      id: id,
      title: title,
      emoji: emoji,
      image: image,
      basePrice: basePrice,
      rating: rating,
      duration: duration,
      category: category,
      tags: tags,
      ecoScore: ecoScore,
      ecoImpact: ecoImpact,
      requiresImage: requiresImage,
      suggestion: suggestion,
      options: options,
      isAvailableNow: isAvailableNow ?? this.isAvailableNow,
      nextAvailableSlot: nextAvailableSlot ?? this.nextAvailableSlot,
    );
  }
}
