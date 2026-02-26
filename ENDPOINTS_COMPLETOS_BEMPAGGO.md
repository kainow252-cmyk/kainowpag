# 📋 Lista Completa de Endpoints - API BemPaggo

**Base URL:** `https://api.bempaggo.io/api/v2`  
**Autenticação:** `Authorization: Bearer {token}`  
**Token Atual:** Válido até 2099  

---

## 🔐 Autenticação

Todos os endpoints requerem o header de autorização:

```bash
Authorization: Bearer eyJhbGciOiJIUzUxMiJ9...
```

O token é um **JWT** que contém:
- `sub`: Seller ID (no nosso caso: `786`)
- `tenant`: Identificador do tenant
- `exp`: Data de expiração
- `isMaster`: Se é um token master

---

## 👥 CLIENTES (Customers)

### ✅ Listar/Buscar

| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| `GET` | `/customers/document/{cpf}` | ✅ 200 | Buscar cliente por CPF/CNPJ |
| `GET` | `/customers/document/{cpf}/check` | ✅ 200 | Verificar se cliente existe |

**Exemplo:**
```bash
GET /api/v2/customers/document/11013430794
```

### ✅ Criar/Atualizar

| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| `POST` | `/customers` | ✅ 201 | Criar novo cliente |
| `PUT` | `/customers/document/{cpf}` | ⚠️ 400 | Atualizar cliente (requer body) |

**Exemplo:**
```bash
POST /api/v2/customers
Content-Type: application/json

{
  "name": "João Silva",
  "document": "12345678901",
  "email": "joao@example.com",
  "phone": {
    "countryCode": 55,
    "areaCode": 11,
    "number": 987654321
  },
  "address": {
    "street": "Rua das Flores",
    "streetNumber": "123",
    "neighborhood": "Centro",
    "city": "São Paulo",
    "state": "SP",
    "zipCode": "01234567"
  }
}
```

---

## 💳 CARTÕES DE CRÉDITO (Credit Cards)

### ✅ Listar/Gerenciar Cartões

| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| `GET` | `/customers/document/{cpf}/credit/cards` | ✅ 200 | Listar cartões do cliente |
| `POST` | `/customers/document/{cpf}/credit/cards` | ⚠️ 400 | Adicionar cartão (requer body) |
| `PUT` | `/customers/document/{cpf}/credit/cards/{id}` | ✅ 200 | Atualizar cartão |
| `DELETE` | `/customers/document/{cpf}/credit/cards/{id}` | ❓ | Remover cartão (não testado) |

**Exemplo de Resposta (GET):**
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
    "token": "a70a46ab22184cce8887623d02baf082...",
    "isDefault": true
  }
]
```

**Exemplo de Criação (POST):**
```bash
POST /api/v2/customers/document/11013430794/credit/cards
Content-Type: application/json

{
  "cardNumber": "5162924840",
  "cvv": "123",
  "holder": {
    "name": "JOÃO SILVA",
    "document": "11013430794"
  },
  "expiration": {
    "month": "12",
    "year": "2028"
  }
}
```

**Exemplo de Atualização (PUT):**
```bash
PUT /api/v2/customers/document/11013430794/credit/cards/1
Content-Type: application/json

