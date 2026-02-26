import 'package:flutter/foundation.dart';
import '../models/customer.dart' as customer_model;
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/charge.dart';
import '../models/subscription.dart';
import '../models/dashboard_stats.dart';

/// Serviço mock para demonstração do app Kainowpag
/// Simula a API DeltaPag com dados fictícios
class DeltaPagMock {
  // Dados mockados
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

  DeltaPagMock() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Adicionar alguns dados de exemplo
    _customers.addAll([
      customer_model.Customer(
        id: _nextCustomerId++,
        name: 'João Silva',
        document: '12345678901',
        email: 'joao@example.com',
        birthdate: '1990-01-15',
        phones: [
          customer_model.Phone(countryCode: 55, areaCode: 11, number: 987654321),
        ],
        addresses: [
          customer_model.Address(
            street: 'Rua das Flores',
            streetNumber: '123',
            neighborhood: 'Centro',
            city: 'São Paulo',
            state: 'SP',
            zipCode: '01234567',
          ),
        ],
      ),
      customer_model.Customer(
        id: _nextCustomerId++,
        name: 'Maria Santos',
        document: '98765432100',
        email: 'maria@example.com',
        birthdate: '1985-05-20',
        phones: [
          customer_model.Phone(countryCode: 55, areaCode: 21, number: 912345678),
        ],
        addresses: [
          customer_model.Address(
            street: 'Av. Principal',
            streetNumber: '456',
            neighborhood: 'Copacabana',
            city: 'Rio de Janeiro',
            state: 'RJ',
            zipCode: '22070000',
          ),
        ],
      ),
    ]);

    _products.addAll([
      Product(
        id: _nextProductId++,
        productType: 'ONETIME',
        affiliateId: 1,
        name: 'Curso Flutter Completo',
        description: 'Aprenda Flutter do zero ao avançado',
        value: 99900, // R$ 999,00
        maxInstallments: 12,
        methods: ['CREDIT_CARD', 'PIX', 'BOLETO'],
      ),
      Product(
        id: _nextProductId++,
        productType: 'SUBSCRIPTION',
        affiliateId: 1,
        name: 'Assinatura Premium',
        description: 'Acesso completo a todos os cursos',
        value: 29900, // R$ 299,00/mês
        maxInstallments: 1,
        methods: ['CREDIT_CARD'],
      ),
    ]);

    _invoices.addAll([
      Invoice(
        id: _nextInvoiceId++,
        customerId: 1,
        invoiceNumber: 'INV-2024-001',
        dueDate: DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
        status: 'OPEN',
        items: [
          InvoiceItem(productId: 1, quantity: 1, unitPriceInCents: 99900),
        ],
        acceptedPaymentMethods: ['CREDIT_CARD', 'PIX', 'BOLETO'],
        paymentUrl: 'https://checkout.deltapag.io/demo/invoice-001',
      ),
      Invoice(
        id: _nextInvoiceId++,
        customerId: 2,
        invoiceNumber: 'INV-2024-002',
        dueDate: DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        status: 'PAID',
        items: [
          InvoiceItem(productId: 2, quantity: 1, unitPriceInCents: 29900),
        ],
        acceptedPaymentMethods: ['CREDIT_CARD'],
        paymentUrl: 'https://checkout.deltapag.io/demo/invoice-002',
      ),
    ]);

