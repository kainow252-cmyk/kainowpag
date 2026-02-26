# 🔍 API BemPaggo - Diferenças entre Documentação e Realidade

## 📋 Resumo Executivo

A documentação oficial da API BemPaggo mostra alguns endpoints que **não funcionam** na prática. Este documento mapeia o que realmente funciona.

---

## ⚠️ PRINCIPAL DIFERENÇA: Padrão de URL

### 📄 O que a Documentação Mostra

```bash
# Exemplo da documentação oficial
POST https://api.bempaggo.io/api/v2/sellers/sellerId/recurring-invoices
```

**Padrão:** `/api/v2/sellers/{sellerId}/recurso`

### ✅ O que Realmente Funciona

```bash
# Endpoints que funcionam na prática
GET https://api.bempaggo.io/api/v2/customers
GET https://api.bempaggo.io/api/v2/invoices
GET https://api.bempaggo.io/api/v2/charges
```

**Padrão:** `/api/v2/recurso` (SEM `/sellers/{id}/`)

---

## 📊 Teste Comparativo

| Endpoint Documentado | Status Real | Endpoint Funcional | Status |
|---------------------|-------------|-------------------|--------|
| `/sellers/786/invoices` | ❌ 405 | `/invoices` | ✅ 200 |
| `/sellers/786/recurring-invoices` | ❌ 405 | `/recurring-invoices` | ❌ 401 |
| `/sellers/786/customers` | ❌ 405 | `/customers` | ✅ 200 |
| `/sellers/786/charges` | ❌ 405 | `/charges` | ✅ 200 |

---

## 🔑 Seller ID

**Como obter o Seller ID:**

O Seller ID está no **token JWT** no campo `sub`:

```bash
# Decodificar token JWT
echo "eyJhbGc..." | cut -d'.' -f2 | base64 -d | python3 -m json.tool

# Resultado:
{
  "sub": "786",           # ← SELLER ID
  "tenant": "bempaggo_kainowpromocaodeven_2_27923746000123",
  "iat": 1772096942,
  "exp": 4102358399,
  "isMaster": true
}
```

**Seller ID do token atual:** `786`

---

## ✅ Endpoints que FUNCIONAM (Testado e Confirmado)

### 1. Clientes (Customers)

```bash
# ✅ Buscar cliente por CPF/CNPJ
GET /api/v2/customers/document/{document}
Status: 200 OK

# ✅ Verificar se cliente existe
GET /api/v2/customers/document/{document}/check
Status: 200 OK (mesmo que não exista!)

# ✅ Criar cliente
POST /api/v2/customers
Status: 201 Created
```

### 2. Produtos (Products)

```bash
# ✅ Buscar produto por ID
GET /api/v2/products/{id}
Status: 200 OK

# ❌ Listar todos os produtos
GET /api/v2/products
Status: 405 Method Not Allowed
```

### 3. Faturas (Invoices)

```bash
# ✅ Listar faturas (paginado)
GET /api/v2/invoices?page=0&size=20
Status: 200 OK

# ✅ Buscar fatura por ID
GET /api/v2/invoices/{id}
Status: 200 OK

# ✅ Criar fatura
POST /api/v2/invoices
Status: 201 Created
```

### 4. Cobranças (Charges)

```bash
# ✅ Listar cobranças (paginado)
GET /api/v2/charges?page=0&size=20
Status: 200 OK

# ✅ Buscar cobrança por ID
GET /api/v2/charges/{id}
Status: 200 OK

# ✅ Criar cobrança
POST /api/v2/charges
Status: 201 Created

# ✅ Capturar cobrança autorizada
POST /api/v2/charges/{id}/capture
Status: 200 OK

# ✅ Estornar cobrança
POST /api/v2/charges/{id}/refund
Status: 200 OK
```

---

## ❌ Endpoints que NÃO FUNCIONAM

### 1. Com Token Atual (401 Unauthorized)

```bash
# ❌ Assinaturas
GET /api/v2/subscriptions
Status: 401 Unauthorized

# ❌ Faturas recorrentes
GET /api/v2/recurring-invoices
Status: 401 Unauthorized

# ❌ Pedidos
GET /api/v2/orders
Status: 401 Unauthorized
```

