# DeltaPag API - Referência Completa

## 📋 Informações Gerais

**Base URL Produção:** `https://api.bempaggo.io/api/v2` (ou `https://api.deltapag.io/api/v2` - ambos funcionam)
**Base URL Sandbox:** `https://apisandbox.bempaggo.io/api/v2`

⚠️ **Nota:** DeltaPag e BemPaggo são o mesmo serviço com dois domínios diferentes. Use o que preferir.

### 🔍 Padrão de URL dos Endpoints

A API BemPaggo usa **dois padrões diferentes** de URL:

**✅ PADRÃO 1 (Funciona) - Recursos Gerais:**
```
/api/v2/customers
/api/v2/products
/api/v2/invoices
/api/v2/charges
```

**⚠️ PADRÃO 2 (Documentação mostra, mas retorna 405) - Recursos por Seller:**
```
/api/v2/sellers/{sellerId}/recurring-invoices
/api/v2/sellers/{sellerId}/subscriptions
```

**Seller ID:** Extraído do token JWT (campo `sub`). No token atual: `786`

**Recomendação:** Use o **Padrão 1** (sem `/sellers/`) para todos os endpoints. O Padrão 2 está documentado mas não está ativo na API.

**Autenticação:** Bearer Token (JWT)
```
Authorization: Bearer {seu_token_jwt}
```

**Content-Type:** `application/json`

---

## 🔑 Códigos de Status

### Status de Pedido/Assinatura (Order/Subscription)
| Código | Descrição |
|--------|-----------|
| `ACTIVE` | Assinatura ativa e em dia |
| `OVERDUE` | Assinatura inadimplente (pagamento atrasado) |
| `CANCELED` | Assinatura cancelada |
| `PENDING` | Assinatura pendente (aguardando primeira cobrança) |
| `COUNTERCHARGE` | Cobrança contestada pelo cliente |
| `CHARGEBACK` | Estornada por fraude ou disputa |

### Status de Cobrança (Charge)
| Código | Descrição |
|--------|-----------|
| `PAY` | Cobrança paga com sucesso |
| `AUTHORIZED` | Cobrança autorizada (aguardando captura) |
| `PENDING` | Cobrança pendente de pagamento |
| `SCHEDULE` | Cobrança agendada para data futura |
| `REFUND` | Cobrança estornada |
| `COUNTERCHARGE` | Cobrança contestada |
| `CHARGEBACK` | Estornada por fraude |
| `FAIL` | Cobrança falhou (negada) |
| `CANCELED` | Cobrança cancelada |
| `IN_PROGRESS` | Cobrança em processamento |

### Status de Transação (Transaction)
| Código | Descrição |
|--------|-----------|
| `IN_PROGRESS` | Transação em processamento |
| `APPROVED` | Transação aprovada |
| `REFUND` | Transação estornada |
| `AUTHORIZED` | Transação autorizada |
| `NOT_AUTHORIZED` | Transação não autorizada |
| `NOT_APPROVED` | Transação não aprovada |
| `CHARGEBACK` | Estornada por fraude |
| `COUNTERCHARGE` | Contestada pelo cliente |
| `FAIL` | Transação falhou |
| `AWAITING_PAYMENT` | Aguardando pagamento (PIX/Boleto) |

### Tipos de Transação (Transaction Type)
| Tipo | Descrição |
|------|-----------|
| `ACCESSION` | Transação de adesão (primeira cobrança) |
| `RECURRENT` | Transação recorrente (assinatura) |
| `LOOSE` | Transação avulsa (não recorrente) |
| `REFUND` | Estorno |
| `CHARGEBACK` | Chargeback |
| `COUNTERCHARGE` | Contestação |

### Motivos de Estorno (Refund Reason)
| Código | Descrição |
|--------|-----------|
| `DUPLICATE_CHARGE` | Cobrança duplicada |
| `IMPROPER_CHARGE` | Cobrança indevida |
| `COSTUMER_WITHDRAWAL` | Desistência do cliente |
| `OTHERS` | Outros motivos |

---

## 🎯 Endpoints Principais

### 1. Clientes (Customers)

