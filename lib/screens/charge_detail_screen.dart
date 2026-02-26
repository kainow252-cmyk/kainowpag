import 'package:flutter/material.dart';
import '../services/deltapag_api.dart';
import '../models/charge.dart';

class ChargeDetailScreen extends StatefulWidget {
  final Charge charge;

  const ChargeDetailScreen({super.key, required this.charge});

  @override
  State<ChargeDetailScreen> createState() => _ChargeDetailScreenState();
}

class _ChargeDetailScreenState extends State<ChargeDetailScreen> {
  final DeltaPagAPI _api = DeltaPagAPI();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cobrança #${widget.charge.id}'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          if (widget.charge.status == 'AUTHORIZED')
            PopupMenuButton<String>(
              onSelected: _handleAction,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'capture',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Capturar Pagamento'),
                    ],
                  ),
                ),
              ],
            ),
          if (widget.charge.status == 'PAY')
            PopupMenuButton<String>(
              onSelected: _handleAction,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'refund',
                  child: Row(
                    children: [
                      Icon(Icons.replay, size: 20, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Estornar'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildCustomerCard(),
                  const SizedBox(height: 16),
                  if (widget.charge.card != null) _buildCardInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Valor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.charge.formattedValue,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Parcelas', '${widget.charge.installments}x'),
                _buildInfoColumn('ID', '#${widget.charge.id ?? "?"}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Cliente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Nome', widget.charge.customer.name),
            _buildDetailRow('Documento', widget.charge.customer.document),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo() {
    final card = widget.charge.card!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Cartão de Crédito',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Número', card.maskedNumber),
            _buildDetailRow('Bandeira', card.brand),
            _buildDetailRow('Validade', card.expiration.formatted),
            _buildDetailRow('Titular', card.holder.name),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor().withAlpha(50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(), width: 2),
      ),
      child: Text(
        widget.charge.statusName,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.charge.status) {
      case 'PAY':
        return Colors.green;
      case 'AUTHORIZED':
        return Colors.blue;
      case 'PENDING':
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'SCHEDULE':
        return Colors.purple;
      case 'FAIL':
        return Colors.red;
      case 'REFUND':
        return Colors.brown;
      case 'CANCELED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleAction(String action) async {
    if (widget.charge.id == null) return;

    switch (action) {
      case 'capture':
        await _captureCharge();
        break;
      case 'refund':
        await _refundCharge();
        break;
    }
  }

  Future<void> _captureCharge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Capturar Pagamento'),
        content: const Text('Deseja capturar este pagamento? Esta ação não pode ser desfeita.'),
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

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final success = await _api.captureCharge(widget.charge.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Pagamento capturado com sucesso!' : 'Erro ao capturar pagamento'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          Navigator.pop(context); // Voltar para a lista
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refundCharge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estornar Pagamento'),
        content: const Text('Deseja estornar este pagamento? O valor será devolvido ao cliente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Estornar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final success = await _api.refundCharge(
        widget.charge.id!,
        reason: 'CUSTOMER_REQUEST',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Pagamento estornado com sucesso!' : 'Erro ao estornar pagamento'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          Navigator.pop(context); // Voltar para a lista
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
