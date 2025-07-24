class InvoiceLineCreate {
  final String libelle; // Product/Service description/label
  final double qty; // Quantity
  final double price; // Unit price (HT - before tax)
  final double tva_tx; // VAT rate (e.g., 20.0 for 20%)
  final String? description; // Optional detailed description (beyond libelle)
  final int? fk_product; // Optional: If linking to an existing product by ID
  final int?
  fk_fournprice; // Optional: For supplier price (if creating supplier invoice)

  InvoiceLineCreate({
    required this.libelle,
    required this.qty,
    required this.price,
    required this.tva_tx,
    this.description,
    this.fk_product,
    this.fk_fournprice,
  });

  Map<String, dynamic> toJson() {
    return {
      'libelle': libelle,
      'qty': qty.toString(),
      'price': price.toStringAsFixed(8),
      'tva_tx': tva_tx.toStringAsFixed(2),
      if (description != null) 'description': description,
      'fk_product': (fk_product != null ? fk_product.toString() : null),
      if (fk_fournprice != null) 'fk_fournprice': fk_fournprice.toString(),
    };
  }

  Map<String, dynamic> toJsonForApi() {
    return {
      'desc': description ?? libelle, // Fallback to libelle if no description
      'libelle': libelle,
      'qty': qty.toString(),
      'subprice': price.toStringAsFixed(8), // subprice = prix unitaire HT
      'tva_tx': tva_tx.toStringAsFixed(2),
      'localtax1_type': "0",
      'localtax2_type': "0",
      'remise_percent': "0",
      'situation_percent': "100",
      'product_type': "0",
      'fk_warehouse': "0",
      'fk_product': null,
      if (fk_fournprice != null) 'fk_fournprice': fk_fournprice.toString(),
    };
  }
}
