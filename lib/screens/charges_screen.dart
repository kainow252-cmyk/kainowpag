import 'package:flutter/material.dart';
import '../services/deltapag_api.dart';
import '../models/charge.dart';
import 'create_charge_screen.dart';

class ChargesScreen extends StatefulWidget {
  const ChargesScreen({super.key});

  @override
  State<ChargesScreen> createState() => _ChargesScreenState();
}

class _ChargesScreenState extends State<ChargesScreen> {
  final DeltaPagAPI _api = DeltaPagAPI();
  List<Charge> _charges = [];
  bool _isLoading = true;
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'Todos',
    'PAY',
    'AUTHORIZED',
    'PENDING',
    'SCHEDULE',
    'IN_PROGRESS',
    'REFUND',
    'FAIL',
    'CANCELED',
  ];

  @override
  void initState() {
    super.initState();
    _loadCharges();
  }

  Future<void> _loadCharges() async {
    setState(() => _isLoading = true);
    try {
      final charges = await _api.listCharges(
        status: _selectedStatus,
        page: 0,
        size: 100,
      );
      setState(() {
        _charges = charges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar cobranças: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PAY':
        return Colors.green;
      case 'AUTHORIZED':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'SCHEDULE':
        return Colors.lightBlue;
      case 'IN_PROGRESS':
        return Colors.amber;
      case 'REFUND':
        return Colors.purple;
      case 'FAIL':
        return Colors.red;
      case 'CANCELED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'PAY':
        return Icons.check_circle;
      case 'AUTHORIZED':
        return Icons.verified;
      case 'PENDING':
        return Icons.pending;
      case 'SCHEDULE':
        return Icons.schedule;
      case 'IN_PROGRESS':
        return Icons.hourglass_empty;
      case 'REFUND':
        return Icons.undo;
      case 'FAIL':
        return Icons.error;
      case 'CANCELED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Future<void> _captureCharge(Charge charge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Capturar Cobrança'),
        content: Text(
          'Deseja capturar a cobrança de ${charge.formattedValue}?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Capturar'),
          ),
        ],
      ),
    );

    if (confirmed == true && charge.id != null) {
      final success = await _api.captureCharge(charge.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Cobrança capturada com sucesso!'
                  : 'Erro ao capturar cobrança',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) _loadCharges();
      }
    }
  }

  Future<void> _refundCharge(Charge charge) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estornar Cobrança'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Estornar ${charge.formattedValue}?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo do estorno',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Estornar'),
          ),
        ],
      ),
    );

    if (confirmed == true && charge.id != null) {
      final reason = reasonController.text.trim();
      if (reason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informe o motivo do estorno'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final success = await _api.refundCharge(charge.id!, reason: reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Cobrança estornada com sucesso!'
                  : 'Erro ao estornar cobrança',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) _loadCharges();
      }
    }
  }

  void _showChargeDetails(Charge charge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    _getStatusIcon(charge.status),
                    color: _getStatusColor(charge.status),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cobrança #${charge.id ?? "N/A"}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          charge.statusName,
                          style: TextStyle(
                            color: _getStatusColor(charge.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow(
                context,
                'Valor',
                charge.formattedValue,
                Icons.attach_money,
              ),
              _buildDetailRow(
                context,
                'Parcelas',
                '${charge.installments}x',
                Icons.credit_card,
              ),
              _buildDetailRow(
                context,
                'Cliente',
                charge.customer.name,
                Icons.person,
              ),
              _buildDetailRow(
                context,
                'Documento',
                charge.customer.document,
                Icons.badge,
              ),
              if (charge.yourReferenceId != null)
                _buildDetailRow(
                  context,
                  'Referência',
                  charge.yourReferenceId!,
                  Icons.tag,
                ),
              if (charge.card != null) ...[
                const Divider(height: 32),
                Text(
                  'Informações do Cartão',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  'Número',
                  charge.card!.maskedNumber,
                  Icons.credit_card,
                ),
                _buildDetailRow(
                  context,
                  'Bandeira',
                  charge.card!.brand,
                  Icons.payment,
                ),
                _buildDetailRow(
                  context,
                  'Titular',
                  charge.card!.holder.name,
                  Icons.person_outline,
                ),
                _buildDetailRow(
                  context,
                  'Validade',
                  charge.card!.expiration.formatted,
                  Icons.calendar_today,
                ),
              ],
              const SizedBox(height: 24),
              // Ações disponíveis
              if (charge.status == 'AUTHORIZED') ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _captureCharge(charge);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Capturar Pagamento'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (charge.status == 'PAY') ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _refundCharge(charge);
                    },
                    icon: const Icon(Icons.undo),
                    label: const Text('Estornar Pagamento'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cobranças'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
            tooltip: 'Filtrar por status',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _charges.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma cobrança encontrada',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crie sua primeira cobrança',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCharges,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _charges.length,
                    itemBuilder: (context, index) {
                      final charge = _charges[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showChargeDetails(charge),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _getStatusIcon(charge.status),
                                      color: _getStatusColor(charge.status),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            charge.customer.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Cobrança #${charge.id ?? "N/A"}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      charge.formattedValue,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(charge.statusName),
                                      backgroundColor: _getStatusColor(
                                        charge.status,
                                      ).withValues(alpha: 0.1),
                                      labelStyle: TextStyle(
                                        color: _getStatusColor(charge.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.credit_card,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${charge.installments}x',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateChargeScreen(),
            ),
          );
          if (result == true) _loadCharges();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Cobrança'),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOptions.map((status) {
            final isSelected = status == 'Todos'
                ? _selectedStatus == null
                : _selectedStatus == status;
            return RadioListTile<String?>(
              title: Text(status == 'Todos' ? status : _getStatusName(status)),
              value: status == 'Todos' ? null : status,
              groupValue: _selectedStatus,
              selected: isSelected,
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                Navigator.pop(context);
                _loadCharges();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getStatusName(String status) {
    final charge = Charge(
      customer: Customer(document: '', name: ''),
      value: 0,
      installments: 1,
      status: status,
    );
    return charge.statusName;
  }
}
