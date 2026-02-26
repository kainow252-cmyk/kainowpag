import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/customer.dart' as customer_model;
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/charge.dart';
import '../models/subscription.dart';
import '../models/dashboard_stats.dart';
import '../models/webhook.dart';

class DeltaPagAPI {
  // ✅ API DeltaPag PRODUÇÃO OFICIAL
  // URL: https://api.deltapag.io/api/v2
  // Painel: https://painel.deltapag.io
  static const String baseUrl = 'https://api.deltapag.io/api/v2';
  static const String token = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI3ODYiLCJ0ZW5hbnQiOiJiZW1wYWdnb19rYWlub3dwcm9tb2Nhb2RldmVuXzJfMjc5MjM3NDYwMDAxMjMiLCJpYXQiOjE3NzIwOTY5NDIsImV4cCI6NDEwMjM1ODM5OSwiaXNNYXN0ZXIiOnRydWV9.gjqYDIeIQPln2SMzxVCsFhSKLNrkSmmZ-TX3EypJOsF_t_Iofy_kLVFOAgqD8LKVzgSMidVFOZX_l2ILaRKhPw';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // CLIENTES
  Future<customer_model.Customer?> createCustomer(customer_model.Customer customer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: _headers,
        body: jsonEncode(customer.toJson()),
      );

      if (kDebugMode) {
        debugPrint('Create Customer Response: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        debugPrint('Response Headers: ${response.headers}');
      }

      if (response.statusCode == 201) {
        // API retorna 201 com Location header
        final locationHeader = response.headers['location'];
        if (locationHeader != null) {
          if (kDebugMode) {
            debugPrint('Location Header: $locationHeader');
          }
          // Buscar o cliente criado
          return await getCustomerFromLocation(locationHeader);
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating customer: $e');
      }
      rethrow;
    }
  }

  Future<customer_model.Customer?> getCustomerFromLocation(String location) async {
    try {
      final response = await http.get(
        Uri.parse(location),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return customer_model.Customer.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting customer from location: $e');
      }
      return null;
    }
  }

  Future<customer_model.Customer?> getCustomerByDocument(String document) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/document/$document'),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        
        // Verificar se é um array de erro (quando cliente não existe)
        if (decoded is List) {
          if (kDebugMode) {
            debugPrint('❌ Cliente não encontrado: $document');
          }
          return null;
        }
        
