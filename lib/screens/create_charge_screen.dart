import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/deltapag_api.dart';
import '../models/charge.dart';

class CreateChargeScreen extends StatefulWidget {
  const CreateChargeScreen({super.key});

  @override
  State<CreateChargeScreen> createState() => _CreateChargeScreenState();
}

class _CreateChargeScreenState extends State<CreateChargeScreen> {
  final DeltaPagAPI _api = DeltaPagAPI();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Tipo de pagamento
  String _paymentType = 'CREDIT_CARD'; // CREDIT_CARD, BOLETO, PIX

  // Dados do cliente
  final _customerNameController = TextEditingController();
  final _customerDocumentController = TextEditingController();

  // Dados da cobrança
  final _valueController = TextEditingController();
  int _installments = 1;
  final _referenceIdController = TextEditingController();

  // Dados do cartão (apenas para CREDIT_CARD)
  final _cardNumberController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _cardHolderDocumentController = TextEditingController();
  final _cardMonthController = TextEditingController();
  final _cardYearController = TextEditingController();
  String _cardBrand = 'VISA';

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerDocumentController.dispose();
    _valueController.dispose();
    _referenceIdController.dispose();
    _cardNumberController.dispose();
    _cardCvvController.dispose();
    _cardHolderNameController.dispose();
    _cardHolderDocumentController.dispose();
    _cardMonthController.dispose();
    _cardYearController.dispose();
    super.dispose();
  }

  Future<void> _createCharge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Converter valor de reais para centavos
      final valueInCents = (double.parse(_valueController.text) * 100).toInt();

      final customer = Customer(
        document: _customerDocumentController.text,
        name: _customerNameController.text,
      );

      Charge? newCharge;

      if (_paymentType == 'CREDIT_CARD') {
        // Criar cobrança com cartão de crédito
        final card = CreditCard(
          cardNumber: _cardNumberController.text.replaceAll(' ', ''),
          cvv: _cardCvvController.text,
          holder: CardHolder(
            name: _cardHolderNameController.text,
            document: _cardHolderDocumentController.text,
          ),
          expiration: CardExpiration(
            month: _cardMonthController.text.padLeft(2, '0'),
            year: _cardYearController.text,
          ),
          brand: _cardBrand,
        );

        final charge = Charge(
          customer: customer,
          value: valueInCents,
          installments: _installments,
          yourReferenceId: _referenceIdController.text.isNotEmpty
              ? _referenceIdController.text
              : null,
          card: card,
        );

        newCharge = await _api.createCharge(charge);
      } else if (_paymentType == 'BOLETO') {
        // TODO: Implementar criação de boleto
        // Endpoint: POST /charges/boleto
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Boleto ainda não implementado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      } else if (_paymentType == 'PIX') {
        // TODO: Implementar criação de PIX
        // Endpoint: POST /charges/pix
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIX ainda não implementado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _isLoading = false);

      if (mounted) {
        if (newCharge != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cobrança criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao criar cobrança'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Cobrança'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo de pagamento
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Método de Pagamento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'CREDIT_CARD',
                            label: Text('Cartão'),
                            icon: Icon(Icons.credit_card),
                          ),
                          ButtonSegment(
                            value: 'BOLETO',
                            label: Text('Boleto'),
                            icon: Icon(Icons.receipt),
                          ),
                          ButtonSegment(
                            value: 'PIX',
                            label: Text('PIX'),
                            icon: Icon(Icons.pix),
                          ),
                        ],
                        selected: {_paymentType},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _paymentType = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dados do cliente
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dados do Cliente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o nome do cliente';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customerDocumentController,
                        decoration: const InputDecoration(
                          labelText: 'CPF/CNPJ',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                          hintText: '000.000.000-00',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o CPF/CNPJ';
                          }
                          if (value.length != 11 && value.length != 14) {
                            return 'CPF/CNPJ inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dados da cobrança
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dados da Cobrança',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _valueController,
                        decoration: const InputDecoration(
                          labelText: 'Valor (R\$)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                          hintText: '100.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o valor';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                      if (_paymentType == 'CREDIT_CARD') ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Parcelas',
                          style: TextStyle(fontSize: 14),
                        ),
                        Slider(
                          value: _installments.toDouble(),
                          min: 1,
                          max: 12,
                          divisions: 11,
                          label: '${_installments}x',
                          onChanged: (value) {
                            setState(() => _installments = value.toInt());
                          },
                        ),
                        Center(
                          child: Text(
                            '$_installments parcelas',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _referenceIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID de Referência (opcional)',
                          prefixIcon: Icon(Icons.tag),
                          border: OutlineInputBorder(),
                          hintText: 'Seu identificador interno',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dados do cartão (apenas para CREDIT_CARD)
              if (_paymentType == 'CREDIT_CARD') ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dados do Cartão',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Número do cartão',
                            prefixIcon: Icon(Icons.credit_card),
                            border: OutlineInputBorder(),
                            hintText: '0000 0000 0000 0000',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o número do cartão';
                            }
                            if (value.length < 13 || value.length > 16) {
                              return 'Número do cartão inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cardCvvController,
                                decoration: const InputDecoration(
                                  labelText: 'CVV',
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(),
                                  hintText: '123',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe o CVV';
                                  }
                                  if (value.length < 3) {
                                    return 'CVV inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _cardBrand,
                                decoration: const InputDecoration(
                                  labelText: 'Bandeira',
                                  prefixIcon: Icon(Icons.payment),
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'VISA',
                                    child: Text('Visa'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'MASTERCARD',
                                    child: Text('Mastercard'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ELO',
                                    child: Text('Elo'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'AMEX',
                                    child: Text('Amex'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'HIPERCARD',
                                    child: Text('Hipercard'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _cardBrand = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _cardMonthController,
                                decoration: const InputDecoration(
                                  labelText: 'Mês',
                                  border: OutlineInputBorder(),
                                  hintText: '12',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Mês';
                                  }
                                  final month = int.tryParse(value);
                                  if (month == null ||
                                      month < 1 ||
                                      month > 12) {
                                    return 'Inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _cardYearController,
                                decoration: const InputDecoration(
                                  labelText: 'Ano',
                                  border: OutlineInputBorder(),
                                  hintText: '2025',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ano';
                                  }
                                  final year = int.tryParse(value);
                                  final currentYear = DateTime.now().year;
                                  if (year == null || year < currentYear) {
                                    return 'Inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Dados do Titular',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cardHolderNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome no cartão',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o nome do titular';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cardHolderDocumentController,
                          decoration: const InputDecoration(
                            labelText: 'CPF do titular',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(),
                            hintText: '00000000000',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o CPF do titular';
                            }
                            if (value.length != 11) {
                              return 'CPF inválido';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Botão criar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _createCharge,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _isLoading ? 'Criando...' : 'Criar Cobrança',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
