#!/bin/bash
# Script de teste da API DeltaPag via proxy

echo "========================================="
echo "🧪 Testando API DeltaPag via Proxy"
echo "========================================="
echo ""

echo "1️⃣ Health Check do Proxy..."
curl -s http://localhost:5001/health | python3 -m json.tool
echo ""

echo "2️⃣ Testando listagem de faturas (invoices)..."
curl -s "http://localhost:5001/api/v2/invoices?page=0&size=5" -H "Content-Type: application/json" 2>&1
echo ""
echo ""

echo "3️⃣ Testando consulta de cliente (customer check)..."
curl -s "http://localhost:5001/api/v2/customers/document/12345678901/check" -H "Content-Type: application/json"
echo ""
echo ""

echo "========================================="
echo "✅ Testes concluídos"
echo "========================================="
