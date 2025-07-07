// lib/models/invoice_line_create_model.dart

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
    // Dolibarr often expects certain numeric values as strings in the POST body
    return {
      'libelle': libelle,
      'qty': qty.toString(),
      'price': price.toStringAsFixed(8), // Important for precision
      'tva_tx': tva_tx.toStringAsFixed(2), // E.g., "20.00"
      if (description != null) 'description': description,
      if (fk_product != null) 'fk_product': fk_product.toString(),
      if (fk_fournprice != null) 'fk_fournprice': fk_fournprice.toString(),
      // Dolibarr can automatically calculate totals for lines,
      // so 'total_ht', 'total_tva', 'total_ttc' are usually not sent here.
    };
  }
}
