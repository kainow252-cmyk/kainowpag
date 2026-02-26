import 'package:flutter/foundation.dart';
import '../models/customer.dart' as customer_model;
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/charge.dart';
import '../models/subscription.dart';
import '../models/dashboard_stats.dart';

class DeltaPagMock {
  final List<customer_model.Customer> _customers = [];
  final List<Product> _products = [];
  final List<Invoice> _invoices = [];
  final List<Charge> _charges = [];
  final List<Subscription> _subscriptions = [];
  
  int _nextCustomerId = 1;
  int _nextProductId = 1;
  int _nextInvoiceId = 1;
  int _nextChargeId = 1;
  int _nextSubscriptionId = 1;

  DeltaPagMock();

  // CLIENTES
  Future<customer_model.Customer?> createCustomer(customer_model.Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newCustomer = customer_model.Customer(
      id: _nextCustomerId++,
      name: customer.name,
      document: customer.document,
      email: customer.email,
      birthdate: customer.birthdate,
      phone: customer.phone,
      address: customer.address,
    );
    
    _customers.add(newCustomer);
    if (kDebugMode) debugPrint('Mock: Cliente criado - ID: ${newCustomer.id}');
    return newCustomer;
  }

  Future<customer_model.Customer?> getCustomerByDocument(String document) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _customers.firstWhere((c) => c.document == document);
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkCustomerExists(String document) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _customers.any((c) => c.document == document);
  }

  // PRODUTOS
  Future<Product?> createProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newProduct = Product(
      id: _nextProductId++,
      productType: product.productType,
      affiliateId: product.affiliateId,
      themeId: product.themeId,
      name: product.name,
      description: product.description,
      value: product.value,
      maxInstallments: product.maxInstallments,
      methods: product.methods,
    );
    
    _products.add(newProduct);
    if (kDebugMode) debugPrint('Mock: Produto criado - ID: ${newProduct.id}');
    return newProduct;
  }

  Future<Product?> getProduct(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Product>> listProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_products);
  }

  // FATURAS
  Future<Invoice?> createInvoice(int sellerId, Invoice invoice) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final newInvoice = Invoice(
      id: _nextInvoiceId++,
      customerId: invoice.customerId,
      invoiceNumber: invoice.invoiceNumber,
      dueDate: invoice.dueDate,
      notificationUrl: invoice.notificationUrl,
      successUrl: invoice.successUrl,
      items: invoice.items,
      acceptedPaymentMethods: invoice.acceptedPaymentMethods,
      status: 'OPEN',
      paymentUrl: 'https://checkout.deltapag.io/demo/invoice-${_nextInvoiceId - 1}',
    );
    
    _invoices.add(newInvoice);
    if (kDebugMode) debugPrint('Mock: Fatura criada - ID: ${newInvoice.id}');
    return newInvoice;
  }

  Future<Invoice?> getInvoice(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _invoices.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Invoice>> listInvoices({
    String? invoiceNumber,
    int? dueDateFrom,
    int? dueDateTo,
    String? document,
    int page = 0,
    int size = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    var filtered = List<Invoice>.from(_invoices);
    
    if (invoiceNumber != null) {
      filtered = filtered.where((i) => i.invoiceNumber?.contains(invoiceNumber) ?? false).toList();
    }
    
    filtered.sort((a, b) => (b.dueDate ?? 0).compareTo(a.dueDate ?? 0));
    
    final start = page * size;
    final end = (start + size).clamp(0, filtered.length);
    
    if (start >= filtered.length) return [];
    
    return filtered.sublist(start, end);
  }

  Future<bool> sendInvoiceEmail(int invoiceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (kDebugMode) debugPrint('Mock: Email de fatura enviado - ID: $invoiceId');
    return true;
  }

  // COBRANÇAS
  Future<Charge?> createCharge(Charge charge) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final newCharge = Charge(
      id: _nextChargeId++,
      customer: charge.customer,
      value: charge.value,
      installments: charge.installments,
      status: 'AUTHORIZED',
      notificationUrl: charge.notificationUrl,
      card: charge.card,
    );
    
    _charges.add(newCharge);
    if (kDebugMode) debugPrint('Mock: Cobrança criada - ID: ${newCharge.id}');
    return newCharge;
  }

  Future<bool> captureCharge(int chargeId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (kDebugMode) debugPrint('Mock: Cobrança capturada - ID: $chargeId');
    return true;
  }

  Future<bool> refundCharge(int chargeId, {required String reason, int? amount}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (kDebugMode) debugPrint('Mock: Cobrança estornada - ID: $chargeId');
    return true;
  }

  Future<bool> cancelBoleto(int chargeId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (kDebugMode) debugPrint('Mock: Boleto cancelado - Charge ID: $chargeId');
    return true;
  }

  Future<bool> cancelPix(int chargeId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (kDebugMode) debugPrint('Mock: PIX cancelado - Charge ID: $chargeId');
    return true;
  }

  // ASSINATURAS
  Future<List<Subscription>> listSubscriptions({String? status, int page = 0, int size = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    var filtered = List<Subscription>.from(_subscriptions);
    
    if (status != null) {
      filtered = filtered.where((s) => s.status == status).toList();
    }
    
    final start = page * size;
    final end = (start + size).clamp(0, filtered.length);
    
    if (start >= filtered.length) return [];
    
    return filtered.sublist(start, end);
  }

  Future<Subscription?> getSubscription(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _subscriptions.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelSubscription(int subscriptionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (kDebugMode) debugPrint('Mock: Assinatura cancelada - ID: $subscriptionId');
    return true;
  }

  // DASHBOARD STATS
  Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return DashboardStats(
      totalCustomers: _customers.length,
      totalProducts: _products.length,
      totalInvoices: _invoices.length,
      totalCharges: _charges.length,
      totalSubscriptions: _subscriptions.length,
      todayChargesValue: 0.0,
      todayChargesCount: 0,
      monthChargesValue: 159.60,
      monthChargesCount: 4,
      averageTicket: 39.90,
      tpvByDate: {
        '20/02': 50.0,
        '21/02': 80.0,
        '22/02': 120.0,
        '23/02': 200.0,
        '24/02': 159.60,
      },
      cardBrands: {
        'Mastercard': 3,
        'Visa': 1,
      },
      paymentMethods: {
        'CREDIT_CARD': 4,
      },
    );
  }
}
