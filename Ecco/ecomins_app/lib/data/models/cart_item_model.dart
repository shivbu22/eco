import 'service_model.dart';

class CartItem {
  final ServiceModel service;
  final ServiceOptionModel selectedOption;
  final int quantity;
  final String? notes;
  final bool imageUploaded;

  const CartItem({
    required this.service,
    required this.selectedOption,
    this.quantity = 1,
    this.notes,
    this.imageUploaded = false,
  });

  double get subtotal => selectedOption.price * quantity;

  CartItem copyWith({
    ServiceOptionModel? selectedOption,
    int? quantity,
    String? notes,
    bool? imageUploaded,
  }) {
    return CartItem(
      service: service,
      selectedOption: selectedOption ?? this.selectedOption,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      imageUploaded: imageUploaded ?? this.imageUploaded,
    );
  }
}
