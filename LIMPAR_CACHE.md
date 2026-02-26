# 🔄 Como Limpar o Cache do Navegador

## ❌ Problema: App mostra dados antigos ou erro "localhost:8080"

O navegador pode estar usando uma **versão em cache** do app Flutter. 

## ✅ Solução: Hard Refresh (Recarregar sem cache)

### **Google Chrome / Edge:**
1. Pressione **Ctrl + Shift + R** (Windows/Linux)
2. Ou **Cmd + Shift + R** (Mac)
3. Ou clique com botão direito no ícone de recarregar e selecione "Recarregar sem cache"

### **Firefox:**
1. Pressione **Ctrl + F5** (Windows/Linux)
2. Ou **Cmd + Shift + R** (Mac)

### **Safari (Mac):**
1. Pressione **Cmd + Option + R**
2. Ou vá em Develop → Empty Caches

### **Método Alternativo (todos navegadores):**
1. Abra as **Ferramentas de Desenvolvedor** (F12)
2. Clique com botão direito no ícone de recarregar
3. Selecione **"Limpar cache e recarregar forçado"**

## 🧹 Limpeza Completa (se o problema persistir):

### **Chrome DevTools:**
```
1. Pressione F12
2. Vá em "Application" (Aplicação)
3. Clique em "Clear storage" (Limpar armazenamento)
4. Marque "Unregister service workers"
5. Clique "Clear site data"
6. Recarregue a página (F5)
```

### **Firefox DevTools:**
```
1. Pressione F12
2. Vá em "Storage" (Armazenamento)
3. Clique com botão direito em "Service Workers"
4. Selecione "Unregister" (Cancelar registro)
5. Limpe os dados do site
6. Recarregue a página (F5)
```

---

## 🚀 Após Limpar Cache:

O app deve:
- ✅ Carregar sem erros de "localhost:8080"
- ✅ Mostrar dados reais da API DeltaPag
- ✅ Dashboard com métricas atualizadas
- ✅ Faturas, Cobranças e Clientes funcionando

---

## 🔗 URL Atual do App:

**https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai**

---

## ❓ Ainda com Problema?

Verifique:
1. O servidor está rodando? `curl http://localhost:5060/health`
2. A API está acessível? `curl http://localhost:5060/api/v2/invoices?page=0&size=1`
3. Console do navegador mostra erros? (F12 → Console)
