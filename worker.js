/**
 * Cloudflare Worker - Proxy CORS para API DeltaPag
 * 
 * Este worker funciona como proxy entre o Flutter Web App e a API DeltaPag,
 * resolvendo problemas de CORS (Cross-Origin Resource Sharing).
 * 
 * Funcionamento:
 * 1. Flutter App faz requisição para: /api/v2/invoices
 * 2. Worker intercepta e redireciona para: https://api.deltapag.io/api/v2/invoices
 * 3. Worker adiciona headers CORS na resposta
 * 4. Flutter App recebe resposta com CORS permitido
 */

const API_BASE_URL = 'https://api.deltapag.io';

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Handler para OPTIONS (CORS preflight)
    if (request.method === 'OPTIONS') {
      return handleOptions(request);
    }
    
    // Handler para /api/generate-checkout-link/:id
    const checkoutLinkMatch = url.pathname.match(/^\/api\/generate-checkout-link\/(\d+)$/);
    if (checkoutLinkMatch) {
      return handleGenerateCheckoutLink(request, url, checkoutLinkMatch[1]);
    }
    
    // Se a URL começa com /api/v2, redirecionar para API DeltaPag
    if (url.pathname.startsWith('/api/v2')) {
      return handleAPIRequest(request, url);
    }
    
    // Caso contrário, retornar erro 404
    return new Response('Not Found', { status: 404 });
  }
};

async function handleAPIRequest(request, url) {
  // Construir URL completa da API
  const apiUrl = API_BASE_URL + url.pathname + url.search;
  
  // Copiar headers da requisição original
  const headers = new Headers(request.headers);
  
  // Fazer requisição para API DeltaPag
  try {
    const apiResponse = await fetch(apiUrl, {
      method: request.method,
      headers: headers,
      body: request.body,
    });
    
    // Copiar resposta da API
    const response = new Response(apiResponse.body, {
      status: apiResponse.status,
      statusText: apiResponse.statusText,
      headers: apiResponse.headers,
    });
    
    // Adicionar headers CORS
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept');
    response.headers.set('Access-Control-Max-Age', '86400');
    
    return response;
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    });
  }
}

// Handler para requisições OPTIONS (CORS preflight)
async function handleOptions(request) {
  return new Response(null, {
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, Accept',
      'Access-Control-Max-Age': '86400',
    },
  });
}

// Handler para /api/generate-checkout-link/:id
async function handleGenerateCheckoutLink(request, url, productId) {
  // Obter o domínio da requisição atual (ex: www.kainowpag.com ou 67e84e37.kainowpag.pages.dev)
  const origin = url.origin; // https://www.kainowpag.com ou https://67e84e37.kainowpag.pages.dev
  
  // Gerar URL completa do checkout
  const checkoutUrl = `${origin}/checkout/${productId}`;
  
  const responseData = {
    success: true,
    checkoutUrl: checkoutUrl,
    productId: productId,
    message: 'Link de checkout gerado com sucesso!',
  };
  
  return new Response(JSON.stringify(responseData), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, Accept',
    },
  });
}
