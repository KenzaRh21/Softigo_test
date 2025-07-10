class Product {
  final int id;
  final String name;
  final double priceHT;
  final double vatRate; // TVA rate for this product

  Product({
    required this.id,
    required this.name,
    required this.priceHT,
    required this.vatRate,
  });

  // Factory constructor to create a Product from a map (e.g., from JSON)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      priceHT: (json['priceHT'] as num).toDouble(),
      vatRate: (json['vatRate'] as num).toDouble(),
    );
  }

  // Method to convert a Product to a map (e.g., for saving)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'priceHT': priceHT, 'vatRate': vatRate};
  }
}
