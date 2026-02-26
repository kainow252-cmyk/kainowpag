import 'package:flutter/material.dart';
import '../services/deltapag_api.dart';
import '../models/product.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final DeltaPagAPI _api = DeltaPagAPI();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxInstallmentsController = TextEditingController(text: '12');
  
  String _productType = 'ONETIME';
  bool _feePassThrough = false;
  final List<String> _selectedMethods = ['CREDIT_CARD'];

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final valueInCents = (double.parse(_valueController.text) * 100).toInt();
      
      final product = Product(
        productType: _productType,
        affiliateId: 1,
        name: _nameController.text,
        value: valueInCents,
        maxInstallments: int.parse(_maxInstallmentsController.text),
        methods: _selectedMethods,
        description: _descriptionController.text,
        themeId: 1,
        feePassThrough: _feePassThrough,
      );

      final createdProduct = await _api.createProduct(product);

      if (!mounted) return;

      if (createdProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, createdProduct);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao criar produto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$) *',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxInstallmentsController,
                decoration: const InputDecoration(
                  labelText: 'Máximo de Parcelas *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _productType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Produto',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ONETIME', child: Text('Pagamento Único')),
                  DropdownMenuItem(value: 'RECURRING', child: Text('Recorrente')),
                ],
                onChanged: (value) {
                  setState(() {
                    _productType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Métodos de Pagamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              CheckboxListTile(
                title: const Text('Cartão de Crédito'),
                value: _selectedMethods.contains('CREDIT_CARD'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedMethods.add('CREDIT_CARD');
                    } else {
                      _selectedMethods.remove('CREDIT_CARD');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('PIX'),
                value: _selectedMethods.contains('PIX'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedMethods.add('PIX');
                    } else {
                      _selectedMethods.remove('PIX');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Boleto'),
                value: _selectedMethods.contains('BOLETO'),
                onChanged: (value) {
                  setState(() {
                    if (value!) {
                      _selectedMethods.add('BOLETO');
                    } else {
                      _selectedMethods.remove('BOLETO');
                    }
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Repassar Taxa ao Cliente'),
                value: _feePassThrough,
                onChanged: (value) {
                  setState(() {
                    _feePassThrough = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createProduct,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Criar Produto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    _maxInstallmentsController.dispose();
    super.dispose();
  }
}
