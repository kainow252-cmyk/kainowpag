# 📊 Dados Reais Disponíveis - API BemPaggo

**URL da API:** `https://api.bempaggo.io/api/v2`  
**Seller ID:** `786` (extraído do token JWT)  
**Token Válido até:** 2099  
**Aplicação:** https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai

---

## ⚠️ Padrões de URL da API

A documentação oficial mostra endpoints com `/sellers/{sellerId}/` mas eles retornam **405 Method Not Allowed**.

**✅ Use este padrão (FUNCIONA):**
- `/api/v2/customers`
- `/api/v2/products`
- `/api/v2/invoices`
- `/api/v2/charges`

**❌ NÃO use (retorna 405):**
- `/api/v2/sellers/786/invoices`
- `/api/v2/sellers/786/recurring-invoices`

---

## 📦 Produtos Cadastrados (1)

### Produto #1 - Assistências
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
💰 **Valor:** R$ 39,90  
🔁 **Tipo:** RECURRING (Recorrente)  
✅ **Status:** Ativo  
🏪 **Descrição:** Club de desconto

---

## 👥 Clientes Cadastrados (2)

### Cliente #1 - GELCI JOSE DA SILVA
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
  "registerDate": "2026-02-25T11:59:35.000+00:00"
}
```
📱 **Contato:** (11) 99988-7766  
📧 **Email:** gelci@email.com

**💳 Cartões Cadastrados (5):**
1. ✅ **MASTERCARD ****4840** (Padrão) - Venc: 12/2033
2. MASTERCARD ****4840 - Venc: 12/2033  
3. MASTERCARD ****8229 - Venc: 02/2034
4. MASTERCARD ****8229 - Venc: 02/2034
5. MASTERCARD ****8229 - Venc: 02/2034

---

### Cliente #2 - Tony Stark
```json
{
  "id": 10,
  "name": "Tony Stark",
  "document": "51190844001",
  "email": "tony@starkindustries.com",
  "birthdate": "2000-01-01",
  "phone": {
    "countryCode": "55",
    "areaCode": "11",
    "number": "987654321"
  },
  "address": {
    "id": 1,
    "street": "Rua Jair Hamms",
    "streetNumber": "38",
    "lineTwo": "Sala 101",
    "neighborhood": "Pedra Branca",
    "city": "Palhoça",
    "state": "SC",
    "zipCode": "88137084"
  },
  "registerDate": "2026-02-26T11:03:16.000+00:00"
}
```
📱 **Contato:** (11) 98765-4321  
📧 **Email:** tony@starkindustries.com  
📍 **Endereço:** Rua Jair Hamms, 38, Sala 101 - Pedra Branca, Palhoça/SC - CEP: 88137-084

---

## 🧾 Faturas Cadastradas (2)

### Fatura #2 - ABERTA
```json
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
    "document": "11013430794"
  }
}
```
💰 **Valor:** R$ 39,90  
📅 **Vencimento:** 28/01/2026  
🟢 **Status:** OPEN (Aberta)  
🔗 **Link Pagamento:** [Pagar agora](https://pay.bempaggo.com.br/invoice/pp8fj19c94ac0977)

---

### Fatura #1 - FECHADA
```json
{
  "id": 1,
  "dueDate": 1772161199999,
  "status": "CLOSED",
  "closeDate": 1772020828513,
  "amount": 3990,
  "customer": {
    "id": 1,
    "name": "GELCI JOSE DA SILVA",
    "document": "11013430794"
  }
}
```
💰 **Valor:** R$ 39,90  
📅 **Vencimento:** 27/12/2025  
🔴 **Status:** CLOSED (Fechada)  
👤 **Cliente:** GELCI JOSE DA SILVA

---

## 💳 Cobranças Registradas (3)

### Cobrança #1 - FALHOU (3DS Obrigatório)
```json
{
  "id": 1,
  "status": "FAIL",
  "value": 3990,
  "transaction": {
    "status": "FAIL",
    "returnCode": "BP428",
    "returnMessage": "Autenticação 3DS obrigatória para completar a transação.",
    "brand": "MASTERCARD",
    "lastFourCardNumber": "4840"
  },
  "customer": {
    "id": 1,
    "name": "GELCI JOSE DA SILVA"
  }
}
```
💰 **Valor:** R$ 39,90  
🔴 **Status:** FAIL (Falhou)  
💳 **Cartão:** MASTERCARD ****4840  
⚠️ **Motivo:** Autenticação 3DS obrigatória

---

### Cobrança #2 - AGENDADA
```json
{
  "id": 2,
  "status": "SCHEDULE",
  "value": 3990,
  "customer": {
    "id": 1,
    "name": "GELCI JOSE DA SILVA"
  }
}
```
💰 **Valor:** R$ 39,90  
🟡 **Status:** SCHEDULE (Agendada)  
👤 **Cliente:** GELCI JOSE DA SILVA

---

### Cobrança #3 - PAGA ✅
```json
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
    "name": "GELCI JOSE DA SILVA"
  }
}
```
💰 **Valor:** R$ 39,90  
✅ **Status:** PAY (Pago)  
💳 **Cartão:** MASTERCARD ****4840  
🎯 **NSU:** 001010202  
💚 **Autorização:** APROVADA

---

## 📈 Estatísticas do Dashboard

### Métricas Calculadas
- **Total de Clientes:** 2
- **Total de Faturas:** 2
- **Total de Cobranças:** 3
- **Valor Total Processado:** R$ 119,70 (3 x R$ 39,90)

### Status das Cobranças
- ✅ **Pagas:** 1 (33%)
- 🟡 **Agendadas:** 1 (33%)
- 🔴 **Falhadas:** 1 (33%)

### Status das Faturas
- 🟢 **Abertas:** 1 (50%)
- 🔴 **Fechadas:** 1 (50%)

---

## 🧪 Como Testar no App

### 1. Buscar Cliente por CPF
- Vá em **Clientes** → Digite **11013430794** → Buscar
- Resultado: GELCI JOSE DA SILVA

### 2. Ver Faturas
- Vá em **Faturas** → Veja as 2 faturas listadas
- Fatura #2 (OPEN) com link de pagamento
- Fatura #1 (CLOSED)

### 3. Ver Cobranças
- Vá em **Cobranças** → Veja as 3 cobranças
- 1 PAGA, 1 AGENDADA, 1 FALHOU

### 4. Dashboard
- Veja métricas em tempo real
- Contadores de clientes, faturas, cobranças
- Valores processados

---

## 🔧 Endpoints Disponíveis

### ✅ Funcionando 100%
- `GET /customers/document/{cpf}` - Buscar cliente
- `POST /customers` - Criar cliente
- `GET /invoices?page=0&size=20` - Listar faturas
- `POST /invoices` - Criar fatura
- `GET /charges?page=0&size=20` - Listar cobranças
- `POST /charges` - Criar cobrança

### ❌ Sem Permissão (Token Atual)
- `GET /subscriptions` - 401 Unauthorized
- `GET /orders` - 401 Unauthorized
- `GET /products` - 405 Method Not Allowed

---

## 🎯 Próximos Passos

1. **Implementar tela de Cobranças completa**
   - Listagem com filtros de status
   - Criação de nova cobrança
   - Captura de cobrança autorizada
   - Estorno de cobrança

2. **Melhorar Dashboard**
   - Gráficos de cobranças por status
   - Timeline de transações
   - Métricas de conversão

3. **Adicionar mais funcionalidades**
   - Envio de fatura por email
   - Notificações de pagamento
   - Histórico de transações

---

**Última atualização:** 26/02/2026  
**API Version:** v2  
**App Status:** 🟢 Online e Funcional
