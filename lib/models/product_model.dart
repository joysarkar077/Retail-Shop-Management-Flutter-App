class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String barcode;
  final String unit;
  final double costPrice;
  final double sellingPrice;
  final int stockCount;
  final int lowStockThreshold;
  final String? imageUrl;
  final bool isActive;
  final dynamic categoryId; // can be map or string id depending on populate

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.unit,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockCount,
    required this.lowStockThreshold,
    this.imageUrl,
    this.isActive = true,
    this.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      unit: json['unit'] ?? 'pcs',
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      stockCount: json['stock_count'] ?? 0,
      lowStockThreshold: json['low_stock_threshold'] ?? 10,
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      categoryId: json['categoryId'],
    );
  }
}