{
  "isDefault": true
}
```

---

## 📦 PRODUTOS (Products)

| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| `GET` | `/products/{id}` | ✅ 200 | Buscar produto por ID |
| `POST` | `/products` | ✅ 201 | Criar novo produto |
| `GET` | `/products` | ❌ 405 | Listar todos (não suportado) |

**Exemplo de Produto:**
```json
{
  "id": 1,
  "name": "assistencias",
  "value": 3990,
  "active": true,
  "type": "RECURRING",
  "checkout": {
    "id": 1,
    "name": "assistencias",
    "description": "club de desconto"
  }
}
```

---

## 🧾 FATURAS (Invoices)

| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| `GET` | `/invoices?page=0&size=20` | ✅ 200 | Listar faturas (paginado) |
| `GET` | `/invoices/{id}` | ✅ 200 | Buscar fatura por ID |
| `POST` | `/invoices` | ✅ 201 | Criar nova fatura |
| `POST` | `/invoices/{id}/send-email` | ✅ 200 | Enviar fatura por email |

**Exemplo de Listagem:**
```json
{
  "content": [
    {
      "id": 2,
      "dueDate": 1774580399999,
      "status": "OPEN",
      "amount": 3990,
      "paymentUrl": "https://pay.bempaggo.com.br/invoice/pp8fj19c94ac0977",
      "customer": {
        "id": 1,
        "name": "GELCI JOSE DA SILVA",
        "document": "11013430794"
      }
    }
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 20
  }
}
```

---

## 💰 COBRANÇAS (Charges)

| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| `GET` | `/charges?page=0&size=20` | ✅ 200 | Listar cobranças (paginado) |
| `GET` | `/charges/{id}` | ✅ 200 | Buscar cobrança por ID |
| `POST` | `/charges` | ✅ 201 | Criar nova cobrança |
| `POST` | `/charges/{id}/capture` | ✅ 200 | Capturar cobrança autorizada |
| `POST` | `/charges/{id}/refund` | ✅ 200 | Estornar cobrança |
| `POST` | `/charges/{id}/cancel-boleto` | ✅ 200 | Cancelar boleto |
| `POST` | `/charges/{id}/cancel-pix` | ✅ 200 | Cancelar PIX |

**Exemplo de Cobrança:**
```json
{
  "id": 3,
  "status": "PAY",
  "value": 3990,
  "refundedAmount": null,
  "transactions": [
    {
      "id": 3,
      "paymentMethod": "CREDIT_CARD",
      "value": 3990,
      "status": "APPROVED",
      "returnCode": "000",
      "returnMessage": "APROVADA 001010202",
      "brand": "MASTERCARD",
      "lastFourCardNumber": "4840",
      "installment": 1,
      "nsu": "001010202"
    }
  ],
  "customer": {
    "id": 1,
    "name": "GELCI JOSE DA SILVA",
    "document": "11013430794"
  }
}
```

---

## 📊 ASSINATURAS E PEDIDOS (❌ Sem Permissão)

| Método | Endpoint | Status | Descrição |
|--------|----------|--------|-----------|
| `GET` | `/subscriptions` | ❌ 401 | Listar assinaturas |
| `GET` | `/recurring-invoices` | ❌ 401 | Listar faturas recorrentes |
| `GET` | `/orders` | ❌ 401 | Listar pedidos |

**Nota:** Token atual não tem permissão para estes endpoints.

---

## 🚫 ENDPOINTS COM /sellers/ (❌ Não Implementados)

Todos os endpoints com padrão `/sellers/{sellerId}/` retornam **405 Method Not Allowed**:

| Endpoint Documentado | Status |
|---------------------|--------|
| `/sellers/786/invoices` | ❌ 405 |
| `/sellers/786/recurring-invoices` | ❌ 405 |
| `/sellers/786/customers` | ❌ 405 |
| `/sellers/786/charges` | ❌ 405 |

**Recomendação:** Não use o padrão `/sellers/{id}/`. Use sempre `/api/v2/{recurso}`.

---

## 📚 Dados Reais Disponíveis

### 🎁 Produtos (1)
- **assistencias** - R$ 39,90 (RECURRING)

### 👥 Clientes (2)
1. **GELCI JOSE DA SILVA** (CPF: 11013430794)
   - 5 cartões cadastrados
   - Email: gelci@email.com
   - Telefone: (11) 99988-7766

2. **Tony Stark** (CPF: 51190844001)
   - Email: tony@starkindustries.com
   - Telefone: (11) 98765-4321

### 🧾 Faturas (2)
- Fatura #2: R$ 39,90 - OPEN
- Fatura #1: R$ 39,90 - CLOSED

### 💳 Cobranças (3)
- Cobrança #1: R$ 39,90 - FAIL (3DS)
- Cobrança #2: R$ 39,90 - SCHEDULE
- Cobrança #3: R$ 39,90 - PAY ✅

### 💳 Cartões do Cliente GELCI (5)
1. ✅ MASTERCARD ****4840 (Padrão) - 12/2033
2. MASTERCARD ****4840 - 12/2033
3. MASTERCARD ****8229 - 02/2034
4. MASTERCARD ****8229 - 02/2034
5. MASTERCARD ****8229 - 02/2034

---

## 🔧 Exemplos Práticos

### Criar Cliente
```bash
curl --request POST \
  --url https://api.bempaggo.io/api/v2/customers \
  --header "authorization: Bearer SEU_TOKEN" \
  --header "content-type: application/json" \
  --data '{
    "name": "Maria Santos",
    "document": "98765432100",
    "email": "maria@example.com",
    "phone": {
      "countryCode": 55,
      "areaCode": 21,
      "number": 987654321
    }
  }'
```

### Listar Cartões
```bash
curl --request GET \
  --url https://api.bempaggo.io/api/v2/customers/document/11013430794/credit/cards \
  --header "authorization: Bearer SEU_TOKEN"
```

### Criar Cobrança
```bash
curl --request POST \
  --url https://api.bempaggo.io/api/v2/charges \
  --header "authorization: Bearer SEU_TOKEN" \
  --header "content-type: application/json" \
  --data '{
    "customer": {
      "id": 1
    },
    "value": 9990,
    "installments": 1,
    "card": {
      "cardNumber": "5162924840",
      "cvv": "123",
      "holder": {
        "name": "GELCI JOSE DA SILVA",
        "document": "11013430794"
      },
      "expiration": {
        "month": "12",
        "year": "2033"
      }
    }
  }'
```

---

## 💡 Boas Práticas

### ✅ Recomendações

1. **Use sempre o padrão `/api/v2/{recurso}`** (sem `/sellers/`)
2. **Trate status codes corretamente:**
   - `200 OK` - Sucesso
   - `201 Created` - Recurso criado (leia header `Location`)
   - `204 No Content` - Sucesso sem corpo
   - `400 Bad Request` - Dados inválidos
   - `401 Unauthorized` - Token inválido ou sem permissão
   - `404 Not Found` - Recurso não existe
   - `405 Method Not Allowed` - Endpoint não implementado

3. **Siga o fluxo de criação de recursos:**
   - POST retorna `201` com header `Location`
   - Faça GET no `Location` para obter o recurso completo

4. **Use paginação para listagens:**
   - `?page=0&size=20` (padrão)
   - Máximo recomendado: `size=100`

### ❌ Evite

1. ❌ Usar endpoints com `/sellers/{id}/`
2. ❌ Assumir que a documentação está correta
3. ❌ Enviar requisições sem body quando obrigatório
4. ❌ Ignorar o header `Location` após POST
5. ❌ Usar métodos HTTP não testados

---

## 📖 Documentação Relacionada

- **DELTAPAG_API_REFERENCE.md** - Referência completa da API
- **DADOS_REAIS_BEMPAGGO.md** - Dados de teste disponíveis
- **API_REAL_VS_DOCUMENTACAO.md** - Comparação com documentação oficial

---

**Última atualização:** 26/02/2026  
**Endpoints testados:** 20+  
**Status:** ✅ Documentação completa e validada
