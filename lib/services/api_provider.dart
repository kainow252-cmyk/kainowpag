import 'package:flutter/foundation.dart';
import '../models/customer.dart' as customer_model;
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/charge.dart';
import '../models/subscription.dart';
import '../models/dashboard_stats.dart';
import 'deltapag_api.dart';
import 'deltapag_mock_simple.dart';
import 'local_storage_service.dart';

/// Provider que gerencia o modo da API (sempre modo REAL)
class APIProvider with ChangeNotifier {
  bool _isDemoMode = false; // SEMPRE modo REAL (conectado à API DeltaPag)
  
  final DeltaPagAPI _realAPI = DeltaPagAPI();
  final DeltaPagMock _mockAPI = DeltaPagMock();
  final LocalStorageService _storage = LocalStorageService();
  
  bool get isDemoMode => _isDemoMode;
  
  void toggleMode() {
    _isDemoMode = !_isDemoMode;
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('Modo API alterado para: ${_isDemoMode ? "DEMO (Mock)" : "REAL (DeltaPag)"}');
    }
  }
  
  void setDemoMode(bool enabled) {
    _isDemoMode = enabled;
    notifyListeners();
  }

  // CLIENTES
  Future<customer_model.Customer?> createCustomer(customer_model.Customer customer) async {
    if (_isDemoMode) {
      return _mockAPI.createCustomer(customer);
    } else {
      final created = await _realAPI.createCustomer(customer);
      if (created != null) {
        // Salvar no cache local para exibição posterior
        await _storage.saveCustomer(created);
      }
      return created;
    }
  }

  /// Lista clientes: combina dados reais da API (de faturas/cobranças) + cache local
  Future<List<customer_model.Customer>> listCustomers() async {
    if (_isDemoMode) {
      return _storage.getCustomers();
    } else {
      try {
        // Buscar clientes reais da API (extraídos de faturas e cobranças)
        final apiCustomers = await _realAPI.listCustomersFromTransactions();
        
        // Buscar clientes do cache local (criados pelo app)
        final cachedCustomers = await _storage.getCustomers();
        
        // Combinar ambos, evitando duplicatas por documento
        final Map<String, customer_model.Customer> uniqueCustomers = {};
        
        // Adicionar clientes da API primeiro (dados mais atualizados)
        for (var customer in apiCustomers) {
          uniqueCustomers[customer.document] = customer;
        }
        
        // Adicionar clientes do cache (apenas os que não existem na API)
        for (var customer in cachedCustomers) {
          if (!uniqueCustomers.containsKey(customer.document)) {
            uniqueCustomers[customer.document] = customer;
          }
        }
        
        return uniqueCustomers.values.toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error listing customers: $e');
        }
        // Em caso de erro, retornar apenas do cache
        return _storage.getCustomers();
      }
    }
  }

  Future<customer_model.Customer?> getCustomerByDocument(String document) async {
    if (_isDemoMode) {
      return _mockAPI.getCustomerByDocument(document);
    } else {
      // Tentar buscar no cache primeiro
      final cached = await _storage.getCustomerByDocument(document);
      if (cached != null) return cached;
      
      // Se não encontrou no cache, buscar na API
      final fromAPI = await _realAPI.getCustomerByDocument(document);
      if (fromAPI != null) {
        // Salvar no cache para próxima vez
        await _storage.saveCustomer(fromAPI);
      }
      return fromAPI;
    }
  }

  Future<bool> checkCustomerExists(String document) {
    return _isDemoMode
        ? _mockAPI.checkCustomerExists(document)
        : _realAPI.checkCustomerExists(document);
  }

  // PRODUTOS
  Future<Product?> createProduct(Product product) async {
    if (_isDemoMode) {
      return _mockAPI.createProduct(product);
    } else {
      final created = await _realAPI.createProduct(product);
      if (created != null) {
        // Salvar no cache local para exibição posterior
        await _storage.saveProduct(created);
      }
      return created;
    }
  }

  Future<Product?> getProduct(int id) async {
    if (_isDemoMode) {
      return _mockAPI.getProduct(id);
    } else {
      // Tentar buscar no cache primeiro
      final cached = await _storage.getProductById(id);
      if (cached != null) return cached;
      
      // API DeltaPag não tem endpoint GET individual para produtos
      return null;
    }
  }

  /// Lista produtos: combina dados reais da API (busca por ID) + cache local
  Future<List<Product>> listProducts() async {
    if (_isDemoMode) {
      return _mockAPI.listProducts();
    } else {
      try {
        // Buscar produtos reais da API (testando IDs sequenciais)
        final apiProducts = await _realAPI.listAllProducts();
        
        // Buscar produtos do cache local (criados pelo app)
        final cachedProducts = await _storage.getProducts();
        
        // Combinar ambos, evitando duplicatas por ID
        final Map<int, Product> uniqueProducts = {};
        
        // Adicionar produtos da API primeiro (dados mais atualizados)
        for (var product in apiProducts) {
          if (product.id != null) {
            uniqueProducts[product.id!] = product;
          }
        }
        
        // Adicionar produtos do cache (apenas os que não existem na API)
        for (var product in cachedProducts) {
          if (product.id != null && !uniqueProducts.containsKey(product.id)) {
            uniqueProducts[product.id!] = product;
          } else if (product.id == null) {
            // Produtos sem ID (criados localmente) sempre são adicionados
            uniqueProducts[DateTime.now().millisecondsSinceEpoch] = product;
          }
        }
        
        // Salvar produtos da API no cache para próxima vez
        for (var product in apiProducts) {
          await _storage.saveProduct(product);
        }
        
        return uniqueProducts.values.toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error listing products: $e');
        }
        // Em caso de erro, retornar apenas do cache
        return _storage.getProducts();
      }
    }
  }

  // FATURAS
  Future<Invoice?> createInvoice(int sellerId, Invoice invoice) {
    return _isDemoMode
        ? _mockAPI.createInvoice(sellerId, invoice)
        : _realAPI.createInvoice(sellerId, invoice);
  }

  Future<Invoice?> getInvoice(int id) {
    return _isDemoMode
        ? _mockAPI.getInvoice(id)
        : _realAPI.getInvoice(id);
  }

  Future<List<Invoice>> listInvoices({
    String? invoiceNumber,
    int? dueDateFrom,
    int? dueDateTo,
    String? document,
    int page = 0,
    int size = 20,
  }) {
    return _isDemoMode
        ? _mockAPI.listInvoices(
            invoiceNumber: invoiceNumber,
            dueDateFrom: dueDateFrom,
            dueDateTo: dueDateTo,
            document: document,
            page: page,
            size: size,
          )
        : _realAPI.listInvoices(
            invoiceNumber: invoiceNumber,
            dueDateFrom: dueDateFrom,
            dueDateTo: dueDateTo,
            document: document,
            page: page,
            size: size,
          );
  }

  Future<bool> sendInvoiceEmail(int invoiceId) {
    return _isDemoMode
        ? _mockAPI.sendInvoiceEmail(invoiceId)
        : _realAPI.sendInvoiceEmail(invoiceId);
  }

  // COBRANÇAS
  Future<Charge?> createCharge(Charge charge) {
    return _isDemoMode
        ? _mockAPI.createCharge(charge)
        : _realAPI.createCharge(charge);
  }

  Future<bool> captureCharge(int chargeId) {
    return _isDemoMode
        ? _mockAPI.captureCharge(chargeId)
        : _realAPI.captureCharge(chargeId);
  }

  Future<bool> refundCharge(int chargeId, {required String reason, int? amount}) {
    return _isDemoMode
        ? _mockAPI.refundCharge(chargeId, reason: reason, amount: amount)
        : _realAPI.refundCharge(chargeId, reason: reason, amount: amount);
  }

  Future<bool> cancelBoleto(int chargeId) {
    return _isDemoMode
        ? _mockAPI.cancelBoleto(chargeId)
        : _realAPI.cancelBoleto(chargeId);
  }

  Future<bool> cancelPix(int chargeId) {
    return _isDemoMode
        ? _mockAPI.cancelPix(chargeId)
        : _realAPI.cancelPix(chargeId);
  }

  // ASSINATURAS
  Future<List<Subscription>> listSubscriptions({String? status, int page = 0, int size = 20}) {
    return _isDemoMode
        ? _mockAPI.listSubscriptions(status: status, page: page, size: size)
        : _realAPI.listSubscriptions(status: status, page: page, size: size);
  }

  Future<Subscription?> getSubscription(int id) {
    return _isDemoMode
        ? _mockAPI.getSubscription(id)
        : _realAPI.getSubscription(id);
  }

  Future<bool> cancelSubscription(int subscriptionId) {
    return _isDemoMode
        ? _mockAPI.cancelSubscription(subscriptionId)
        : _realAPI.cancelSubscription(subscriptionId);
  }

  // DASHBOARD STATS
  Future<DashboardStats> getDashboardStats() {
    return _isDemoMode
        ? _mockAPI.getDashboardStats()
        : _realAPI.getDashboardStats();
  }
}
