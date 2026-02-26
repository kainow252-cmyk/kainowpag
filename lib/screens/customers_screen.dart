import 'package:flutter/material.dart';
import '../services/deltapag_api.dart';
import '../models/customer.dart';
import 'create_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final DeltaPagAPI _api = DeltaPagAPI();
  final TextEditingController _searchController = TextEditingController();
  Customer? _foundCustomer;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchCustomer() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Digite um CPF/CNPJ para buscar';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _foundCustomer = null;
    });

    try {
      final customer = await _api.getCustomerByDocument(_searchController.text);
      setState(() {
        _foundCustomer = customer;
        _isLoading = false;
        if (customer == null) {
          _errorMessage = 'Cliente não encontrado';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao buscar cliente: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por CPF/CNPJ',
                hintText: 'Digite o documento',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _foundCustomer = null;
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _searchCustomer(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_foundCustomer != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildCustomerCard(_foundCustomer!),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Busque um cliente ou adicione novo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCustomerScreen(),
            ),
          );
          if (result != null && result is Customer) {
            setState(() {
              _foundCustomer = result;
              _searchController.text = result.document;
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Cliente'),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'CPF/CNPJ: ${customer.document}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(Icons.cake, 'Data de Nascimento', customer.birthdate ?? 'Não informado'),
            if (customer.email != null)
              _buildInfoRow(Icons.email, 'Email', customer.email!),
            if (customer.phone != null)
              _buildInfoRow(Icons.phone, 'Telefone', customer.phone!.formatted),
            if (customer.address != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on, 'Endereço', customer.address!.formatted),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
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
