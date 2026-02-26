import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_provider.dart';
import '../models/subscription.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<Subscription> _subscriptions = [];
  List<Subscription> _filteredSubscriptions = [];
  bool _isLoading = true;
  String? _selectedFilter;
  
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() => _isLoading = true);
    
    final api = context.read<APIProvider>();
    final subscriptions = await api.listSubscriptions();
    
    setState(() {
      _subscriptions = subscriptions;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    if (_selectedFilter == null || _selectedFilter == 'Todas') {
      _filteredSubscriptions = List.from(_subscriptions);
    } else {
      _filteredSubscriptions = _subscriptions.where((sub) {
        switch (_selectedFilter) {
          case 'Ativas':
            return sub.status == 'ACTIVE';
          case 'Inadimplentes':
            return sub.status == 'OVERDUE';
          case 'Pendentes':
            return sub.status == 'PENDING';
          case 'Canceladas':
            return sub.status == 'CANCELED';
          default:
            return true;
        }
      }).toList();
    }
  }

  Future<void> _cancelSubscription(Subscription subscription) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: Text('Deseja realmente cancelar a assinatura de ${subscription.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );

    if (confirm == true && subscription.id != null) {
      final api = context.read<APIProvider>();
      final success = await api.cancelSubscription(subscription.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Assinatura cancelada com sucesso!'
                : 'Erro ao cancelar assinatura'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success) {
          _loadSubscriptions();
        }
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Assinaturas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('Todas'),
            _buildFilterOption('Ativas'),
            _buildFilterOption('Pendentes'),
            _buildFilterOption('Inadimplentes'),
            _buildFilterOption('Canceladas'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String filter) {
    final isSelected = (_selectedFilter ?? 'Todas') == filter;
    return ListTile(
      title: Text(filter),
      leading: Radio<String>(
        value: filter,
        groupValue: _selectedFilter ?? 'Todas',
        onChanged: (value) {
          setState(() {
            _selectedFilter = value;
            _applyFilter();
          });
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          _selectedFilter = filter;
          _applyFilter();
        });
        Navigator.pop(context);
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = null;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinaturas'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_selectedFilter != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar',
          ),
          if (_selectedFilter != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Limpar filtros',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubscriptions,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredSubscriptions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma assinatura encontrada',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      if (_selectedFilter != null) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Limpar filtros'),
                        ),
                      ],
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSubscriptions,
                  child: Column(
                    children: [
                      // Filter Chips
                      if (_selectedFilter != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.blue.withOpacity(0.1),
                          child: Row(
                            children: [
                              const Icon(Icons.filter_alt, size: 20, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Filtro: $_selectedFilter',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '${_filteredSubscriptions.length} resultado(s)',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      
                      // Tabs
                      Container(
                        color: Theme.of(context).cardColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTabButton('Todas', null),
                            _buildTabButton('Ativas', 'Ativas'),
                            _buildTabButton('Inadimplentes', 'Inadimplentes'),
                            _buildTabButton('Pendentes', 'Pendentes'),
                            _buildTabButton('Canceladas', 'Canceladas'),
                          ],
                        ),
                      ),
                      
                      // List
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredSubscriptions.length,
                          itemBuilder: (context, index) {
                            final subscription = _filteredSubscriptions[index];
                            return _buildSubscriptionCard(subscription);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Função de criar assinatura em desenvolvimento'),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Nova Assinatura',
      ),
    );
  }

  Widget _buildTabButton(String label, String? filter) {
    final isSelected = _selectedFilter == filter || 
                      (_selectedFilter == null && filter == null);
    
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
          _applyFilter();
        });
      },
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.blue : Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(Subscription subscription) {
    final statusColor = _getStatusColor(subscription.status);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(
            _getStatusIcon(subscription.status),
            color: statusColor,
          ),
        ),
        title: Text(
          subscription.customerName ?? 'Cliente não informado',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subscription.customerEmail ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subscription.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(subscription.valueInCents / 100),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              subscription.cycleText,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Criada em:', subscription.createdAt != null
                    ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(subscription.createdAt!))
                    : 'N/A'),
                _buildDetailRow('Produto:', subscription.productName ?? 'N/A'),
                _buildDetailRow('CPF/CNPJ:', subscription.customerDocument ?? 'N/A'),
                _buildDetailRow('Tipo de cobrança:', subscription.billingTypeText),
                _buildDetailRow('Frequência:', subscription.cycleText),
                if (subscription.nextChargeDate != null)
                  _buildDetailRow(
                    'Próxima cobrança:',
                    dateFormat.format(DateTime.fromMillisecondsSinceEpoch(subscription.nextChargeDate!)),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (subscription.status == 'ACTIVE' || subscription.status == 'PENDING')
                      ElevatedButton.icon(
                        onPressed: () => _cancelSubscription(subscription),
                        label: const Text('Cancelar'),
                        icon: const Icon(Icons.cancel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'OVERDUE':
        return Colors.red;
      case 'CANCELED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ACTIVE':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'OVERDUE':
        return Icons.warning;
      case 'CANCELED':
        return Icons.cancel;
      default:
        return Icons.subscriptions;
    }
  }
}