    _subscriptions.addAll([
      Subscription(
        id: _nextSubscriptionId++,
        customerName: 'Gilson Pereira da Silva',
        customerEmail: 'gilsonpereira4228@gmail.com',
        customerDocument: '12345678901',
        productName: 'assistencias',
        status: 'ACTIVE',
        billingType: 'AUTOMATIC',
        cycle: 'MONTHLY',
        valueInCents: 3990,
        createdAt: DateTime(2026, 2, 25).millisecondsSinceEpoch,
        nextChargeDate: DateTime.now().add(const Duration(days: 10)).millisecondsSinceEpoch,
      ),
      Subscription(
        id: _nextSubscriptionId++,
        customerName: 'FELIPE OLIVEIRA DE CARVALHO',
        customerEmail: 'felipeoliveiracarvalho@gmail.com',
        customerDocument: '98765432100',
        productName: 'assistencias',
        status: 'PENDING',
        billingType: 'AUTOMATIC',
        cycle: 'MONTHLY',
        valueInCents: 3990,
        createdAt: DateTime(2026, 2, 25).millisecondsSinceEpoch,
      ),
      Subscription(
        id: _nextSubscriptionId++,
        customerName: 'GELCI JOSE DA SILVA',
        customerEmail: 'gelci@email.com',
        customerDocument: '11122233344',
        productName: 'assistencias',
        status: 'OVERDUE',
        billingType: 'AUTOMATIC',
        cycle: 'MONTHLY',
        valueInCents: 3990,
        createdAt: DateTime(2026, 2, 25).millisecondsSinceEpoch,
      ),
    ]);
  }

  // CLIENTES
  Future<customer_model.Customer?> createCustomer(customer_model.Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular latência de rede
    
    final newCustomer = customer_model.Customer(
      id: _nextCustomerId++,
      name: customer.name,
      document: customer.document,
      email: customer.email,
      birthdate: customer.birthdate,
      phones: customer.phones,
      addresses: customer.addresses,
    );
    
    _customers.add(newCustomer);
    
    if (kDebugMode) {
      debugPrint('Mock: Cliente criado - ID: ${newCustomer.id}, Nome: ${newCustomer.name}');
    }
    
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
      name: product.name,
      description: product.description,
      value: product.value,
      maxInstallments: product.maxInstallments,
      methods: product.methods,
    );
    
    _products.add(newProduct);
    
    if (kDebugMode) {
      debugPrint('Mock: Produto criado - ID: ${newProduct.id}, Nome: ${newProduct.name}');
    }
    
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
    
    if (kDebugMode) {
      debugPrint('Mock: Fatura criada - ID: ${newInvoice.id}, Número: ${newInvoice.invoiceNumber}');
    }
    
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
      filtered = filtered.where((i) => i.invoiceNumber.contains(invoiceNumber)).toList();
    }
    
    if (dueDateFrom != null) {
      filtered = filtered.where((i) => i.dueDate >= dueDateFrom).toList();
    }
    
    if (dueDateTo != null) {
      filtered = filtered.where((i) => i.dueDate <= dueDateTo).toList();
    }
    
    // Ordenar por data de vencimento (mais recentes primeiro)
    filtered.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    
    // Paginação
    final start = page * size;
    final end = (start + size).clamp(0, filtered.length);
    
    if (start >= filtered.length) return [];
    
    return filtered.sublist(start, end);
  }

  Future<bool> sendInvoiceEmail(int invoiceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (kDebugMode) {
      debugPrint('Mock: Email de fatura enviado para invoice ID: $invoiceId');
    }
    
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
    
    if (kDebugMode) {
      debugPrint('Mock: Cobrança criada - ID: ${newCharge.id}, Valor: R\$ ${(newCharge.value / 100).toStringAsFixed(2)}');
    }
    
    return newCharge;
  }

  Future<bool> captureCharge(int chargeId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (kDebugMode) {
      debugPrint('Mock: Cobrança capturada - ID: $chargeId');
    }
    
    return true;
  }

  Future<bool> refundCharge(int chargeId, {required String reason, int? amount}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (kDebugMode) {
      debugPrint('Mock: Cobrança estornada - ID: $chargeId, Motivo: $reason');
    }
    
    return true;
  }

  Future<bool> cancelBoleto(int chargeId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (kDebugMode) {
      debugPrint('Mock: Boleto cancelado - Charge ID: $chargeId');
    }
    
    return true;
  }

  Future<bool> cancelPix(int chargeId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (kDebugMode) {
      debugPrint('Mock: PIX cancelado - Charge ID: $chargeId');
    }
    
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
    
    if (kDebugMode) {
      debugPrint('Mock: Assinatura cancelada - ID: $subscriptionId');
    }
    
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
