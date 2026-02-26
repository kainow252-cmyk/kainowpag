# Solução CORS - Payment Master

## 🔍 Problema Identificado

O Flutter web não conseguia acessar diretamente a API Bempaggo (`https://api.bempaggo.io`) devido a restrições de **CORS (Cross-Origin Resource Sharing)**:

```
net::ERR_FAILED
TypeError: Failed to fetch
The FetchEvent for "https://api.bempaggo.io/api/v2/invoices?page=0&size=100" resulted in a network error
```

### Por que isso acontece?

- **Navegadores bloqueiam requisições entre domínios diferentes** por segurança
- Flutter web (localhost/sandbox) → API Bempaggo (api.bempaggo.io) = **domínios diferentes**
- A API Bempaggo não tem headers CORS configurados para permitir acesso externo

---

## ✅ Solução Implementada

**Proxy Local CORS** - Servidor intermediário que:
1. Recebe requisições do Flutter web (sem CORS)
2. Encaminha para a API Bempaggo com autenticação
3. Retorna resposta com headers CORS habilitados

### Arquitetura

```
┌─────────────┐     HTTP      ┌─────────────┐    HTTPS    ┌──────────────┐
│ Flutter Web │──────────────>│ Proxy CORS  │────────────>│ API Bempaggo │
│ :5060       │  (localhost)  │ :8080       │ (c/ token)  │ (produção)   │
└─────────────┘               └─────────────┘             └──────────────┘
```

---

## 📁 Arquivos Criados

### 1. `proxy_bempaggo.py`
Servidor Flask que atua como proxy CORS:
- **Porta**: 8080
- **Função**: Intermediar requisições entre Flutter e API
- **Tecnologias**: Flask, Flask-CORS, Requests

### 2. `start_services.sh`
Script de inicialização automática dos serviços:
- Para serviços antigos (portas 5060 e 8080)
- Inicia Proxy Bempaggo
- Inicia Flutter Web Server
- Exibe status e URLs

### 3. Alteração em `lib/services/deltapag_api.dart`
```dart
// ANTES (não funcionava)
static const String baseUrl = 'https://api.bempaggo.io/api/v2';

// DEPOIS (funciona via proxy)
static const String baseUrl = 'http://localhost:8080/api/v2';
```

---

## 🚀 Como Usar

### Inicialização Automática
```bash
cd /home/user/flutter_app
./start_services.sh
```

### Inicialização Manual

**1. Iniciar Proxy:**
```bash
cd /home/user/flutter_app
nohup python3 proxy_bempaggo.py > proxy.log 2>&1 &
```

**2. Iniciar Flutter:**
```bash
cd /home/user/flutter_app/build/web
nohup python3 -m http.server 5060 --bind 0.0.0.0 > /tmp/flutter_server.log 2>&1 &
```

**3. Verificar Status:**
```bash
lsof -i :5060  # Flutter Web Server
lsof -i :8080  # Proxy Bempaggo
```

---

## 🔧 Endpoints e Portas

| Serviço | Porta | URL | Função |
|---------|-------|-----|--------|
| **Flutter Web** | 5060 | https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai | Aplicação principal |
| **Proxy Bempaggo** | 8080 | http://localhost:8080 | Intermediário CORS |
| **API Bempaggo** | 443 | https://api.bempaggo.io/api/v2 | API de produção |

---

## 📊 Logs

- **Proxy Bempaggo**: `/home/user/flutter_app/proxy.log`
- **Flutter Server**: `/tmp/flutter_server.log`

### Ver logs em tempo real:
```bash
tail -f /home/user/flutter_app/proxy.log
tail -f /tmp/flutter_server.log
```

---

## 🛑 Parar Serviços

```bash
# Parar todos os serviços
lsof -ti:5060 | xargs kill -9  # Flutter
lsof -ti:8080 | xargs kill -9  # Proxy
```

---

## ✅ Verificação de Funcionamento

### 1. Testar Proxy
```bash
curl http://localhost:8080/health
```

**Resposta esperada:**
```json
{
  "status": "ok",
  "service": "Bempaggo CORS Proxy",
  "api_base": "https://api.bempaggo.io/api/v2"
}
```

### 2. Testar API via Proxy
```bash
curl "http://localhost:8080/api/v2/invoices?page=0&size=1"
```

**Deve retornar:** JSON com dados reais de faturas

### 3. Testar Flutter
Acesse: https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai
- Dashboard deve carregar com dados reais
- Faturas devem aparecer
- Clientes devem aparecer

---

## 🔐 Segurança

**Token de Autenticação** está hardcoded no `proxy_bempaggo.py`:
```python
TOKEN = "eyJhbGciOiJIUzUxMiJ9..."
```

**⚠️ Para produção:**
- Mover token para variável de ambiente
- Usar HTTPS no proxy
- Implementar rate limiting
- Adicionar logs de auditoria

---

## 🐛 Troubleshooting

### Problema: "Connection Refused" no Flutter

**Causa:** Proxy não está rodando

**Solução:**
```bash
cd /home/user/flutter_app
python3 proxy_bempaggo.py
```

### Problema: "Failed to fetch" continua aparecendo

**Causa:** Flutter ainda apontando para API direta

**Solução:**
1. Verificar `lib/services/deltapag_api.dart`
2. Confirmar `baseUrl = 'http://localhost:8080/api/v2'`
3. Rebuild: `flutter build web --release`

### Problema: Dados não aparecem

**Causa:** Proxy retornando erro 500

**Solução:**
1. Ver logs: `tail -f /home/user/flutter_app/proxy.log`
2. Verificar se token é válido
3. Testar API diretamente:
   ```bash
   curl -H "Authorization: Bearer TOKEN" https://api.bempaggo.io/api/v2/invoices
   ```

---

## 📈 Melhorias Futuras

- [ ] Cache de requisições no proxy
- [ ] Retry automático em caso de falha
- [ ] Métricas e monitoramento
- [ ] Configuração via arquivo .env
- [ ] Docker container para o proxy
- [ ] Load balancing se necessário

---

## 📞 Suporte

**Logs importantes para debug:**
```bash
# Ver requisições do proxy
tail -f /home/user/flutter_app/proxy.log

# Ver erros do Flutter
tail -f /tmp/flutter_server.log

# Ver status dos processos
ps aux | grep -E "(proxy|python3.*5060)"
```

**Restart completo:**
```bash
cd /home/user/flutter_app
./start_services.sh
```

---

## ✅ Status Atual

- ✅ Proxy CORS funcionando
- ✅ Flutter web conectando via proxy
- ✅ Dados reais carregando
- ✅ Dashboard com métricas
- ✅ Faturas listadas
- ✅ Clientes carregados
- ✅ Webhooks configurados
- ✅ Todas funcionalidades operacionais

**Sistema 100% funcional!** 🎉