#### 1.1 Buscar Cliente por CPF/CNPJ
```http
GET /customers/document/{document}
```
**Response:** `200 OK` - Retorna o cliente
```json
{
  "id": 1,
  "name": "GELCI JOSE DA SILVA",
  "document": "11013430794",
  "email": "gelci@email.com",
  "phone": {
    "countryCode": "55",
    "areaCode": "11",
    "number": "999887766"
  },
  "registerDate": "2026-02-25T11:59:35.000+00:00",
  "birthdate": null,
  "address": null
}
```

#### 1.2 Verificar se Cliente Existe
```http
GET /customers/document/{document}/check
```
**Response:** 
- `204 No Content` - Cliente existe
- `404 Not Found` - Cliente não existe

#### 1.3 Criar Cliente
```http
POST /customers
Content-Type: application/json

{
  "name": "João da Silva",
  "document": "12345678901",
  "email": "joao@email.com",
  "birthdate": "1990-01-15",
  "phone": {
    "countryCode": "55",
    "areaCode": "11",
    "number": "987654321"
  },
  "address": {
    "street": "Rua das Flores",
    "number": "123",
    "complement": "Apto 45",
    "district": "Centro",
    "city": "São Paulo",
    "state": "SP",
    "zipCode": "01234567",
    "country": "BR"
  }
}
```
**Response:** `201 Created`
**Header:** `Location: /api/v2/customers/{id}`

#### 1.4 Buscar Cliente por ID (após criar)
```http
GET {Location}
```
**Response:** `200 OK` - Retorna o cliente criado

#### 1.5 Atualizar Cliente
```http
PUT /customers/document/{document}
Content-Type: application/json

{
  "name": "João da Silva Atualizado",
  "email": "novo@email.com",
  "phone": {
    "countryCode": "55",
    "areaCode": "11",
    "number": "999999999"
  }
}
```
**Response:** `200 OK` - Cliente atualizado (requer body completo)

#### 1.6 Listar Cartões do Cliente
```http
GET /customers/document/{document}/credit/cards
```
**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "holder": {
      "name": "GELCI JOSE DA SILVA",
      "document": "11013430794"
    },
    "bin": "516292",
    "lastFour": "4840",
    "expiration": {
      "year": "2033",
      "month": "12"
    },
    "brand": "MASTERCARD",
    "token": "a70a46ab22184cce8887623d02baf082b8ddc5c7a626458097baa271999bf74d",
    "isDefault": true
  }
]
```

#### 1.7 Adicionar Cartão ao Cliente
```http
POST /customers/document/{document}/credit/cards
Content-Type: application/json

{
  "cardNumber": "5162924840",
  "cvv": "123",
  "holder": {
    "name": "JOÃO SILVA",
    "document": "12345678901"
  },
  "expiration": {
    "month": "12",
    "year": "2028"
  }
}
```
**Response:** `201 Created`

#### 1.8 Atualizar Cartão do Cliente
```http
PUT /customers/document/{document}/credit/cards/{id}
Content-Type: application/json

{
  "isDefault": true
}
```
**Response:** `200 OK` - Define cartão como padrão

---

### 2. Produtos (Products)

#### 2.1 Criar Produto
```http
POST /products
Content-Type: application/json

{
  "name": "Plano Premium",
  "description": "Acesso completo por 30 dias",
  "value": 9990,
  "installments": 1,
  "acceptedPaymentMethods": ["CREDIT_CARD", "PIX", "BOLETO"],
  "themeId": null
}
```
**Response:** `201 Created`
**Header:** `Location: /api/v2/products/{id}`

#### 2.2 Buscar Produto por ID
```http
GET /products/{id}
```
**Response:** `200 OK`

⚠️ **Nota:** `GET /products` (listar todos) retorna `405 Method Not Allowed`

---

### 3. Faturas (Invoices)

#### 3.1 Listar Faturas (com paginação)
```http
GET /invoices?page=0&size=20
```
**Response:** `200 OK`
```json
[
  {
    "id": 2,
    "dueDate": 1774580399999,
    "status": "OPEN",
    "closeDate": 1774407600001,
    "amount": 3990,
    "paymentUrl": "https://pay.bempaggo.com.br/invoice/pp8fj19c94ac0977",
    "customer": {
      "id": 1,
      "name": "GELCI JOSE DA SILVA",
      "document": "11013430794",
      "email": "gelci@email.com"
    }
  }
]
```

#### 3.2 Criar Fatura
```http
POST /invoices
Content-Type: application/json

