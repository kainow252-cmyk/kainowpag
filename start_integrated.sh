#!/bin/bash

echo "========================================"
echo "🚀 Payment Master - Inicialização"
echo "========================================"

# Matar processos anteriores
echo "🛑 Parando serviços anteriores..."
lsof -ti:5060 | xargs -r kill -9 2>/dev/null
lsof -ti:8080 | xargs -r kill -9 2>/dev/null
sleep 1

# Iniciar proxy integrado
echo "🚀 Iniciando servidor integrado (Flutter + API Proxy)..."
cd /home/user/flutter_app
python3 proxy_integrated.py > /tmp/integrated_server.log 2>&1 &
PROXY_PID=$!

sleep 3

# Verificar se está rodando
if ps -p $PROXY_PID > /dev/null 2>&1; then
    echo "✅ Servidor integrado iniciado (PID: $PROXY_PID)"
    echo "🌐 Flutter Web: http://localhost:5060"
    echo "📡 API Proxy: http://localhost:5060/api/v2"
    echo "❤️  Health: http://localhost:5060/health"
    echo ""
    echo "📋 Para ver logs:"
    echo "   tail -f /tmp/integrated_server.log"
    echo ""
    echo "🛑 Para parar:"
    echo "   lsof -ti:5060 | xargs kill -9"
else
    echo "❌ Erro ao iniciar servidor"
    echo "📋 Verificar logs: tail /tmp/integrated_server.log"
    exit 1
fi

echo "========================================"
echo "✅ Pronto! Sistema rodando!"
echo "========================================"
