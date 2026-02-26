import 'payment_status.dart';

class Charge {
  final int? id;
  final Customer customer;
  final int value;
  final int installments;
  final String? yourReferenceId;
  final String? notificationUrl;
  final String? status;
  final CreditCard? card;
  final int? checkoutId; // ID do checkout para vincular ao produto

  Charge({
    this.id,
    required this.customer,
    required this.value,
    required this.installments,
    this.yourReferenceId,
    this.notificationUrl,
    this.status,
    this.card,
    this.checkoutId,
  });

  factory Charge.fromJson(Map<String, dynamic> json) {
    return Charge(
      id: json['id'],
      customer: Customer.fromJson(json['customer']),
      value: json['value'],
      installments: json['installments'],
      yourReferenceId: json['yourReferenceId'],
      notificationUrl: json['notificationUrl'],
      status: json['status'],
      card: json['card'] != null ? CreditCard.fromJson(json['card']) : null,
      checkoutId: json['checkoutId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customer': customer.toJson(),
      'value': value,
      'installments': installments,
      if (yourReferenceId != null) 'yourReferenceId': yourReferenceId,
      if (notificationUrl != null) 'notificationUrl': notificationUrl,
      if (card != null) 'card': card!.toJson(),
      if (checkoutId != null) 'checkoutId': checkoutId,
    };
  }

  String get formattedValue => 'R\$ ${(value / 100).toStringAsFixed(2)}';
  String get formattedAmount => formattedValue; // Alias para compatibilidade
  
  String get statusName => PaymentStatus.getChargeName(status);
  String get statusDisplay => statusName; // Alias para compatibilidade
  String get statusDescription => PaymentStatus.getChargeDescription(status);
}

class Customer {
  final String document;
  final String name;

  Customer({
    required this.document,
    required this.name,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      document: json['document'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document': document,
      'name': name,
    };
  }
}

class CreditCard {
  final String cardNumber;
  final String cvv;
  final CardHolder holder;
  final CardExpiration expiration;
  final String brand;

  CreditCard({
    required this.cardNumber,
    required this.cvv,
    required this.holder,
    required this.expiration,
    required this.brand,
  });

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      cardNumber: json['cardNumber'],
      cvv: json['cvv'],
      holder: CardHolder.fromJson(json['holder']),
      expiration: CardExpiration.fromJson(json['expiration']),
      brand: json['brand'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'cvv': cvv,
      'holder': holder.toJson(),
      'expiration': expiration.toJson(),
      'brand': brand,
    };
  }

  String get maskedNumber => '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
}

class CardHolder {
  final String name;
  final String document;

  CardHolder({
    required this.name,
    required this.document,
  });

  factory CardHolder.fromJson(Map<String, dynamic> json) {
    return CardHolder(
      name: json['name'],
      document: json['document'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'document': document,
    };
  }
}

class CardExpiration {
  final String month;
  final String year;

  CardExpiration({
    required this.month,
    required this.year,
  });

  factory CardExpiration.fromJson(Map<String, dynamic> json) {
    return CardExpiration(
      month: json['month'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
    };
  }

  String get formatted => '$month/$year';
}