        // Cliente encontrado
        return customer_model.Customer.fromJson(decoded);
      }
      
      // Status 422 ou outro erro = cliente não existe
      if (response.statusCode == 422) {
        if (kDebugMode) {
          debugPrint('❌ Cliente não encontrado (422): $document');
        }
        return null;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting customer: $e');
      }
      return null;
    }
  }

  Future<bool> checkCustomerExists(String document) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/document/$document/check'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking customer: $e');
      }
      return false;
    }
  }

  /// Lista todos os clientes únicos extraídos de faturas e cobranças
  /// A API DeltaPag não tem endpoint direto para listar clientes,
  /// mas podemos extrair da lista de faturas e cobranças
  Future<List<customer_model.Customer>> listCustomersFromTransactions() async {
    try {
      final Map<String, customer_model.Customer> uniqueCustomers = {};
      
      // 1. Buscar clientes de faturas
      try {
        final invoicesResponse = await http.get(
          Uri.parse('$baseUrl/invoices?page=0&size=100'),
          headers: _headers,
        );
        
        if (invoicesResponse.statusCode == 200 && invoicesResponse.body.isNotEmpty) {
          final invoicesData = jsonDecode(invoicesResponse.body);
          final List<dynamic> invoices = invoicesData['content'] ?? [];
          
          for (var invoice in invoices) {
            final customerData = invoice['customer'];
            if (customerData != null && customerData['document'] != null) {
              final document = customerData['document'];
              if (!uniqueCustomers.containsKey(document)) {
                uniqueCustomers[document] = customer_model.Customer(
                  id: customerData['id'],
                  name: customerData['name'] ?? 'Cliente',
                  document: document,
                  email: customerData['email'],
                  phone: customerData['phone'] != null 
                      ? customer_model.Phone(
                          countryCode: customerData['phone']['countryCode'] ?? 55,
                          areaCode: customerData['phone']['areaCode'] ?? 0,
                          number: customerData['phone']['number'] ?? 0,
                        )
                      : null,
                );
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error fetching customers from invoices: $e');
        }
      }
      
      // 2. Buscar clientes de cobranças
      try {
        final chargesResponse = await http.get(
          Uri.parse('$baseUrl/charges?page=0&size=100'),
          headers: _headers,
        );
        
        if (chargesResponse.statusCode == 200 && chargesResponse.body.isNotEmpty) {
          final chargesData = jsonDecode(chargesResponse.body);
          List<dynamic> charges = [];
          
          if (chargesData is List) {
            charges = chargesData;
          } else if (chargesData is Map && chargesData['content'] != null) {
            charges = chargesData['content'];
          }
          
          for (var charge in charges) {
            if (charge['customer'] != null) {
              final customerData = charge['customer'];
              if (customerData['document'] != null) {
                final document = customerData['document'];
                if (!uniqueCustomers.containsKey(document)) {
                  uniqueCustomers[document] = customer_model.Customer(
                    id: customerData['id'],
                    name: customerData['name'] ?? 'Cliente',
                    document: document,
                    email: customerData['email'],
                    phone: customerData['phone'] != null 
                        ? customer_model.Phone(
                            countryCode: customerData['phone']['countryCode'] ?? 55,
                            areaCode: customerData['phone']['areaCode'] ?? 0,
                            number: customerData['phone']['number'] ?? 0,
                          )
                        : null,
                  );
                }
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error fetching customers from charges: $e');
        }
      }
      
      return uniqueCustomers.values.toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error listing customers from transactions: $e');
      }
      return [];
    }
  }

  // PRODUTOS
  Future<Product?> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
        body: jsonEncode(product.toJson()),
      );

      if (kDebugMode) {
        debugPrint('Create Product Response: ${response.statusCode}');
        debugPrint('Response Headers: ${response.headers}');
      }

      if (response.statusCode == 201) {
        final locationHeader = response.headers['location'];
        if (locationHeader != null) {
          return await getProductFromLocation(locationHeader);
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating product: $e');
      }
      rethrow;
    }
  }

  Future<Product?> getProductFromLocation(String location) async {
    try {
      final response = await http.get(
        Uri.parse(location),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Product.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting product from location: $e');
      }
      return null;
    }
  }

  Future<Product?> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      );

      if (kDebugMode) {
        debugPrint('Get Product Response: ${response.statusCode}');
      }

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Product.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting product: $e');
      }
      return null;
    }
  }

  Future<Product?> updateProduct(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
        body: jsonEncode(product.toJson()),
      );

      if (kDebugMode) {
        debugPrint('Update Product Response: ${response.statusCode}');
      }

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Product.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating product: $e');
      }
      rethrow;
    }
  }

  /// Lista todos os produtos buscando sequencialmente por ID
  /// A API DeltaPag não tem endpoint GET /products para listagem,
  /// então testamos IDs de 1 até encontrar todos os produtos
  Future<List<Product>> listAllProducts() async {
    try {
      final List<Product> products = [];
      int consecutiveNotFound = 0;
      int currentId = 1;
      const int maxConsecutiveNotFound = 2; // OTIMIZADO: Parar após 2 IDs não encontrados (reduz 404s)
      const int maxProducts = 100; // Limite de segurança
      
      while (consecutiveNotFound < maxConsecutiveNotFound && products.length < maxProducts) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/products/$currentId'),
            headers: _headers,
          );
          
          if (response.statusCode == 200 && response.body.isNotEmpty) {
            final productData = jsonDecode(response.body);
            
            // Converter o formato da API para o modelo Product
            final product = Product(
              id: productData['id'],
              productType: productData['type'] ?? 'ONETIME',
              affiliateId: productData['checkout']?['affiliateMinimal']?['id'] ?? 1,
              name: productData['name'] ?? 'Produto',
              value: productData['value'] ?? 0,
              softDescriptor: productData['softDescriptor'],
              maxInstallments: productData['maxInstallments'] ?? 1,
              active: productData['active'] ?? true,
              methods: List<String>.from(productData['checkout']?['methods'] ?? ['CREDIT_CARD']),
              description: productData['checkout']?['description'],
              themeId: productData['checkout']?['theme']?['id'] ?? 1,
              feePassThrough: productData['checkout']?['feePassThrough'] ?? false,
            );
            
            products.add(product);
            consecutiveNotFound = 0; // Resetar contador
            
            if (kDebugMode) {
              debugPrint('Produto encontrado: ${product.name} (ID: ${product.id})');
            }
          } else {
            consecutiveNotFound++;
          }
        } catch (e) {
          consecutiveNotFound++;
        }
        
        currentId++;
      }
      
      if (kDebugMode) {
        debugPrint('Total de produtos encontrados: ${products.length}');
      }
      
      return products;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error listing all products: $e');
      }
      return [];
    }
  }

  // FATURAS
  Future<Invoice?> createInvoice(int sellerId, Invoice invoice) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sellers/$sellerId/invoices'),
        headers: _headers,
        body: jsonEncode(invoice.toJson()),
      );

      if (kDebugMode) {
        debugPrint('Create Invoice Response: ${response.statusCode}');
        debugPrint('Response Headers: ${response.headers}');
      }

      if (response.statusCode == 201) {
        final locationHeader = response.headers['location'];
        final linkHeader = response.headers['link'];
        
        if (kDebugMode) {
          debugPrint('Location: $locationHeader');
          debugPrint('Link (Payment URL): $linkHeader');
        }

        if (locationHeader != null) {
          final invoiceData = await getInvoiceFromLocation(locationHeader);
          if (invoiceData != null && linkHeader != null) {
            // Adicionar payment URL ao invoice
            return Invoice(
              id: invoiceData.id,
              customerId: invoiceData.customerId,
              invoiceNumber: invoiceData.invoiceNumber,
              dueDate: invoiceData.dueDate,
              notificationUrl: invoiceData.notificationUrl,
              successUrl: invoiceData.successUrl,
              items: invoiceData.items,
              acceptedPaymentMethods: invoiceData.acceptedPaymentMethods,
              status: invoiceData.status,
              paymentUrl: linkHeader,
            );
          }
          return invoiceData;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating invoice: $e');
      }
      rethrow;
    }
  }

  Future<Invoice?> getInvoiceFromLocation(String location) async {
    try {
      final response = await http.get(
        Uri.parse(location),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Invoice.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting invoice from location: $e');
      }
      return null;
    }
  }

  Future<Invoice?> getInvoice(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invoices/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Invoice.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting invoice: $e');
      }
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
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (invoiceNumber != null) queryParams['invoiceNumber'] = invoiceNumber;
      if (dueDateFrom != null) queryParams['dueDateFrom'] = dueDateFrom.toString();
      if (dueDateTo != null) queryParams['dueDateTo'] = dueDateTo.toString();
      if (document != null) queryParams['document'] = document;

      final uri = Uri.parse('$baseUrl/invoices').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data is Map && data['content'] != null) {
          return (data['content'] as List).map((json) => Invoice.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => Invoice.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error listing invoices: $e');
      }
      return [];
    }
  }

  Future<bool> sendInvoiceEmail(int invoiceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoices/$invoiceId/send-email'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending invoice email: $e');
      }
      return false;
    }
  }

  Future<bool> finalizeInvoice(int invoiceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoices/$invoiceId/finalize'),
        headers: _headers,
      );

      if (kDebugMode) {
        debugPrint('Finalize Invoice Response: ${response.statusCode}');
      }

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error finalizing invoice: $e');
      }
      return false;
    }
  }

  Future<bool> voidInvoice(int invoiceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoices/$invoiceId/void'),
        headers: _headers,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error voiding invoice: $e');
      }
      return false;
    }
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invoices/$invoiceId/items'),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((json) => InvoiceItem.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting invoice items: $e');
      }
      return [];
    }
  }

  Future<Charge?> getInvoiceLatestCharge(int invoiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invoices/$invoiceId/charges/latest'),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Charge.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting invoice latest charge: $e');
      }
      return null;
    }
  }

  Future<List<Charge>> listCharges({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/charges').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data is Map && data['content'] != null) {
          return (data['content'] as List).map((json) => Charge.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => Charge.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error listing charges: $e');
      }
      return [];
    }
  }

  Future<Charge?> getCharge(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/charges/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Charge.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting charge: $e');
      }
      return null;
    }
  }

  // COBRANÇAS
  Future<Charge?> createCharge(Charge charge) async {
    try {
      // Preparar body da requisição
      final requestBody = charge.toJson();
      
      if (kDebugMode) {
        debugPrint('📤 Sending charge request to: $baseUrl/charges/credit/card');
        debugPrint('📦 Request body: ${jsonEncode(requestBody)}');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/charges/credit/card'),
        headers: _headers,
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        debugPrint('📥 Create Charge Response: ${response.statusCode}');
        debugPrint('📄 Response body: ${response.body}');
        debugPrint('📋 Response Headers: ${response.headers}');
      }

      if (response.statusCode == 201) {
        final locationHeader = response.headers['location'];
        if (locationHeader != null) {
          // Extrair ID da cobrança do location header
          final chargeIdMatch = RegExp(r'/charges/(\d+)').firstMatch(locationHeader);
          if (chargeIdMatch != null) {
            final chargeId = chargeIdMatch.group(1)!;
            
            // Se tinha notificationUrl com CHARGE_ID, atualizar com ID real
            if (charge.notificationUrl != null && charge.notificationUrl!.contains('CHARGE_ID')) {
              final updatedUrl = charge.notificationUrl!.replaceAll('CHARGE_ID', chargeId);
              
              if (kDebugMode) {
                debugPrint('🔔 Atualizando notificationUrl: $updatedUrl');
              }
              
              // Atualizar cobrança com URL correta
              try {
                await http.put(
                  Uri.parse('$baseUrl/charges/$chargeId'),
                  headers: _headers,
                  body: jsonEncode({'notificationUrl': updatedUrl}),
                );
                
                if (kDebugMode) {
                  debugPrint('✅ NotificationUrl atualizada com sucesso');
                }
              } catch (updateError) {
                if (kDebugMode) {
                  debugPrint('⚠️ Erro ao atualizar notificationUrl: $updateError');
                }
              }
            }
          }
          
          return await getChargeFromLocation(locationHeader);
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating charge: $e');
      }
      rethrow;
    }
  }

  Future<Charge?> getChargeFromLocation(String location) async {
    try {
      final response = await http.get(
        Uri.parse(location),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Charge.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting charge from location: $e');
      }
      return null;
    }
  }

  Future<bool> captureCharge(int chargeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/charges/$chargeId/credit-card/capture'),
        headers: _headers,
      );

      if (kDebugMode) {
        debugPrint('Capture Charge Response: ${response.statusCode}');
      }

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error capturing charge: $e');
      }
      return false;
    }
  }

  Future<bool> refundCharge(int chargeId, {required String reason, int? amount}) async {
    try {
      final body = {
        'reason': reason,
        if (amount != null) 'amount': amount,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/charges/$chargeId/credit-card/refund'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        debugPrint('Refund Charge Response: ${response.statusCode}');
      }

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error refunding charge: $e');
      }
      return false;
    }
  }

  Future<bool> cancelBoleto(int chargeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/charges/$chargeId/boleto/cancel'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error canceling boleto: $e');
      }
      return false;
    }
  }

  Future<bool> cancelPix(int chargeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/charges/$chargeId/pix/cancel'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error canceling PIX: $e');
      }
      return false;
    }
  }

  // ASSINATURAS (SUBSCRIPTIONS)
  Future<List<Subscription>> listSubscriptions({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/subscriptions').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data is Map && data['content'] != null) {
          return (data['content'] as List).map((json) => Subscription.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => Subscription.fromJson(json)).toList();
        }
      } else if (response.statusCode == 401) {
        // Token não tem permissão para subscriptions - usar dados derivados de charges
        if (kDebugMode) {
          debugPrint('⚠️ Subscriptions endpoint unauthorized (401) - usando dados de cobranças recorrentes');
        }
        return _extractSubscriptionsFromCharges();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error listing subscriptions: $e');
      }
      // Em caso de erro, tentar extrair de charges
      try {
        return _extractSubscriptionsFromCharges();
      } catch (e2) {
        return [];
      }
    }
  }

  /// Extrai subscriptions dos dados de charges recorrentes
  Future<List<Subscription>> _extractSubscriptionsFromCharges() async {
    try {
      final chargesResponse = await http.get(
        Uri.parse('$baseUrl/charges?page=0&size=100'),
        headers: _headers,
      );

      if (chargesResponse.statusCode == 200 && chargesResponse.body.isNotEmpty) {
        final chargesData = jsonDecode(chargesResponse.body);
        List<dynamic> charges = [];
        
        if (chargesData is List) {
          charges = chargesData;
        } else if (chargesData is Map && chargesData['content'] != null) {
          charges = chargesData['content'];
        }

        // Agrupar charges por order (pedido recorrente = subscription)
        final Map<int, List<dynamic>> chargesByOrder = {};
        for (var charge in charges) {
          if (charge['order'] != null && charge['order']['orderType'] == 'RECURRENT') {
            final orderId = charge['order']['id'];
            if (!chargesByOrder.containsKey(orderId)) {
              chargesByOrder[orderId] = [];
            }
            chargesByOrder[orderId]!.add(charge);
          }
        }

        // Criar subscriptions baseadas nos pedidos recorrentes
        final List<Subscription> subscriptions = [];
        chargesByOrder.forEach((orderId, orderCharges) {
          if (orderCharges.isNotEmpty) {
            final firstCharge = orderCharges.first;
            final customer = firstCharge['customer'];
            
            // Determinar status baseado nas cobranças
            String status = 'ACTIVE';
            if (orderCharges.every((c) => c['status'] == 'FAIL')) {
              status = 'CANCELED';
            } else if (orderCharges.any((c) => c['status'] == 'SCHEDULE')) {
              status = 'ACTIVE';
            }

            subscriptions.add(Subscription(
              id: orderId,
              customerId: customer?['id']?.toString(),
              customerName: customer?['name'],
              customerDocument: customer?['document'],
              productId: '1', // Produto assistencias (único produto encontrado)
              productName: 'assistencias',
              status: status,
              billingType: 'AUTOMATIC',
              cycle: 'MONTHLY',
              valueInCents: firstCharge['value'] ?? 0,
            ));
          }
        });

        if (kDebugMode) {
          debugPrint('✅ Extraídas ${subscriptions.length} subscriptions de charges recorrentes');
        }

        return subscriptions;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error extracting subscriptions from charges: $e');
      }
      return [];
    }
  }

  Future<Subscription?> getSubscription(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Subscription.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting subscription: $e');
      }
      return null;
    }
  }

  Future<bool> cancelSubscription(int subscriptionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/$subscriptionId/cancel'),
        headers: _headers,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error canceling subscription: $e');
      }
      return false;
    }
  }

  // DASHBOARD STATS
  Future<DashboardStats> getDashboardStats() async {
    try {
      // Buscar dados de múltiplos endpoints para montar o dashboard
      final invoicesResponse = await http.get(
        Uri.parse('$baseUrl/invoices?page=0&size=100'),
        headers: _headers,
      );

      final chargesResponse = await http.get(
        Uri.parse('$baseUrl/charges?page=0&size=100'),
        headers: _headers,
      );

      final subscriptionsResponse = await http.get(
        Uri.parse('$baseUrl/subscriptions?page=0&size=100'),
        headers: _headers,
      );

      int totalInvoices = 0;
      int totalCharges = 0;
      int totalSubscriptions = 0;
      double todayChargesValue = 0;
      int todayChargesCount = 0;
      double monthChargesValue = 0;
      int monthChargesCount = 0;
      Map<String, double> tpvByDate = {};
      Map<String, int> cardBrands = {};
      Map<String, int> paymentMethods = {};
      
      // IMPORTANTE: Considerar apenas cobranças bem-sucedidas (PAY) para métricas financeiras
      final successStatuses = ['PAY', 'AUTHORIZED'];

      // Processar faturas
      if (invoicesResponse.statusCode == 200 && invoicesResponse.body.isNotEmpty) {
        final invoicesData = jsonDecode(invoicesResponse.body);
        if (invoicesData is Map && invoicesData['content'] != null) {
          totalInvoices = (invoicesData['content'] as List).length;
        } else if (invoicesData is List) {
          totalInvoices = invoicesData.length;
        }
      }

      // Processar cobranças
      if (chargesResponse.statusCode == 200 && chargesResponse.body.isNotEmpty) {
        final chargesData = jsonDecode(chargesResponse.body);
        List chargesList = [];
        
        if (chargesData is Map && chargesData['content'] != null) {
          chargesList = chargesData['content'];
        } else if (chargesData is List) {
          chargesList = chargesData;
        }

        totalCharges = chargesList.length;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final monthStart = DateTime(now.year, now.month, 1);

        for (var charge in chargesList) {
          final chargeStatus = charge['status'] ?? '';
          
          // API BemPaggo: campo é 'value' (em centavos)
          final amount = ((charge['value'] ?? 0) as num).toDouble() / 100.0;
          
          // Usar transactions para pegar data e método de pagamento
          final transactions = charge['transactions'] as List?;
          if (transactions != null && transactions.isNotEmpty) {
            final transaction = transactions[0];
            final transactionDate = transaction['transactionDate'];
            final transactionStatus = transaction['status'] ?? '';
            final paymentMethod = transaction['paymentMethod'] ?? 'UNKNOWN';
            
            if (transactionDate != null) {
              final chargeDate = DateTime.fromMillisecondsSinceEpoch(transactionDate);
              final dateKey = '${chargeDate.day.toString().padLeft(2, '0')}/${chargeDate.month.toString().padLeft(2, '0')}';
              
              // Adicionar ao TPV por data (TODAS as transações para visibilidade)
              tpvByDate[dateKey] = (tpvByDate[dateKey] ?? 0) + amount;

              // Comparar apenas a data (sem hora)
              final chargeDateOnly = DateTime(chargeDate.year, chargeDate.month, chargeDate.day);
              
              // CORRIGIDO: Considerar últimas 24 horas ao invés de "hoje" apenas
              final last24Hours = now.subtract(const Duration(hours: 24));
              if (chargeDate.isAfter(last24Hours)) {
                // Incluir TODAS as cobranças das últimas 24h (independente do status para visibilidade)
                todayChargesValue += amount;
                todayChargesCount++;
              }

              // Para métricas do mês, considerar apenas cobranças bem-sucedidas
              if (chargeDateOnly.isAfter(monthStart.subtract(const Duration(days: 1)))) {
                if (successStatuses.contains(chargeStatus) || successStatuses.contains(transactionStatus)) {
                  monthChargesValue += amount;
                  monthChargesCount++;
                }
              }
            }

            // Processar métodos de pagamento
            paymentMethods[paymentMethod] = (paymentMethods[paymentMethod] ?? 0) + 1;

            // Processar bandeiras de cartão (se disponível)
            if (paymentMethod == 'CREDIT_CARD' || paymentMethod == 'DEBIT_CARD') {
              final brand = charge['cardBrand'] ?? 'Other';
              cardBrands[brand] = (cardBrands[brand] ?? 0) + 1;
            }
          }
        }
      }

      // Processar assinaturas
      if (subscriptionsResponse.statusCode == 200 && subscriptionsResponse.body.isNotEmpty) {
        final subscriptionsData = jsonDecode(subscriptionsResponse.body);
        if (subscriptionsData is Map && subscriptionsData['content'] != null) {
          totalSubscriptions = (subscriptionsData['content'] as List).length;
        } else if (subscriptionsData is List) {
          totalSubscriptions = subscriptionsData.length;
        }
      }

      final averageTicket = monthChargesCount > 0 ? (monthChargesValue / monthChargesCount).toDouble() : 0.0;

      return DashboardStats(
        totalInvoices: totalInvoices,
        totalCharges: totalCharges,
        totalSubscriptions: totalSubscriptions,
        todayChargesValue: todayChargesValue,
        todayChargesCount: todayChargesCount,
        monthChargesValue: monthChargesValue,
        monthChargesCount: monthChargesCount,
        averageTicket: averageTicket,
        tpvByDate: tpvByDate,
        cardBrands: cardBrands,
        paymentMethods: paymentMethods,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting dashboard stats: $e');
      }
      return DashboardStats();
    }
  }

  // WEBHOOKS
  Future<WebhookConfiguration?> createWebhook(WebhookConfiguration webhook) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/webhook-configurations'),
        headers: _headers,
        body: jsonEncode(webhook.toJson()),
      );

      if (kDebugMode) {
        debugPrint('Create Webhook Response: ${response.statusCode}');
        debugPrint('Response Headers: ${response.headers}');
      }

      if (response.statusCode == 201) {
        // API retorna 201 com Location header
        final locationHeader = response.headers['location'];
        if (kDebugMode) {
          debugPrint('Location: $locationHeader');
        }
        
        // Criar objeto com os dados enviados + ID extraído da location
        if (locationHeader != null) {
          final idMatch = RegExp(r'/webhooks/(\d+)').firstMatch(locationHeader);
          if (idMatch != null) {
            final id = int.parse(idMatch.group(1)!);
            return WebhookConfiguration(
              id: id,
              event: webhook.event,
              notificationUrl: webhook.notificationUrl,
              authType: webhook.authType,
              authorizationHeader: webhook.authorizationHeader,
              apiKey: webhook.apiKey,
              username: webhook.username,
              password: webhook.password,
              customHeaders: webhook.customHeaders,
              timeoutSeconds: webhook.timeoutSeconds,
              retryCount: webhook.retryCount,
              active: true,
            );
          }
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating webhook: $e');
      }
      rethrow;
    }
  }

  Future<WebhookConfiguration?> getWebhook(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/webhooks/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return WebhookConfiguration.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting webhook: $e');
      }
      return null;
    }
  }

  Future<bool> deleteWebhook(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/webhook-configurations/$id'),
        headers: _headers,
      );

      if (kDebugMode) {
        debugPrint('Delete Webhook Response: ${response.statusCode}');
      }

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting webhook: $e');
      }
      return false;
    }
  }

  Future<bool> updateWebhook(int id, WebhookConfiguration webhook) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/webhook-configurations/$id'),
        headers: _headers,
        body: jsonEncode(webhook.toJson()),
      );

      if (kDebugMode) {
        debugPrint('Update Webhook Response: ${response.statusCode}');
      }

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating webhook: $e');
      }
      return false;
    }
  }
}
