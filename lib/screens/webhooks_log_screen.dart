import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/payment_status.dart';

class WebhooksLogScreen extends StatefulWidget {
  const WebhooksLogScreen({super.key});

  @override
  State<WebhooksLogScreen> createState() => _WebhooksLogScreenState();
}

class _WebhooksLogScreenState extends State<WebhooksLogScreen> {
  List<Map<String, dynamic>> _webhooks = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'all';
  Timer? _autoRefreshTimer;
  bool _autoRefreshEnabled = true;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWebhooks();
    _startAutoRefresh();
  }
  
  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
  
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    if (_autoRefreshEnabled) {
      _autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _loadWebhooks(showLoading: false);
      });
    }
  }
  
  void _toggleAutoRefresh() {
    setState(() {
      _autoRefreshEnabled = !_autoRefreshEnabled;
    });
    if (_autoRefreshEnabled) {
      _startAutoRefresh();
    } else {
      _autoRefreshTimer?.cancel();
    }
  }

  Future<void> _loadWebhooks({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('/api/webhooks/log?limit=50'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newWebhooks = List<Map<String, dynamic>>.from(data['webhooks'] ?? []);
        
        setState(() {
          final newCount = newWebhooks.length;
          
          // Mostrar notificação se houver novos webhooks
          if (newCount > _lastCount && _lastCount > 0 && !showLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${newCount - _lastCount} novo(s) webhook(s) recebido(s)'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          }
          
          _webhooks = newWebhooks;
          _lastCount = newCount;
          _isLoading = false;
        });
      } else {
        if (showLoading) {
          setState(() {
            _error = 'Erro ao carregar webhooks: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (showLoading) {
        setState(() {
          _error = 'Erro ao carregar webhooks: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredWebhooks {
    if (_selectedFilter == 'all') return _webhooks;
    return _webhooks.where((w) => w['type'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String? status) {
    // Usar o modelo centralizado de status
    return PaymentStatus.getChargeColor(status);
  }

  String _getStatusText(String? status) {
    // Usar o modelo centralizado de status
    return PaymentStatus.getChargeName(status);
  }
  
  String _getStatusDescription(String? status) {
    // Descrição detalhada do status
    return PaymentStatus.getChargeDescription(status);
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'charge':
        return Icons.payment;
      case 'subscription':
        return Icons.subscriptions;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(date.toLocal());
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Webhooks Recebidos'),
        actions: [
          IconButton(
            icon: Icon(_autoRefreshEnabled ? Icons.pause_circle : Icons.play_circle),
            onPressed: _toggleAutoRefresh,
            tooltip: _autoRefreshEnabled ? 'Pausar atualização automática' : 'Ativar atualização automática',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadWebhooks(showLoading: true),
            tooltip: 'Atualizar agora',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar com contador e auto-refresh
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _autoRefreshEnabled ? Colors.green.shade50 : Colors.grey.shade100,
            child: Row(
              children: [
                Icon(
                  _autoRefreshEnabled ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: _autoRefreshEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _autoRefreshEnabled 
                      ? 'Atualização automática (10s)' 
                      : 'Atualização pausada',
                  style: TextStyle(
                    fontSize: 12,
                    color: _autoRefreshEnabled ? Colors.green.shade800 : Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_webhooks.length} webhook${_webhooks.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filtrar: '),
                const SizedBox(width: 8),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'all',
                        label: Text('Todos'),
                        icon: Icon(Icons.all_inclusive),
                      ),
                      ButtonSegment(
                        value: 'charge',
                        label: Text('Cobranças'),
                        icon: Icon(Icons.payment),
                      ),
                      ButtonSegment(
                        value: 'subscription',
                        label: Text('Assinaturas'),
                        icon: Icon(Icons.subscriptions),
                      ),
                    ],
                    selected: {_selectedFilter},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _selectedFilter = selection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Lista de webhooks
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadWebhooks,
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : _filteredWebhooks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum webhook recebido ainda',
                                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Os webhooks aparecerão aqui quando houver mudanças',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredWebhooks.length,
                            itemBuilder: (context, index) {
                              final webhook = _filteredWebhooks[_filteredWebhooks.length - 1 - index];
                              final type = webhook['type'] ?? 'unknown';
                              final status = webhook['status'];
                              final timestamp = webhook['timestamp'] ?? '';
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ExpansionTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColor(status),
                                    child: Icon(_getTypeIcon(type), color: Colors.white),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        type == 'charge' ? 'Cobrança' : 'Assinatura',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getStatusText(status),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (type == 'charge') ...[
                                        Text('ID: ${webhook['charge_id'] ?? 'N/A'}'),
                                        if (webhook['value'] != null)
                                          Text('Valor: R\$ ${(webhook['value'] / 100).toStringAsFixed(2)}'),
                                        if (webhook['customer'] != null)
                                          Text('Cliente: ${webhook['customer']}'),
                                      ] else if (type == 'subscription') ...[
                                        Text('ID: ${webhook['subscription_id'] ?? 'N/A'}'),
                                      ],
                                      Text(
                                        _formatDate(timestamp),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Descrição do Status
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(status).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: _getStatusColor(status).withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  PaymentStatus.getChargeIcon(status),
                                                  color: _getStatusColor(status),
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _getStatusDescription(status),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Dados Completos
                                          const Text(
                                            'Dados Completos (JSON):',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: SelectableText(
                                              jsonEncode(webhook['data'] ?? {}),
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
