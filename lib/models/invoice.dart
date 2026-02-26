class Invoice {
  final int? id;
  final int? customerId;
  final InvoiceCustomer? customer;
  final String? invoiceNumber;
  final int? dueDate;
  final String? notificationUrl;
  final String? successUrl;
  final int? amount;
  final int? paidAmount;
  final String? status;
  final String? paymentUrl;
  final int? closeDate;
  final int? createdAt;
  final int? invoiceSequence;
  final bool? pastDue;
  final int? paymentDate;
  final int? recurrentInvoiceId;
  final int? orderId;
  final int? userId;
  final InvoiceAffiliate? affiliate;
  final List<InvoiceItem>? items;
  final List<PaymentMethod>? acceptedPaymentMethods;
  final InvoiceFine? fine;
  final InvoiceInterest? interest;

  Invoice({
    this.id,
    this.customerId,
    this.customer,
    this.invoiceNumber,
    this.dueDate,
    this.notificationUrl,
    this.successUrl,
    this.amount,
    this.paidAmount,
    this.status,
    this.paymentUrl,
    this.closeDate,
    this.createdAt,
    this.invoiceSequence,
    this.pastDue,
    this.paymentDate,
    this.recurrentInvoiceId,
    this.orderId,
    this.userId,
    this.affiliate,
    this.items,
    this.acceptedPaymentMethods,
    this.fine,
    this.interest,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      customerId: json['customerId'],
      customer: json['customer'] != null ? InvoiceCustomer.fromJson(json['customer']) : null,
      invoiceNumber: json['invoiceNumber'],
      dueDate: json['dueDate'],
      notificationUrl: json['notificationUrl'],
      successUrl: json['successUrl'],
      amount: json['amount'],
      paidAmount: json['paidAmount'],
      status: json['status'],
      paymentUrl: json['paymentUrl'],
      closeDate: json['closeDate'],
      createdAt: json['createdAt'],
      invoiceSequence: json['invoiceSequence'],
      pastDue: json['pastDue'],
      paymentDate: json['paymentDate'],
      recurrentInvoiceId: json['recurrentInvoiceId'],
      orderId: json['orderId'],
      userId: json['userId'],
      affiliate: json['affiliate'] != null ? InvoiceAffiliate.fromJson(json['affiliate']) : null,
      items: (json['items'] as List?)?.map((item) => InvoiceItem.fromJson(item)).toList(),
      acceptedPaymentMethods: (json['acceptedPaymentMethods'] as List?)?.map((method) => PaymentMethod.fromJson(method)).toList(),
      fine: json['fine'] != null ? InvoiceFine.fromJson(json['fine']) : null,
      interest: json['interest'] != null ? InvoiceInterest.fromJson(json['interest']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (customerId != null) 'customerId': customerId,
      if (invoiceNumber != null) 'invoiceNumber': invoiceNumber,
      if (dueDate != null) 'dueDate': dueDate,
      if (notificationUrl != null) 'notificationUrl': notificationUrl,
      if (successUrl != null) 'successUrl': successUrl,
      if (amount != null) 'amount': amount,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
      if (acceptedPaymentMethods != null) 'acceptedPaymentMethods': acceptedPaymentMethods!.map((method) => method.toJson()).toList(),
      if (fine != null) 'fine': fine!.toJson(),
      if (interest != null) 'interest': interest!.toJson(),
    };
  }

  int get totalAmount => amount ?? 0;
  String get formattedTotal => 'R\$ ${(totalAmount / 100).toStringAsFixed(2)}';
  
  String get statusDisplay {
    switch (status) {
      case 'OPEN': return 'Aberta';
      case 'CLOSED': return 'Fechada';
      case 'PAID': return 'Paga';
      case 'CANCELED': return 'Cancelada';
      case 'OVERDUE': return 'Vencida';
      default: return status ?? 'Desconhecido';
    }
  }
  
  String get formattedDueDate {
    if (dueDate == null) return 'Sem vencimento';
    final date = DateTime.fromMillisecondsSinceEpoch(dueDate!);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class InvoiceCustomer {
  final int? id;
  final String? name;
  final String? document;
  final String? email;
  final String? phone;

  InvoiceCustomer({
    this.id,
    this.name,
    this.document,
    this.email,
    this.phone,
  });

  factory InvoiceCustomer.fromJson(Map<String, dynamic> json) {
    return InvoiceCustomer(
      id: json['id'],
      name: json['name'],
      document: json['document'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (document != null) 'document': document,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }
}

class InvoiceAffiliate {
  final int? id;
  final String? name;
  final String? businessName;
  final String? document;
  final bool? isSeller;
  final String? status;

  InvoiceAffiliate({
    this.id,
    this.name,
    this.businessName,
    this.document,
    this.isSeller,
    this.status,
  });

  factory InvoiceAffiliate.fromJson(Map<String, dynamic> json) {
    return InvoiceAffiliate(
      id: json['id'],
      name: json['name'],
      businessName: json['businessName'],
      document: json['document'],
      isSeller: json['isSeller'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (businessName != null) 'businessName': businessName,
      if (document != null) 'document': document,
      if (isSeller != null) 'isSeller': isSeller,
      if (status != null) 'status': status,
    };
  }
}

class InvoiceFine {
  final String? type;
  final double? value;

  InvoiceFine({
    this.type,
    this.value,
  });

  factory InvoiceFine.fromJson(Map<String, dynamic> json) {
    return InvoiceFine(
      type: json['type'],
      value: json['value']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (value != null) 'value': value,
    };
  }
}

class InvoiceInterest {
  final String? type;
  final double? value;

  InvoiceInterest({
    this.type,
    this.value,
  });

  factory InvoiceInterest.fromJson(Map<String, dynamic> json) {
    return InvoiceInterest(
      type: json['type'],
      value: json['value']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (value != null) 'value': value,
    };
  }
}

class InvoiceItem {
  final int? invoiceId;
  final int? planId;
  final String? planName;
  final String? planType;
  final String? planFrequency;
  final int? invoiceItemQuantity;
  final int? invoiceItemMaxCycles;
  final int? invoiceItemUnitPrice;
  final int? productId;
  final int? quantity;
  final int? unitPriceInCents;
  final String? description;

  InvoiceItem({
    this.invoiceId,
    this.planId,
    this.planName,
    this.planType,
    this.planFrequency,
    this.invoiceItemQuantity,
    this.invoiceItemMaxCycles,
    this.invoiceItemUnitPrice,
    this.productId,
    this.quantity,
    this.unitPriceInCents,
    this.description,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      invoiceId: json['invoiceId'],
      planId: json['planId'],
      planName: json['planName'],
      planType: json['planType'],
      planFrequency: json['planFrequency'],
      invoiceItemQuantity: json['invoiceItemQuantity'],
      invoiceItemMaxCycles: json['invoiceItemMaxCycles'],
      invoiceItemUnitPrice: json['invoiceItemUnitPrice'],
      productId: json['productId'],
      quantity: json['quantity'],
      unitPriceInCents: json['unitPriceInCents'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'productId': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceInCents != null) 'unitPriceInCents': unitPriceInCents,
      if (description != null) 'description': description,
    };
  }

  int get finalUnitPrice => unitPriceInCents ?? invoiceItemUnitPrice ?? 0;
  int get finalQuantity => quantity ?? invoiceItemQuantity ?? 1;
  
  String get formattedPrice => 'R\$ ${(finalUnitPrice / 100).toStringAsFixed(2)}';
  String get formattedTotal => 'R\$ ${((finalUnitPrice * finalQuantity) / 100).toStringAsFixed(2)}';
  
  String get typeDisplay {
    switch (planType) {
      case 'RECURRENT': return 'Recorrente';
      case 'UNIQUE': return 'Único';
      default: return planType ?? 'Desconhecido';
    }
  }
  
  String get frequencyDisplay {
    switch (planFrequency) {
      case 'DAILY': return 'Diário';
      case 'WEEKLY': return 'Semanal';
      case 'MONTHLY': return 'Mensal';
      case 'YEARLY': return 'Anual';
      default: return planFrequency ?? '-';
    }
  }
}

class PaymentMethod {
  final String? method;
  final int? amountOff;
  final CardSettings? cardSettings;
  final PixSettings? pixSettings;

  PaymentMethod({
    this.method,
    this.amountOff,
    this.cardSettings,
    this.pixSettings,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      method: json['method'],
      amountOff: json['amountOff'],
      cardSettings: json['cardSettings'] != null ? CardSettings.fromJson(json['cardSettings']) : null,
      pixSettings: json['pixSettings'] != null ? PixSettings.fromJson(json['pixSettings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (method != null) 'method': method,
      if (amountOff != null) 'amountOff': amountOff,
      if (cardSettings != null) 'cardSettings': cardSettings!.toJson(),
      if (pixSettings != null) 'pixSettings': pixSettings!.toJson(),
    };
  }

  String get methodName {
    switch (method) {
      case 'CREDIT_CARD':
        return 'Cartão de Crédito';
      case 'PIX':
        return 'PIX';
      case 'BANK_SLIP':
        return 'Boleto';
      default:
        return method ?? 'Desconhecido';
    }
  }
}

class CardSettings {
  final int? maxInstallments;
  final bool? feePassThrough;
  final String? softDescriptor;
  final int? maxInstallmentsWithoutFees;

  CardSettings({
    this.maxInstallments,
    this.feePassThrough,
    this.softDescriptor,
    this.maxInstallmentsWithoutFees,
  });

  factory CardSettings.fromJson(Map<String, dynamic> json) {
    return CardSettings(
      maxInstallments: json['maxInstallments'],
      feePassThrough: json['feePassThrough'],
      softDescriptor: json['softDescriptor'],
      maxInstallmentsWithoutFees: json['maxInstallmentsWithoutFees'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (maxInstallments != null) 'maxInstallments': maxInstallments,
      if (feePassThrough != null) 'feePassThrough': feePassThrough,
      if (softDescriptor != null) 'softDescriptor': softDescriptor,
      if (maxInstallmentsWithoutFees != null) 'maxInstallmentsWithoutFees': maxInstallmentsWithoutFees,
    };
  }
}

class PixSettings {
  final int? expirationMinutes;

  PixSettings({
    this.expirationMinutes,
  });

  factory PixSettings.fromJson(Map<String, dynamic> json) {
    return PixSettings(
      expirationMinutes: json['expirationMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (expirationMinutes != null) 'expirationMinutes': expirationMinutes,
    };
  }
}
