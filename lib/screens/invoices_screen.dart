import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/deltapag_api.dart';
import '../models/invoice.dart';
import 'invoice_detail_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final DeltaPagAPI _api = DeltaPagAPI();
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final invoices = await _api.listInvoices();
      
      // Filtrar por status se necessário
      List<Invoice> filtered = invoices;
      if (_filterStatus != null) {
        filtered = invoices.where((inv) => inv.status == _filterStatus).toList();
      }
      
      setState(() {
        _invoices = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar faturas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faturas'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value == 'ALL' ? null : value;
              });
              _loadInvoices();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ALL', child: Text('Todas')),
              const PopupMenuItem(value: 'OPEN', child: Text('Abertas')),
              const PopupMenuItem(value: 'CLOSED', child: Text('Fechadas')),
              const PopupMenuItem(value: 'PAID', child: Text('Pagas')),
              const PopupMenuItem(value: 'CANCELED', child: Text('Canceladas')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        _filterStatus != null 
                            ? 'Nenhuma fatura ${_getStatusText(_filterStatus!)}'
                            : 'Nenhuma fatura encontrada',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInvoices,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = _invoices[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _navigateToDetail(invoice),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: _getStatusColor(invoice.status),
                                      child: const Icon(Icons.receipt, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Fatura #${invoice.id}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            invoice.customer?.name ?? 'Cliente ID ${invoice.customerId ?? "?"}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusChip(invoice.status),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Valor',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          invoice.formattedTotal,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Vencimento',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          invoice.formattedDueDate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (invoice.paymentUrl != null) ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: () => _copyPaymentLink(invoice.paymentUrl!),
                                    icon: const Icon(Icons.link, size: 16),
                                    label: const Text('Copiar Link de Pagamento'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 36),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'OPEN': return 'aberta';
      case 'CLOSED': return 'fechada';
      case 'PAID': return 'paga';
      case 'CANCELED': return 'cancelada';
      default: return '';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'OPEN':
        return Colors.blue;
      case 'CLOSED':
        return Colors.orange;
      case 'CANCELED':
        return Colors.red;
      case 'OVERDUE':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        Invoice(status: status).statusDisplay,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  void _copyPaymentLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copiado para área de transferência!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDetail(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailScreen(invoice: invoice),
      ),
    ).then((_) => _loadInvoices());
  }
}
