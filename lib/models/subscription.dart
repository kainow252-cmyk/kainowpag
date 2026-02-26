import 'payment_status.dart';

class Subscription {
  final int? id;
  final String? customerId;
  final String? customerName;
  final String? customerEmail;
  final String? customerDocument;
  final String? productId;
  final String? productName;
  final String status; // ACTIVE, PENDING, OVERDUE, CANCELED, COUNTERCHARGE, CHARGEBACK
  final String billingType; // AUTOMATIC, MANUAL
  final String cycle; // MONTHLY, YEARLY
  final int valueInCents;
  final int? createdAt;
  final int? nextChargeDate;
  final String? notificationUrl;

  Subscription({
    this.id,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.customerDocument,
    this.productId,
    this.productName,
    required this.status,
    required this.billingType,
    required this.cycle,
    required this.valueInCents,
    this.createdAt,
    this.nextChargeDate,
    this.notificationUrl,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      customerId: json['customerId']?.toString(),
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerDocument: json['customerDocument'],
      productId: json['productId']?.toString(),
      productName: json['productName'],
      status: json['status'] ?? 'PENDING',
      billingType: json['billingType'] ?? 'AUTOMATIC',
      cycle: json['cycle'] ?? 'MONTHLY',
      valueInCents: json['valueInCents'] ?? json['value'] ?? 0,
      createdAt: json['createdAt'],
      nextChargeDate: json['nextChargeDate'],
      notificationUrl: json['notificationUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (customerId != null) 'customerId': customerId,
      if (customerName != null) 'customerName': customerName,
      if (customerEmail != null) 'customerEmail': customerEmail,
      if (customerDocument != null) 'customerDocument': customerDocument,
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      'status': status,
      'billingType': billingType,
      'cycle': cycle,
      'valueInCents': valueInCents,
      if (createdAt != null) 'createdAt': createdAt,
      if (nextChargeDate != null) 'nextChargeDate': nextChargeDate,
      if (notificationUrl != null) 'notificationUrl': notificationUrl,
    };
  }

  String get statusText => PaymentStatus.getOrderName(status);
  String get statusDescription => PaymentStatus.getOrderDescription(status);

  String get cycleText {
    switch (cycle) {
      case 'MONTHLY':
        return 'Mensal';
      case 'YEARLY':
        return 'Anual';
      case 'WEEKLY':
        return 'Semanal';
      default:
        return cycle;
    }
  }

  String get billingTypeText {
    switch (billingType) {
      case 'AUTOMATIC':
        return 'Automática';
      case 'MANUAL':
        return 'Manual';
      default:
        return billingType;
    }
  }
}
