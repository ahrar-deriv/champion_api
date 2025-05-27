/// Trading product information
class Product {
  /// Product identifier
  final String id;

  /// Product display name
  final String displayName;

  /// Product description
  final String? description;

  /// Whether the product is enabled
  final bool isEnabled;

  /// Product configuration
  final Map<String, dynamic>? config;

  const Product({
    required this.id,
    required this.displayName,
    this.description,
    this.isEnabled = true,
    this.config,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String?,
      isEnabled: (json['is_enabled'] as bool?) ?? true,
      config: json['config'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      if (description != null) 'description': description,
      'is_enabled': isEnabled,
      if (config != null) 'config': config,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, displayName: $displayName, isEnabled: $isEnabled)';
  }
}

/// Product configuration details
class ProductConfig {
  /// Configuration data
  final Map<String, dynamic> config;

  const ProductConfig({
    required this.config,
  });

  factory ProductConfig.fromJson(Map<String, dynamic> json) {
    return ProductConfig(
      config: json,
    );
  }

  Map<String, dynamic> toJson() {
    return config;
  }
}

/// List of products response
class ProductsList {
  /// List of products
  final List<Product> products;

  const ProductsList({
    required this.products,
  });

  factory ProductsList.fromJson(Map<String, dynamic> json) {
    return ProductsList(
      products: (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
    };
  }
}
