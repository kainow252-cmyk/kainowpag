import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/customer.dart' as customer_model;
import '../models/product.dart';

/// Serviço de armazenamento local para cache de clientes e produtos
/// A API DeltaPag não fornece endpoints GET para listar recursos,
/// então usamos cache local para manter registro dos itens criados
class LocalStorageService {
  static const String _customersKey = 'cached_customers';
  static const String _productsKey = 'cached_products';

  // CLIENTES
  
  /// Salva um cliente no cache local
  Future<void> saveCustomer(customer_model.Customer customer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customers = await getCustomers();
      
      // Evitar duplicatas (por documento)
      customers.removeWhere((c) => c.document == customer.document);
      customers.add(customer);
      
      // Salvar lista atualizada
      final customersJson = customers.map((c) => c.toJson()).toList();
      await prefs.setString(_customersKey, jsonEncode(customersJson));
      
      if (kDebugMode) {
        debugPrint('Cliente salvo no cache: ${customer.name} (${customer.document})');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar cliente no cache: $e');
      }
    }
  }
  
  /// Busca todos os clientes do cache local
  Future<List<customer_model.Customer>> getCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customersString = prefs.getString(_customersKey);
      
      if (customersString == null || customersString.isEmpty) {
        return [];
      }
      
      final List<dynamic> customersJson = jsonDecode(customersString);
      return customersJson
          .map((json) => customer_model.Customer.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao buscar clientes do cache: $e');
      }
      return [];
    }
  }
  
  /// Busca um cliente por documento no cache local
  Future<customer_model.Customer?> getCustomerByDocument(String document) async {
    try {
      final customers = await getCustomers();
      return customers.firstWhere(
        (c) => c.document == document,
        orElse: () => throw Exception('Cliente não encontrado'),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Remove um cliente do cache local
  Future<void> deleteCustomer(String document) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customers = await getCustomers();
      
      customers.removeWhere((c) => c.document == document);
      
      final customersJson = customers.map((c) => c.toJson()).toList();
      await prefs.setString(_customersKey, jsonEncode(customersJson));
      
      if (kDebugMode) {
        debugPrint('Cliente removido do cache: $document');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao remover cliente do cache: $e');
      }
    }
  }

  // PRODUTOS
  
  /// Salva um produto no cache local
  Future<void> saveProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final products = await getProducts();
      
      // Evitar duplicatas (por ID se disponível, senão por nome)
      if (product.id != null) {
        products.removeWhere((p) => p.id == product.id);
      } else {
        products.removeWhere((p) => p.name == product.name);
      }
      products.add(product);
      
      // Salvar lista atualizada
      final productsJson = products.map((p) => p.toJson()).toList();
      await prefs.setString(_productsKey, jsonEncode(productsJson));
      
      if (kDebugMode) {
        debugPrint('Produto salvo no cache: ${product.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar produto no cache: $e');
      }
    }
  }
  
  /// Busca todos os produtos do cache local
  Future<List<Product>> getProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsString = prefs.getString(_productsKey);
      
      if (productsString == null || productsString.isEmpty) {
        return [];
      }
      
      final List<dynamic> productsJson = jsonDecode(productsString);
      return productsJson
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao buscar produtos do cache: $e');
      }
      return [];
    }
  }
  
  /// Busca um produto por ID no cache local
  Future<Product?> getProductById(int id) async {
    try {
      final products = await getProducts();
      return products.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Produto não encontrado'),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Remove um produto do cache local
  Future<void> deleteProduct(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final products = await getProducts();
      
      products.removeWhere((p) => p.id == id);
      
      final productsJson = products.map((p) => p.toJson()).toList();
      await prefs.setString(_productsKey, jsonEncode(productsJson));
      
      if (kDebugMode) {
        debugPrint('Produto removido do cache: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao remover produto do cache: $e');
      }
    }
  }
  
  /// Limpa todo o cache (útil para reset ou logout)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_customersKey);
      await prefs.remove(_productsKey);
      
      if (kDebugMode) {
        debugPrint('Cache limpo completamente');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao limpar cache: $e');
      }
    }
  }
}