{
  "customer": {
    "id": 1
  },
  "dueDate": "2026-03-15T23:59:59.000Z",
  "items": [
    {
      "product": {
        "id": 1
      },
      "quantity": 1,
      "value": 9990
    }
  ],
  "acceptedPaymentMethods": ["CREDIT_CARD", "PIX", "BOLETO"]
}
```
**Response:** `201 Created`
**Header:** `Location: /api/v2/invoices/{id}`

#### 3.3 Buscar Fatura por ID
```http
GET /invoices/{id}
```
**Response:** `200 OK`

#### 3.4 Enviar Fatura por Email
```http
POST /invoices/{id}/send-email
```
**Response:** `200 OK`

---

### 4. Cobranças (Charges)

#### 4.1 Listar Cobranças
```http
GET /charges?page=0&size=20
```
**Response:** `200 OK`
```json
[
  {
    "id": 3,
    "status": "PAY",
    "value": 3990,
    "transaction": {
      "status": "APPROVED",
      "returnCode": "000",
      "returnMessage": "APROVADA 001010202",
      "brand": "MASTERCARD",
      "lastFourCardNumber": "4840",
      "installment": 1,
      "nsu": "001010202"
    },
    "customer": {
      "id": 1,
      "name": "GELCI JOSE DA SILVA",
      "document": "11013430794"
    }
  }
]
```

#### 4.2 Criar Cobrança (Cartão de Crédito)
```http
POST /charges
Content-Type: application/json

{
  "customer": {
    "id": 1
  },
  "value": 9990,
  "installments": 1,
  "card": {
    "cardNumber": "5555666677778884",
    "cvv": "123",
    "holder": {
      "name": "JOÃO SILVA",
      "document": "12345678901"
    },
    "expiration": {
      "month": "12",
      "year": "2028"
    }
  },
  "yourReferenceId": "pedido-123",
  "notificationUrl": "https://seusite.com/webhook"
}
```
**Response:** `201 Created`
**Header:** `Location: /api/v2/charges/{id}`

#### 4.3 Capturar Cobrança Autorizada
```http
POST /charges/{id}/capture
```
**Response:** `200 OK`

#### 4.4 Estornar Cobrança
```http
POST /charges/{id}/refund
Content-Type: application/json

