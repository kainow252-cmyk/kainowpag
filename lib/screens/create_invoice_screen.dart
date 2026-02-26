import 'package:flutter/material.dart';
import '../services/deltapag_api.dart';
import '../models/invoice.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final DeltaPagAPI _api = DeltaPagAPI();
  bool _isLoading = false;

  final _customerIdController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _productIdController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  Future<void> _createInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final priceInCents = (double.parse(_priceController.text) * 100).toInt();
      final dueDate = DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch;

      final invoice = Invoice(
        customerId: int.parse(_customerIdController.text),
        invoiceNumber: _invoiceNumberController.text,
        dueDate: dueDate,
        items: [
          InvoiceItem(
            productId: int.parse(_productIdController.text),
            quantity: int.parse(_quantityController.text),
            unitPriceInCents: priceInCents,
          ),
        ],
        acceptedPaymentMethods: [
          PaymentMethod(
            method: 'CREDIT_CARD',
            cardSettings: CardSettings(
              maxInstallments: 12,
              feePassThrough: false,
            ),
          ),
        ],
      );

      final createdInvoice = await _api.createInvoice(1, invoice);

      if (!mounted) return;

      if (createdInvoice != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fatura criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, createdInvoice);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao criar fatura'),
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
        title: const Text('Nova Fatura'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _customerIdController,
                decoration: const InputDecoration(
                  labelText: 'ID do Cliente *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _invoiceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número da Fatura *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productIdController,
                decoration: const InputDecoration(
                  labelText: 'ID do Produto *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço Unitário (R\$) *',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createInvoice,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Criar Fatura'),
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
    _customerIdController.dispose();
    _invoiceNumberController.dispose();
    _productIdController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
