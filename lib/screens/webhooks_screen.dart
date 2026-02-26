import 'package:flutter/material.dart';
import '../services/deltapag_api.dart';
import '../models/webhook.dart';
import 'create_webhook_screen.dart';

class WebhooksScreen extends StatefulWidget {
  const WebhooksScreen({super.key});

  @override
  State<WebhooksScreen> createState() => _WebhooksScreenState();
}

class _WebhooksScreenState extends State<WebhooksScreen> {
  final DeltaPagAPI _api = DeltaPagAPI();
  final List<WebhookConfiguration> _webhooks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Nota: API não tem endpoint de listagem, então vamos usar lista local
  }

  void _addWebhook(WebhookConfiguration webhook) {
    setState(() {
      _webhooks.add(webhook);
    });
  }

  Future<void> _deleteWebhook(int index) async {
    final webhook = _webhooks[index];
    if (webhook.id == null) {
      setState(() {
        _webhooks.removeAt(index);
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Webhook'),
        content: const Text('Deseja realmente deletar este webhook? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final success = await _api.deleteWebhook(webhook.id!);

      if (mounted) {
        if (success) {
          setState(() {
            _webhooks.removeAt(index);
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Webhook deletado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao deletar webhook'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webhooks'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showInfoDialog(),
            tooltip: 'Ajuda',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _webhooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.webhook, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum webhook configurado',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crie um webhook para receber notificações',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _webhooks.length,
                  itemBuilder: (context, index) {
                    final webhook = _webhooks[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.webhook,
                                    color: Colors.blue.shade700,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        webhook.eventDisplay,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        webhook.authTypeDisplay,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteWebhook(index),
                                  tooltip: 'Deletar',
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow('URL', webhook.notificationUrl),
                            _buildInfoRow('Timeout', '${webhook.timeoutSeconds}s'),
                            _buildInfoRow('Retries', webhook.retryCount.toString()),
                            if (webhook.authType != 'NONE') ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.security, size: 16, color: Colors.orange.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Autenticação configurada',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateWebhookScreen(),
            ),
          );
          if (result != null && result is WebhookConfiguration) {
            _addWebhook(result);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Webhook'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Sobre Webhooks'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Webhooks são notificações automáticas enviadas pela API para sua aplicação quando eventos específicos ocorrem.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Eventos disponíveis:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('• Novo Alerta (NEW_ALERT)', style: TextStyle(fontSize: 13)),
              Text('• Nova Assinatura (NEW_SUBSCRIPTION)', style: TextStyle(fontSize: 13)),
              Text('• Assinatura Cancelada (CANCELED_SUBSCRIPTION)', style: TextStyle(fontSize: 13)),
              Text('• Assinatura Ativa (ACTIVE_SUBSCRIPTION)', style: TextStyle(fontSize: 13)),
              Text('• Assinatura Vencida (OVERDUE_SUBSCRIPTION)', style: TextStyle(fontSize: 13)),
              Text('• Token de Ticket (TICKET_TOKEN)', style: TextStyle(fontSize: 13)),
              SizedBox(height: 16),
              Text(
                'Configure a URL de destino e a autenticação necessária para receber as notificações.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
