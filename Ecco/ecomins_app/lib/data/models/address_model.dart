class AddressModel {
  final String id;
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  String get shortDisplay => '$addressLine1, $city';
  String get fullDisplay => '$addressLine1${addressLine2.isNotEmpty ? ', $addressLine2' : ''}, $city, $state - $pincode';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String? ?? '',
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };
}
