import 'package:flutter/material.dart';
import '../services/deltapag_api.dart';
import '../models/webhook.dart';

class CreateWebhookScreen extends StatefulWidget {
  const CreateWebhookScreen({super.key});

  @override
  State<CreateWebhookScreen> createState() => _CreateWebhookScreenState();
}

class _CreateWebhookScreenState extends State<CreateWebhookScreen> {
  final _formKey = GlobalKey<FormState>();
  final DeltaPagAPI _api = DeltaPagAPI();

  String _selectedEvent = WebhookEvent.newAlert;
  String _selectedAuthType = WebhookAuthType.none;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _authHeaderController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _customHeadersController = TextEditingController();
  int _timeoutSeconds = 30;
  int _retryCount = 3;
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    _authHeaderController.dispose();
    _apiKeyController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _customHeadersController.dispose();
    super.dispose();
  }

  Future<void> _createWebhook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final webhook = WebhookConfiguration(
        event: _selectedEvent,
        notificationUrl: _urlController.text.trim(),
        authType: _selectedAuthType,
        authorizationHeader: _selectedAuthType == WebhookAuthType.bearer ? _authHeaderController.text.trim() : null,
        apiKey: _selectedAuthType == WebhookAuthType.apiKey ? _apiKeyController.text.trim() : null,
        username: _selectedAuthType == WebhookAuthType.basic ? _usernameController.text.trim() : null,
        password: _selectedAuthType == WebhookAuthType.basic ? _passwordController.text.trim() : null,
        customHeaders: _selectedAuthType == WebhookAuthType.custom ? _customHeadersController.text.trim() : null,
        timeoutSeconds: _timeoutSeconds,
        retryCount: _retryCount,
      );

      final created = await _api.createWebhook(webhook);

      if (mounted) {
        setState(() => _isLoading = false);

        if (created != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Webhook criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, created);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao criar webhook'),
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
        title: const Text('Novo Webhook'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Evento'),
                    _buildEventDropdown(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('URL de Notificação'),
                    _buildUrlField(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Autenticação'),
                    _buildAuthTypeDropdown(),
                    const SizedBox(height: 16),
                    _buildAuthFields(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Configurações Avançadas'),
                    _buildAdvancedSettings(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _createWebhook,
                        child: const Text('Criar Webhook', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEventDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedEvent,
        isExpanded: true,
        underline: const SizedBox(),
        items: WebhookEvent.all.map((event) {
          return DropdownMenuItem(
            value: event,
            child: Text(WebhookEvent.getDisplay(event)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedEvent = value);
          }
        },
      ),
    );
  }

  Widget _buildUrlField() {
    return TextFormField(
      controller: _urlController,
      decoration: const InputDecoration(
        hintText: 'https://exemplo.com/webhook',
        prefixIcon: Icon(Icons.link),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'URL é obrigatória';
        }
        if (!value.startsWith('http://') && !value.startsWith('https://')) {
          return 'URL deve começar com http:// ou https://';
        }
        return null;
      },
    );
  }

  Widget _buildAuthTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedAuthType,
        isExpanded: true,
        underline: const SizedBox(),
        items: WebhookAuthType.all.map((authType) {
          return DropdownMenuItem(
            value: authType,
            child: Row(
              children: [
                Icon(
                  _getAuthIcon(authType),
                  size: 20,
                  color: authType == WebhookAuthType.none ? Colors.grey : Colors.blue,
                ),
                const SizedBox(width: 12),
                Text(WebhookAuthType.getDisplay(authType)),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedAuthType = value);
          }
        },
      ),
    );
  }

  IconData _getAuthIcon(String authType) {
    switch (authType) {
      case WebhookAuthType.none:
        return Icons.no_encryption;
      case WebhookAuthType.bearer:
        return Icons.key;
      case WebhookAuthType.basic:
        return Icons.lock;
      case WebhookAuthType.apiKey:
        return Icons.vpn_key;
      case WebhookAuthType.custom:
        return Icons.settings;
      default:
        return Icons.security;
    }
  }

  Widget _buildAuthFields() {
    switch (_selectedAuthType) {
      case WebhookAuthType.bearer:
        return TextFormField(
          controller: _authHeaderController,
          decoration: const InputDecoration(
            labelText: 'Bearer Token',
            hintText: 'Bearer seu_token_aqui',
            prefixIcon: Icon(Icons.key),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_selectedAuthType == WebhookAuthType.bearer && (value == null || value.trim().isEmpty)) {
              return 'Token é obrigatório';
            }
            return null;
          },
        );
      case WebhookAuthType.basic:
        return Column(
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuário',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_selectedAuthType == WebhookAuthType.basic && (value == null || value.trim().isEmpty)) {
                  return 'Usuário é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (_selectedAuthType == WebhookAuthType.basic && (value == null || value.trim().isEmpty)) {
                  return 'Senha é obrigatória';
                }
                return null;
              },
            ),
          ],
        );
      case WebhookAuthType.apiKey:
        return TextFormField(
          controller: _apiKeyController,
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: 'sua_api_key_aqui',
            prefixIcon: Icon(Icons.vpn_key),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (_selectedAuthType == WebhookAuthType.apiKey && (value == null || value.trim().isEmpty)) {
              return 'API Key é obrigatória';
            }
            return null;
          },
        );
      case WebhookAuthType.custom:
        return TextFormField(
          controller: _customHeadersController,
          decoration: const InputDecoration(
            labelText: 'Headers Customizados (JSON)',
            hintText: '{"X-Custom-Header": "valor"}',
            prefixIcon: Icon(Icons.code),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (_selectedAuthType == WebhookAuthType.custom && (value == null || value.trim().isEmpty)) {
              return 'Headers são obrigatórios';
            }
            return null;
          },
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nenhuma autenticação será usada',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildAdvancedSettings() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Timeout (segundos)', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: _timeoutSeconds,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [15, 30, 45, 60, 90, 120, 180, 300].map((seconds) {
                        return DropdownMenuItem(
                          value: seconds,
                          child: Text('${seconds}s'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _timeoutSeconds = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tentativas', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: _retryCount,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [0, 1, 2, 3, 4, 5, 10].map((count) {
                        return DropdownMenuItem(
                          value: count,
                          child: Text(count.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _retryCount = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'O timeout define quanto tempo aguardar pela resposta. As tentativas definem quantas vezes reenviar em caso de falha.',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