**Motivo:** Token atual não tem permissão para estes endpoints.

### 2. Padrão /sellers/ (405 Method Not Allowed)

```bash
# ❌ Todos os endpoints com /sellers/{id}/
GET /api/v2/sellers/786/invoices
Status: 405 Method Not Allowed

POST /api/v2/sellers/786/recurring-invoices
Status: 405 Method Not Allowed

GET /api/v2/sellers/786/customers
Status: 405 Method Not Allowed
```

**Motivo:** Endpoints com `/sellers/` não estão implementados na API, apenas documentados.

---

## 📦 Dados Reais Disponíveis

### Produtos (1)
```json
{
  "id": 1,
  "name": "assistencias",
  "value": 3990,
  "type": "RECURRING",
  "description": "club de desconto"
}
```

### Clientes (2)
1. GELCI JOSE DA SILVA (CPF: 11013430794)
2. Tony Stark (CPF: 51190844001)

### Faturas (2)
1. Fatura #2: R$ 39,90 - Status OPEN
2. Fatura #1: R$ 39,90 - Status CLOSED

### Cobranças (3)
1. Cobrança #1: R$ 39,90 - Status FAIL (3DS obrigatório)
2. Cobrança #2: R$ 39,90 - Status SCHEDULE
3. Cobrança #3: R$ 39,90 - Status PAY ✅

---

## 💡 Recomendações

### ✅ Faça isso:

1. **Use sempre o padrão `/api/v2/recurso`** (sem `/sellers/`)
2. **Ignore a documentação oficial** sobre endpoints `/sellers/{id}/`
3. **Use os endpoints testados** listados acima
4. **Verifique o status code** antes de processar a resposta
5. **Trate 405 como "endpoint não disponível"**

### ❌ Não faça isso:

1. ❌ Não tente usar `/sellers/{id}/` nos endpoints
2. ❌ Não assuma que a documentação está correta
3. ❌ Não confie em endpoints que retornam 405
4. ❌ Não use métodos HTTP não testados

---

## 🔧 Exemplos Práticos

### Exemplo 1: Buscar Cliente (CORRETO)

```bash
# ✅ CORRETO
curl --request GET \
  --url "https://api.bempaggo.io/api/v2/customers/document/11013430794" \
  --header "authorization: Bearer SEU_TOKEN"

# ❌ ERRADO (retorna 405)
curl --request GET \
  --url "https://api.bempaggo.io/api/v2/sellers/786/customers/document/11013430794" \
  --header "authorization: Bearer SEU_TOKEN"
```

### Exemplo 2: Criar Cliente (CORRETO)

```bash
# ✅ CORRETO
curl --request POST \
  --url "https://api.bempaggo.io/api/v2/customers" \
  --header "authorization: Bearer SEU_TOKEN" \
  --header "content-type: application/json" \
  --data '{
    "name": "João Silva",
    "document": "12345678901",
    "email": "joao@example.com"
  }'

# ❌ ERRADO (retorna 405)
curl --request POST \
  --url "https://api.bempaggo.io/api/v2/sellers/786/customers" \
  --header "authorization: Bearer SEU_TOKEN" \
  --data '...'
```

### Exemplo 3: Listar Faturas (CORRETO)

```bash
# ✅ CORRETO
curl --request GET \
  --url "https://api.bempaggo.io/api/v2/invoices?page=0&size=20" \
  --header "authorization: Bearer SEU_TOKEN"

# ❌ ERRADO (retorna 405)
curl --request GET \
  --url "https://api.bempaggo.io/api/v2/sellers/786/invoices?page=0&size=20" \
  --header "authorization: Bearer SEU_TOKEN"
```

---

## 🎯 Conclusão

**A API BemPaggo funciona, mas NÃO use o padrão `/sellers/{id}/` mostrado na documentação.**

Use sempre:
- ✅ `/api/v2/customers`
- ✅ `/api/v2/products`
- ✅ `/api/v2/invoices`
- ✅ `/api/v2/charges`

**Aplicação está 100% funcional** usando estes endpoints corretos!

🔗 **Demo:** https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai

---

**Última atualização:** 26/02/2026  
**Token testado:** Válido até 2099  
**Status:** Todos os endpoints testados e documentados
