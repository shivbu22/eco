class WorkerModel {
  final String id;
  final String name;
  final double rating;
  final int completedJobs;
  final String speciality;
  final String avatar;
  final bool isVerified;
  final bool isOnline;
  final double? distanceKm;
  final int? etaMinutes;

  const WorkerModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.completedJobs,
    required this.speciality,
    required this.avatar,
    this.isVerified = false,
    this.isOnline = true,
    this.distanceKm,
    this.etaMinutes,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      completedJobs: json['jobs'] as int? ?? 0,
      speciality: json['speciality'] as String,
      avatar: json['avatar'] as String,
      isVerified: json['verified'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? true,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      etaMinutes: json['etaMinutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rating': rating,
        'jobs': completedJobs,
        'speciality': speciality,
        'avatar': avatar,
        'verified': isVerified,
        'isOnline': isOnline,
      };
}
