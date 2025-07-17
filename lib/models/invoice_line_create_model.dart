class InvoiceLineCreate {
  final int? lineid; // 🔥 ID of the line (used for update/delete)
  final String libelle;
  final double qty;
  final double price;
  final double tva_tx;
  final String? description;
  final int? fk_product;
  final int? fk_fournprice;

  InvoiceLineCreate({
    this.lineid, // ← New optional parameter
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
      if (lineid != null) 'id': lineid.toString(), // Include only if present
      'libelle': libelle,
      'qty': qty.toString(),
      'price': price.toStringAsFixed(8),
      'tva_tx': tva_tx.toStringAsFixed(2),
      if (description != null) 'description': description,
      'fk_product': fk_product?.toString(),
      if (fk_fournprice != null) 'fk_fournprice': fk_fournprice.toString(),
    };
  }

  Map<String, dynamic> toJsonForApi() {
    return {
      if (lineid != null)
        'id': lineid.toString(), // Include for updates/deletes
      'desc': description ?? libelle,
      'libelle': libelle,
      'qty': qty.toString(),
      'subprice': price.toStringAsFixed(8),
      'tva_tx': tva_tx.toStringAsFixed(2),
      'localtax1_type': "0",
      'localtax2_type': "0",
      'remise_percent': "0",
      'situation_percent': "100",
      'product_type': "0",
      'fk_warehouse': "0",
      'fk_product': fk_product?.toString(),
      if (fk_fournprice != null) 'fk_fournprice': fk_fournprice.toString(),
    };
  }
}
