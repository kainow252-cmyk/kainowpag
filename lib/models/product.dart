class Product {
  final int? id;
  final String productType;
  final int affiliateId;
  final String name;
  final int value;
  final String? softDescriptor;
  final int maxInstallments;
  final bool active;
  final List<String> methods;
  final String? description;
  final int themeId;
  final bool feePassThrough;
  final int? expirationDate;
  final int? checkoutId; // ID do checkout vinculado (para produtos recorrentes)

  Product({
    this.id,
    required this.productType,
    required this.affiliateId,
    required this.name,
    required this.value,
    this.softDescriptor,
    required this.maxInstallments,
    this.active = true,
    required this.methods,
    this.description,
    required this.themeId,
    this.feePassThrough = false,
    this.expirationDate,
    this.checkoutId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Extrair checkoutId do objeto checkout se existir
    int? checkoutId;
    if (json['checkout'] != null && json['checkout'] is Map) {
      checkoutId = json['checkout']['id'];
    }
    
    return Product(
      id: json['id'],
      productType: json['type'] ?? json['productType'] ?? 'ONE_TIME',
      affiliateId: json['affiliateId'] ?? 1,
      name: json['name'],
      value: json['value'],
      softDescriptor: json['softDescriptor'],
      maxInstallments: json['maxInstallments'] ?? 1,
      active: json['active'] ?? true,
      methods: List<String>.from(json['methods'] ?? ['CREDIT_CARD']),
      description: json['description'],
      themeId: json['themeId'] ?? 1,
      feePassThrough: json['feePassThrough'] ?? false,
      expirationDate: json['expirationDate'],
      checkoutId: checkoutId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productType': productType,
      'affiliateId': affiliateId,
      'name': name,
      'value': value,
      if (softDescriptor != null) 'softDescriptor': softDescriptor,
      'maxInstallments': maxInstallments,
      'active': active,
      'methods': methods,
      if (description != null) 'description': description,
      'themeId': themeId,
      'feePassThrough': feePassThrough,
      if (expirationDate != null) 'expirationDate': expirationDate,
      if (checkoutId != null) 'checkoutId': checkoutId,
    };
  }

  String get formattedValue => 'R\$ ${(value / 100).toStringAsFixed(2)}';
}