{
  "amount": 9990,
  "reason": "DUPLICATE_CHARGE"
}
```
**Response:** `200 OK`

#### 4.5 Cancelar Boleto
```http
POST /charges/{id}/cancel-boleto
```
**Response:** `200 OK`

#### 4.6 Cancelar PIX
```http
POST /charges/{id}/cancel-pix
```
**Response:** `200 OK`

---

### 5. Assinaturas (Subscriptions) ❌ TOKEN ATUAL SEM PERMISSÃO

```http
GET /subscriptions?page=0&size=20
```
**Response:** `401 Unauthorized`

⚠️ **Nota:** O token atual não possui permissão para acessar assinaturas. É necessário gerar um novo token no painel DeltaPag com permissões completas.

---

### 6. Pedidos (Orders) ❌ TOKEN ATUAL SEM PERMISSÃO

```http
GET /orders?page=0&size=20
```
**Response:** `401 Unauthorized`

---

## 🔄 Fluxo de Criação de Recursos

Todos os endpoints POST retornam:
- **Status:** `201 Created`
- **Header:** `Location: /api/v2/{resource}/{id}`

**Fluxo recomendado:**
1. Fazer POST para criar o recurso
2. Ler o header `Location` da resposta
3. Fazer GET no endpoint `Location` para obter o recurso completo

**Exemplo em Dart:**
```dart
// 1. Criar cliente
final createResponse = await http.post(
  Uri.parse('https://api.deltapag.io/api/v2/customers'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode(customerData),
);

// 2. Ler Location header
if (createResponse.statusCode == 201) {
  final location = createResponse.headers['location'];
  
  // 3. Buscar cliente criado
  final getResponse = await http.get(
    Uri.parse('https://api.deltapag.io/api/v2$location'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  final customer = Customer.fromJson(jsonDecode(getResponse.body));
}
```

---

## 📊 Dados Reais Disponíveis (Token Atual)

### ✅ Endpoints Funcionando
- `/customers` - Criar, buscar, verificar
- `/products` - Criar, buscar por ID
- `/invoices` - Criar, listar, buscar, enviar email
- `/charges` - Criar, listar, capturar, estornar, cancelar

### ❌ Endpoints Sem Permissão
- `/subscriptions` - 401 Unauthorized
- `/orders` - 401 Unauthorized
- `/products` (GET all) - 405 Method Not Allowed

### 📦 Cliente de Teste Real
```json
{
  "name": "GELCI JOSE DA SILVA",
  "document": "11013430794",
  "email": "gelci@email.com",
  "phone": "(11) 99988-7766"
}
```

### 💰 Faturas Reais
- **Fatura #2:** R$ 39,90 - Status OPEN - Vencimento 28/01/2026
- **Fatura #1:** R$ 39,90 - Status CLOSED

### 💳 Cobranças Reais
- **Cobrança #1:** R$ 39,90 - Status FAIL (3DS obrigatório)
- **Cobrança #2:** R$ 39,90 - Status SCHEDULE
- **Cobrança #3:** R$ 39,90 - Status PAY - MASTERCARD ****4840

---

## 🚀 Como Usar no Flutter

### 1. Buscar Cliente
```dart
final customer = await api.getCustomerByDocument('11013430794');
```

### 2. Criar Cliente
```dart
final customer = await api.createCustomer(customerData);
```

### 3. Listar Faturas
```dart
final invoices = await api.listInvoices(page: 0, size: 20);
```

### 4. Criar Fatura
```dart
final invoice = await api.createInvoice(invoiceData);
```

### 5. Listar Cobranças
```dart
final charges = await api.listCharges(page: 0, size: 20);
```

---

## 🔐 Token Atual

```
eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI3ODYiLCJ0ZW5hbnQiOiJiZW1wYWdnb19rYWlub3dwcm9tb2Nhb2RldmVuXzJfMjc5MjM3NDYwMDAxMjMiLCJpYXQiOjE3NzIwMjY3NTEsImV4cCI6NDEwMjM1ODM5OSwiaXNNYXN0ZXIiOnRydWV9.JGLFdcv-WrJg0i-XDRnX1JsSaChXi2ASCksfPKzejhlHDgEnA-uXvscdYULKw51PgldKWFiPU8pRdq6EMJ3AEg
```

**Válido até:** 2099
**Permissões:** Clientes, Produtos, Faturas, Cobranças
**Sem permissão:** Assinaturas, Pedidos

---

## 📝 Notas Importantes

1. **Paginação:** Todos os endpoints de listagem suportam `?page=0&size=20`
2. **Datas:** Timestamps em milissegundos (Unix timestamp)
3. **Valores:** Sempre em centavos (R$ 39,90 = 3990)
4. **Headers Location:** Sempre usar após POST para buscar recurso criado
5. **Status Codes:**
   - `200 OK` - Sucesso
   - `201 Created` - Recurso criado
   - `204 No Content` - Sucesso sem corpo
   - `401 Unauthorized` - Token inválido ou sem permissão
   - `404 Not Found` - Recurso não encontrado
   - `405 Method Not Allowed` - Método HTTP não suportado

---

## 🎯 Próximos Passos

### Para habilitar Assinaturas:
1. Acessar painel DeltaPag: https://painel.deltapag.io
2. Gerar novo token com permissões completas
3. Incluir permissão para `/api/v2/subscriptions`
4. Atualizar token em `lib/services/deltapag_api.dart`

### Endpoints a implementar:
- ✅ Clientes (100% implementado)
- ✅ Produtos (criar e buscar)
- ✅ Faturas (100% implementado)
- ✅ Cobranças (100% implementado)
- ⏳ Assinaturas (aguardando permissão)
- ⏳ Pedidos (aguardando permissão)
- ⏳ Webhooks (a implementar)
- ⏳ Split de pagamento (a implementar)

---

**Documentação gerada em:** 27/12/2025
**Aplicação:** Payment Master - DeltaPag Integration
**Versão da API:** v2
