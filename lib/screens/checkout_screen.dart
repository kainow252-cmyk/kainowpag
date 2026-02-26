import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/customer.dart' as cust_model;
import '../models/charge.dart' as charge_model;
import '../services/api_provider.dart';
import 'home_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String productId;
  final bool showAdminTools; // Se true, mostra link e API

  const CheckoutScreen({
    super.key,
    required this.productId,
    this.showAdminTools = false, // Por padrão, não mostra (modo cliente)
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Dados do produto
  Product? _product;
  bool _isLoading = true;
  
  // Método de pagamento selecionado
  String _paymentMethod = 'CREDIT_CARD';
  
  // Dados do cliente
  final _nameController = TextEditingController();
  final _documentController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Dados do cartão
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expirationController = TextEditingController();
  final _cvvController = TextEditingController();
  int _installments = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      debugPrint('🔍 Loading product with ID: ${widget.productId}');
      
      final apiProvider = Provider.of<APIProvider>(context, listen: false);
      final product = await apiProvider.getProduct(int.parse(widget.productId));
      
      if (product != null) {
        debugPrint('✅ Product loaded: ${product.name}');
        
        setState(() {
          _product = product;
          _isLoading = false;
        });
      } else {
        debugPrint('⚠️ Product is null');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading product: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar produto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _getCheckoutUrl() {
    // Pega a URL base do navegador
    const baseUrl = 'https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai';
    return '$baseUrl/checkout/${widget.productId}';
  }

  String _getAPIUrl() {
    const baseUrl = 'https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai';
    return '$baseUrl/api/generate-checkout-link/${widget.productId}';
  }

  Future<void> _copyCheckoutLink() async {
    final checkoutUrl = _getCheckoutUrl();
    
    await Clipboard.setData(ClipboardData(text: checkoutUrl));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Link copiado!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      checkoutUrl,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _copyAPILink() async {
    final apiUrl = _getAPIUrl();
    
    await Clipboard.setData(ClipboardData(text: apiUrl));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Link da API copiado!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      apiUrl,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto não encontrado')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiProvider = Provider.of<APIProvider>(context, listen: false);

      // 1. Criar/verificar cliente
      cust_model.Customer? customer;
      
      // Tentar buscar cliente existente
      customer = await apiProvider.getCustomerByDocument(_documentController.text);
      
      // Se cliente não existe, criar novo
      if (customer == null) {
        if (kDebugMode) {
          debugPrint('🆕 Cliente não encontrado, criando novo: ${_documentController.text}');
        }
        
        customer = await apiProvider.createCustomer(cust_model.Customer(
          name: _nameController.text,
          document: _documentController.text,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          phone: _phoneController.text.isNotEmpty && _phoneController.text.length >= 10
              ? cust_model.Phone(
                  countryCode: 55,
                  areaCode: int.parse(_phoneController.text.substring(0, 2)),
                  number: int.parse(_phoneController.text.substring(2)),
                )
              : null,
        ));
        
        if (customer == null) {
          throw Exception('Falha ao criar cliente');
        }
        
        if (kDebugMode) {
          debugPrint('✅ Cliente criado com sucesso: ${customer.name}');
        }
      } else {
        if (kDebugMode) {
          debugPrint('✅ Cliente encontrado: ${customer.name}');
        }
      }

      // 2. Criar cobrança
      charge_model.Charge? charge;
      
      if (_paymentMethod == 'CREDIT_CARD') {
        // Preparar dados do cartão
        final cardNumber = _cardNumberController.text.replaceAll(' ', '');
        final expirationParts = _expirationController.text.split('/');
        final month = expirationParts[0].trim();
        String year = expirationParts[1].trim();
        
        // Converter ano de 2 dígitos para 4 dígitos (ex: 25 -> 2025)
        if (year.length == 2) {
          final currentYear = DateTime.now().year;
          final currentCentury = (currentYear ~/ 100) * 100; // 2000
          final twoDigitYear = int.parse(year);
          year = (currentCentury + twoDigitYear).toString();
        }
        
        charge = await apiProvider.createCharge(charge_model.Charge(
          customer: charge_model.Customer(
            document: customer.document,
            // IMPORTANTE: Usar o nome do formulário, não o nome do cliente cadastrado
            name: _nameController.text,
          ),
          value: _product!.value,
          installments: _installments,
          // Vincular ao checkout do produto para criar como recorrente
          checkoutId: _product!.checkoutId,
          // URL de notificação do webhook (DeltaPag enviará "Bempaggo" quando houver mudanças)
          // IMPORTANTE: Usar domínio de produção após propagação DNS
          notificationUrl: 'https://kainowpag.com/api/webhooks/deltapag/charge/CHARGE_ID',
          card: charge_model.CreditCard(
            cardNumber: cardNumber,
            cvv: _cvvController.text,
            holder: charge_model.CardHolder(
              name: _cardHolderController.text,
              document: customer.document,
            ),
            expiration: charge_model.CardExpiration(
              month: month,
              year: year,
            ),
            brand: _detectCardBrand(cardNumber),
          ),
        ));
      } else {
        // Boleto ou PIX - precisa implementar no futuro
        throw UnimplementedError('$_paymentMethod ainda não implementado');
      }

      setState(() {
        _isLoading = false;
      });

      // 3. Mostrar mensagem de sucesso
      if (mounted && charge != null) {
        _showSuccessDialog(charge);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar pagamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _detectCardBrand(String cardNumber) {
    // Detectar bandeira do cartão baseado nos primeiros dígitos
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('6')) return 'Discover';
    if (cardNumber.startsWith('3')) return 'Amex';
    return 'Unknown';
  }

  void _showSuccessDialog(charge_model.Charge charge) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pagamento Finalizado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seu pagamento foi processado com sucesso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Produto:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        _product!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Valor:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        _formatCurrency(_product!.value),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (charge.status != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: charge.status == 'PAY'
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            charge.statusName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: charge.status == 'PAY'
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Obrigado pela sua compra!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
                Navigator.of(context).pop(); // Volta para a tela anterior
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Concluir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
        ),
        body: const Center(
          child: Text('Produto não encontrado'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: widget.showAdminTools
            ? [
                IconButton(
                  icon: const Icon(Icons.link),
                  tooltip: 'Copiar link do checkout',
                  onPressed: _copyCheckoutLink,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumo do produto
              _buildProductSummary(),
              
              // Card com link do checkout (só mostra para admin)
              if (widget.showAdminTools) _buildCheckoutLinkCard(),
              
              const Divider(height: 32),
              
              // Dados do cliente
              _buildCustomerForm(),
              
              const Divider(height: 32),
              
              // Método de pagamento
              _buildPaymentMethodSelector(),
              
              const Divider(height: 32),
              
              // Dados de pagamento
              if (_paymentMethod == 'CREDIT_CARD')
                _buildCreditCardForm(),
              
              const SizedBox(height: 32),
              
              // Botão de pagamento
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Finalizar Pagamento - ${_formatCurrency(_product!.value)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _product!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_product!.description != null)
            Text(
              _product!.description!,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _product!.productType == 'RECURRING'
                    ? 'Valor Mensal:'
                    : 'Valor:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatCurrency(_product!.value),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutLinkCard() {
    final checkoutUrl = _getCheckoutUrl();
    final apiUrl = _getAPIUrl();
    
    return Column(
      children: [
        // Card 1: Link do Checkout
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.link, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Link do Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          checkoutUrl,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        color: Colors.blue.shade700,
                        onPressed: _copyCheckoutLink,
                        tooltip: 'Copiar link',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compartilhe este link para que seus clientes possam fazer o pagamento diretamente.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Card 2: Link da API
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.api, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'API de Geração de Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          apiUrl,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        color: Colors.green.shade700,
                        onPressed: _copyAPILink,
                        tooltip: 'Copiar link da API',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use esta URL para gerar links de checkout automaticamente via API.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _testCheckoutAPI() async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Chamar API
      final apiUrl = 'https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai/api/generate-checkout-link/${widget.productId}';
      
      final response = await http.get(Uri.parse(apiUrl));
      
      // Fechar loading
      if (mounted) Navigator.pop(context);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Mostrar resultado da API
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  const Text('API Funcionando!'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Resposta da API:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildAPIField('Status', data['status']),
                    _buildAPIField('Produto', data['product_name']),
                    _buildAPIField('Valor', 'R\$ ${(data['product_value'] / 100).toFixed(2)}'),
                    _buildAPIField('Link Gerado', data['checkout_url']),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'JSON Completo:\n${jsonEncode(data)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data['checkout_url']));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copiado!')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copiar Link'),
                ),
              ],
            ),
          );
        }
      } else {
        // Erro na API
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro na API: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao testar API: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAPIField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dados do Cliente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome Completo *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nome é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _documentController,
            decoration: const InputDecoration(
              labelText: 'CPF/CNPJ *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'CPF/CNPJ é obrigatório';
              }
              if (value.length != 11 && value.length != 14) {
                return 'CPF/CNPJ inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
              hintText: '11999999999',
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Método de Pagamento',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'CREDIT_CARD',
                label: Text('Cartão'),
                icon: Icon(Icons.credit_card),
              ),
              ButtonSegment(
                value: 'BOLETO',
                label: Text('Boleto'),
                icon: Icon(Icons.receipt),
                enabled: false,
              ),
              ButtonSegment(
                value: 'PIX',
                label: Text('PIX'),
                icon: Icon(Icons.pix),
                enabled: false,
              ),
            ],
            selected: {_paymentMethod},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _paymentMethod = newSelection.first;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dados do Cartão',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Número do Cartão *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
              hintText: '1234 5678 9012 3456',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Número do cartão é obrigatório';
              }
              if (value.length < 13) {
                return 'Número do cartão inválido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardHolderController,
            decoration: const InputDecoration(
              labelText: 'Nome no Cartão *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nome no cartão é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expirationController,
                  decoration: const InputDecoration(
                    labelText: 'Validade *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: 'MM/AA',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpirationDateFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Validade é obrigatória';
                    }
                    if (value.length != 5) {
                      return 'Validade inválida';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CVV é obrigatório';
                    }
                    if (value.length < 3) {
                      return 'CVV inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _installments,
            decoration: const InputDecoration(
              labelText: 'Parcelas',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.payment),
            ),
            items: List.generate(
              _product!.maxInstallments,
              (index) {
                final installment = index + 1;
                final value = _product!.value / installment;
                return DropdownMenuItem(
                  value: installment,
                  child: Text('${installment}x de ${_formatCurrency(value.round())}'),
                );
              },
            ),
            onChanged: (value) {
              setState(() {
                _installments = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int valueInCents) {
    final value = valueInCents / 100;
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expirationController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}

// Formatador customizado para data de expiração
class _ExpirationDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length > 2 && !text.contains('/')) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    
    return newValue;
  }
}

// Tela de sucesso
class CheckoutSuccessScreen extends StatelessWidget {
  final charge_model.Charge charge;
  final Product product;

  const CheckoutSuccessScreen({
    super.key,
    required this.charge,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                'Pagamento Realizado!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Seu pagamento de ${_formatCurrency(charge.value)} foi processado com sucesso.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalhes da Compra',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildDetailRow('Produto:', product.name),
                      _buildDetailRow('Método:', 'Cartão de Crédito'),
                      _buildDetailRow('Status:', charge.statusName),
                      if (charge.id != null)
                        _buildDetailRow('ID da Cobrança:', '#${charge.id}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Voltar ao Início'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatCurrency(int valueInCents) {
    final value = valueInCents / 100;
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
