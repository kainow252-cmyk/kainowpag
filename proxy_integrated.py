#!/usr/bin/env python3
"""
Proxy Integrado - Serve Flutter Web + Proxy API
Resolve problema de Mixed Content servindo tudo pelo mesmo domínio
"""

from flask import Flask, request, Response, send_from_directory
from flask_cors import CORS
import requests
import os

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Configuração
FLUTTER_BUILD_DIR = "/home/user/flutter_app/build/web"
# ⚠️ IMPORTANTE: Usar API correta - DeltaPag (não BemPaggo)
API_BASE_URL = "https://api.deltapag.io/api/v2"
# Token DeltaPag (mesmo token - compatível com ambas APIs)
TOKEN = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI3ODYiLCJ0ZW5hbnQiOiJiZW1wYWdnb19rYWlub3dwcm9tb2Nhb2RldmVuXzJfMjc5MjM3NDYwMDAxMjMiLCJpYXQiOjE3NzIwOTY5NDIsImV4cCI6NDEwMjM1ODM5OSwiaXNNYXN0ZXIiOnRydWV9.gjqYDIeIQPln2SMzxVCsFhSKLNrkSmmZ-TX3EypJOsF_t_Iofy_kLVFOAgqD8LKVzgSMidVFOZX_l2ILaRKhPw"

def get_api_headers():
    return {
        'Authorization': f'Bearer {TOKEN}',
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }

# API Proxy Routes
@app.route('/api/v2/<path:endpoint>', methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'])
def api_proxy(endpoint):
    """Proxy para API Bempaggo"""
    
    # Handle CORS preflight
    if request.method == 'OPTIONS':
        response = Response()
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        return response
    
    # Construir URL
    url = f"{API_BASE_URL}/{endpoint}"
    if request.query_string:
        url += f"?{request.query_string.decode('utf-8')}"
    
    print(f"[API PROXY] {request.method} {url}")
    
    try:
        # Fazer requisição
        if request.method == 'GET':
            api_response = requests.get(url, headers=get_api_headers(), timeout=30)
        elif request.method == 'POST':
            data = request.get_json() if request.is_json else None
            api_response = requests.post(url, json=data, headers=get_api_headers(), timeout=30)
        elif request.method == 'PUT':
            data = request.get_json() if request.is_json else None
            api_response = requests.put(url, json=data, headers=get_api_headers(), timeout=30)
        elif request.method == 'DELETE':
            api_response = requests.delete(url, headers=get_api_headers(), timeout=30)
        
        # Retornar resposta
        response = Response(
            api_response.content,
            status=api_response.status_code,
            headers={
                'Content-Type': api_response.headers.get('Content-Type', 'application/json'),
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            }
        )
        return response
        
    except Exception as e:
        print(f"[ERROR] {str(e)}")
        return Response(f'{{"error": "{str(e)}"}}', status=500, mimetype='application/json')

# Health check
@app.route('/health')
def health():
    return {'status': 'ok', 'service': 'Flutter + API Proxy', 'api_base': API_BASE_URL}

# Gerar Link de Checkout
@app.route('/api/generate-checkout-link/<product_id>', methods=['GET'])
def generate_checkout_link(product_id):
    """
    Gera link de checkout para um produto específico
    
    Exemplo: GET /api/generate-checkout-link/1
    Retorna: {
        "product_id": "1",
        "checkout_url": "https://5060-irjnby5ff1796hp64gl7e-d0b9e1e2.sandbox.novita.ai/checkout/1",
        "short_url": "/checkout/1",
        "status": "success"
    }
    """
    try:
        # Obter informações do produto da API DeltaPag
        product_url = f"{API_BASE_URL}/products/{product_id}"
        print(f"[CHECKOUT LINK] Fetching product: {product_url}")
        
        product_response = requests.get(product_url, headers=get_api_headers(), timeout=10)
        
        if product_response.status_code == 200:
            product_data = product_response.json()
            
            # Obter host do request
            host = request.host
            scheme = request.scheme
            
            # Gerar link completo
            checkout_url = f"{scheme}://{host}/checkout/{product_id}"
            
            response_data = {
                "status": "success",
                "product_id": product_id,
                "product_name": product_data.get('name'),
                "product_value": product_data.get('value'),
                "checkout_url": checkout_url,
                "short_url": f"/checkout/{product_id}",
                "message": "Link de checkout gerado com sucesso"
            }
            
            print(f"[CHECKOUT LINK] Generated: {checkout_url}")
            return response_data, 200
            
        elif product_response.status_code == 404:
            return {
                "status": "error",
                "message": f"Produto com ID {product_id} não encontrado",
                "product_id": product_id
            }, 404
            
        else:
            return {
                "status": "error",
                "message": f"Erro ao buscar produto: {product_response.status_code}",
                "product_id": product_id
            }, product_response.status_code
            
    except Exception as e:
        print(f"[ERROR] Generate checkout link: {str(e)}")
        return {
            "status": "error",
            "message": str(e),
            "product_id": product_id
        }, 500

# Gerar múltiplos links de checkout
@app.route('/api/generate-checkout-links', methods=['POST'])
def generate_multiple_checkout_links():
    """
    Gera múltiplos links de checkout
    
    Body: {
        "product_ids": [1, 2, 3]
    }
    
    Retorna: {
        "status": "success",
        "links": [
            {"product_id": "1", "checkout_url": "...", ...},
            {"product_id": "2", "checkout_url": "...", ...}
        ]
    }
    """
    try:
        data = request.get_json()
        product_ids = data.get('product_ids', [])
        
        if not product_ids:
            return {
                "status": "error",
                "message": "Lista de product_ids vazia"
            }, 400
        
        links = []
        errors = []
        
        for product_id in product_ids:
            try:
                # Obter informações do produto
                product_url = f"{API_BASE_URL}/products/{product_id}"
                product_response = requests.get(product_url, headers=get_api_headers(), timeout=10)
                
                if product_response.status_code == 200:
                    product_data = product_response.json()
                    
                    # Gerar link
                    host = request.host
                    scheme = request.scheme
                    checkout_url = f"{scheme}://{host}/checkout/{product_id}"
                    
                    links.append({
                        "product_id": str(product_id),
                        "product_name": product_data.get('name'),
                        "product_value": product_data.get('value'),
                        "checkout_url": checkout_url,
                        "short_url": f"/checkout/{product_id}"
                    })
                else:
                    errors.append({
                        "product_id": str(product_id),
                        "error": f"Produto não encontrado ou erro {product_response.status_code}"
                    })
                    
            except Exception as e:
                errors.append({
                    "product_id": str(product_id),
                    "error": str(e)
                })
        
        return {
            "status": "success",
            "total_requested": len(product_ids),
            "total_generated": len(links),
            "total_errors": len(errors),
            "links": links,
            "errors": errors if errors else None
        }, 200
        
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }, 500

