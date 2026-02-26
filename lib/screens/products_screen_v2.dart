import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/api_provider.dart';
import 'create_product_screen.dart';
import 'checkout_screen.dart';

class ProductsScreenV2 extends StatefulWidget {
  const ProductsScreenV2({super.key});

  @override
  State<ProductsScreenV2> createState() => _ProductsScreenV2State();
}

class _ProductsScreenV2State extends State<ProductsScreenV2> {
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final apiProvider = Provider.of<APIProvider>(context, listen: false);
      final products = await apiProvider.listProducts();
      
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar produtos: $e')),
        );
      }
    }
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final nameLower = product.name.toLowerCase();
          final queryLower = query.toLowerCase();
          
          return nameLower.contains(queryLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar produto',
                hintText: 'Digite o nome do produto',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterProducts,
            ),
          ),
          
          // Lista de produtos ou estado vazio
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProductScreen(),
            ),
          );
          
          if (result == true) {
            // Recarregar lista após criar novo produto
            _loadProducts();
          }
        },
        label: const Text('Novo Produto'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Nenhum produto cadastrado'
                : 'Nenhum produto encontrado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Adicione produtos para começar'
                : 'Tente buscar por outro termo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        itemCount: _filteredProducts.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final priceInReais = product.value / 100;
    final isRecurring = product.productType == 'RECURRING';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com nome e badges
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Badge de status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.active 
                          ? Colors.green.shade100 
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.active ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: product.active 
                              ? Colors.green.shade700 
                              : Colors.red.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.active ? 'Ativo' : 'Inativo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: product.active 
                                ? Colors.green.shade700 
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Badge de tipo de produto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isRecurring 
                      ? Colors.purple.shade50 
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isRecurring 
                        ? Colors.purple.shade200 
                        : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRecurring ? Icons.loop : Icons.shopping_cart,
                      size: 14,
                      color: isRecurring 
                          ? Colors.purple.shade700 
                          : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isRecurring ? 'Recorrente Mensal' : 'Pagamento Único',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isRecurring 
                            ? Colors.purple.shade700 
                            : Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Preço
              Row(
                children: [
                  Text(
                    _currencyFormat.format(priceInReais),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isRecurring) ...[
                    Text(
                      '/mês',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Descrição
              if (product.description != null && product.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  product.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Informações adicionais
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.maxInstallments}x sem juros',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(Product product) {
    final priceInReais = product.value / 100;
    final isRecurring = product.productType == 'RECURRING';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Título e badges
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: product.active 
                            ? Colors.green.shade100 
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        product.active ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: product.active 
                              ? Colors.green.shade700 
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Badge de tipo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isRecurring 
                        ? Colors.purple.shade50 
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRecurring 
                          ? Colors.purple.shade200 
                          : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRecurring ? Icons.loop : Icons.shopping_cart,
                        size: 16,
                        color: isRecurring 
                            ? Colors.purple.shade700 
                            : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRecurring ? 'Recorrente Mensal' : 'Pagamento Único',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isRecurring 
                              ? Colors.purple.shade700 
                              : Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // ═══════════════════════════════════
                // SEÇÃO: GERAL
                // ═══════════════════════════════════
                _buildSectionTitle('Geral'),
                _buildDetailRow('ID', '#${product.id}', Icons.tag),
                _buildDetailRow(
                  'Nome',
                  product.name,
                  Icons.label,
                ),
                if (product.description != null && product.description!.isNotEmpty)
                  _buildDetailRow('Descrição', product.description!, Icons.description),
                
                // ═══════════════════════════════════
                // SEÇÃO: PAGAMENTO
                // ═══════════════════════════════════
                const SizedBox(height: 8),
                _buildSectionTitle('Pagamento'),
                _buildDetailRow(
                  'Tipo de Pagamento',
                  isRecurring ? 'Recorrente Mensal' : 'Pagamento Único',
                  Icons.loop,
                ),
                _buildDetailRow(
                  'Valor',
                  '${_currencyFormat.format(priceInReais)}${isRecurring ? '/mês' : ''}',
                  Icons.attach_money,
                ),
                _buildDetailRow(
                  'Formas de Pagamento',
                  product.methods.map((m) {
                    if (m == 'CREDIT_CARD') return 'Cartão de Crédito';
                    if (m == 'BOLETO') return 'Boleto';
                    if (m == 'PIX') return 'PIX';
                    return m;
                  }).join(', '),
                  Icons.credit_card,
                ),
                _buildDetailRow(
                  'Parcelas',
                  'Até ${product.maxInstallments}x sem juros',
                  Icons.calendar_month,
                ),
                if (product.softDescriptor != null && product.softDescriptor!.isNotEmpty)
                  _buildDetailRow(
                    'Descrição na Fatura',
                    product.softDescriptor!,
                    Icons.receipt_long,
                  ),
                _buildDetailRow(
                  'Repassar Taxa',
                  product.feePassThrough ? 'Sim' : 'Não',
                  Icons.calculate,
                ),
                
                // ═══════════════════════════════════
                // SEÇÃO: CHECKOUT
                // ═══════════════════════════════════
                const SizedBox(height: 8),
                _buildSectionTitle('Checkout'),
                _buildDetailRow(
                  'URL do Checkout',
                  'Clique para copiar',
                  Icons.link,
                  isLink: true,
                  linkValue: 'https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai/checkout/${product.id}',
                  onLinkTap: () {
                    // Copiar para área de transferência
                    final checkoutUrl = 'https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai/checkout/${product.id}';
                    Clipboard.setData(ClipboardData(text: checkoutUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Link copiado!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    checkoutUrl,
                                    style: const TextStyle(fontSize: 11),
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
                  },
                ),
                _buildDetailRow(
                  'Tema',
                  'DEFAULT (#${product.themeId})',
                  Icons.palette,
                ),
                
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Abrir página de checkout com ferramentas de admin
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                productId: product.id.toString(),
                                showAdminTools: true, // Mostra link e API
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Acessar Checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Fechar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {bool isLink = false, String? linkValue, VoidCallback? onLinkTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 4),
                isLink
                    ? GestureDetector(
                        onTap: onLinkTap ?? () {
                          final urlToCopy = linkValue ?? value;
                          // Copiar para clipboard e mostrar mensagem
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('URL copiada: $urlToCopy'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            if (linkValue != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                linkValue,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