# Flutter Web Routes (devem vir DEPOIS das rotas de API)
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve_flutter(path):
    """Serve arquivos do Flutter Web com suporte a deep links"""
    
    # Lista de extensões de arquivo estático
    static_extensions = ['.js', '.css', '.png', '.jpg', '.jpeg', '.svg', '.ico', '.woff', '.woff2', '.ttf', '.otf', '.json', '.txt']
    
    # Verifica se é um arquivo estático
    is_static_file = any(path.endswith(ext) for ext in static_extensions)
    
    if is_static_file:
        # Tenta servir arquivo estático
        file_path = os.path.join(FLUTTER_BUILD_DIR, path)
        if os.path.exists(file_path) and os.path.isfile(file_path):
            response = send_from_directory(FLUTTER_BUILD_DIR, path)
            # Cache para arquivos estáticos
            response.headers['Cache-Control'] = 'public, max-age=31536000'
            return response
    
    # Para todas as rotas do app (/, /checkout/1, etc), serve index.html
    # Isso permite que o go_router do Flutter gerencie a navegação
    response = send_from_directory(FLUTTER_BUILD_DIR, 'index.html')
    
    # Headers para prevenir cache do index.html (facilita hot reload)
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    
    return response

if __name__ == '__main__':
    print("=" * 70)
    print("🚀 Payment Master - Flutter Web + API Proxy Server")
    print("=" * 70)
    print(f"📁 Flutter Build: {FLUTTER_BUILD_DIR}")
    print(f"🌐 API Base URL: {API_BASE_URL}")
    print(f"🔗 Server: http://0.0.0.0:5060")
    print(f"📡 API Proxy: http://localhost:5060/api/v2/...")
    print("")
    print("💡 Para limpar cache do navegador:")
    print("   Chrome: Ctrl+Shift+R (hard refresh)")
    print("   Firefox: Ctrl+F5")
    print("=" * 70)
    app.run(host='0.0.0.0', port=5060, debug=False, threaded=True)
