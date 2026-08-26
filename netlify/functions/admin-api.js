const crypto = require('crypto');

function json(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    },
    body: JSON.stringify(body),
  };
}

function b64url(input) {
  return Buffer.from(input)
    .toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

function signToken(payload, secret) {
  const header = b64url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const body = b64url(JSON.stringify(payload));
  const data = `${header}.${body}`;
  const sig = crypto.createHmac('sha256', secret).update(data).digest('base64url');
  return `${data}.${sig}`;
}

function verifyToken(token, secret) {
  if (!token) return null;
  const parts = token.split('.');
  if (parts.length !== 3) return null;
  const [header, body, sig] = parts;
  const data = `${header}.${body}`;
  const expected = crypto.createHmac('sha256', secret).update(data).digest('base64url');
  if (sig !== expected) return null;
  try {
    const payload = JSON.parse(Buffer.from(body.replace(/-/g, '+').replace(/_/g, '/'), 'base64').toString());
    if (payload.exp && Date.now() / 1000 > payload.exp) return null;
    return payload;
  } catch {
    return null;
  }
}

function getSecrets() {
  const adminUser = process.env.ADMIN_USERNAME || 'admin';
  const adminPass = process.env.ADMIN_PASSWORD || 'Voltify@2026';
  const sessionSecret = process.env.ADMIN_SESSION_SECRET || 'voltify-admin-session-secret';
  const supabaseUrl = process.env.SUPABASE_URL || 'https://rrrlkvcfxykyhscrswzi.supabase.co';
  const serviceRole = process.env.SUPABASE_SERVICE_ROLE_KEY;
  return { adminUser, adminPass, sessionSecret, supabaseUrl, serviceRole };
}

function requireAuth(event) {
  const { sessionSecret } = getSecrets();
  const header = event.headers.authorization || event.headers.Authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : '';
  return verifyToken(token, sessionSecret);
}

async function supabaseRequest(path, { method = 'GET', body, prefer } = {}) {
  const { supabaseUrl, serviceRole } = getSecrets();
  if (!serviceRole) {
    const err = new Error('SUPABASE_SERVICE_ROLE_KEY manquante sur Netlify');
    err.statusCode = 500;
    throw err;
  }
  const headers = {
    apikey: serviceRole,
    Authorization: `Bearer ${serviceRole}`,
    'Content-Type': 'application/json',
  };
  if (prefer) headers.Prefer = prefer;
  const res = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  let data = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = text;
  }
  if (!res.ok) {
    const err = new Error((data && data.message) || text || `Supabase ${res.status}`);
    err.statusCode = res.status;
    err.details = data;
    throw err;
  }
  return data;
}

exports.handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') {
    return json(200, { ok: true });
  }

  try {
    const qs = event.queryStringParameters || {};
    const action = qs.action || 'login';

    if (action === 'login' && event.httpMethod === 'POST') {
      const { adminUser, adminPass, sessionSecret } = getSecrets();
      const body = JSON.parse(event.body || '{}');
      const username = String(body.username || '').trim();
      const password = String(body.password || '');
      if (username !== adminUser || password !== adminPass) {
        return json(401, { error: 'Identifiant ou mot de passe incorrect' });
      }
      const token = signToken(
        {
          sub: username,
          role: 'admin',
          exp: Math.floor(Date.now() / 1000) + 60 * 60 * 12,
        },
        sessionSecret,
      );
      return json(200, { token, username });
    }

    const auth = requireAuth(event);
    if (!auth) return json(401, { error: 'Session expirée. Reconnectez-vous.' });

    if (action === 'products' && event.httpMethod === 'GET') {
      const data = await supabaseRequest('products?select=*&order=name.asc');
      return json(200, { data });
    }

    if (action === 'products' && event.httpMethod === 'POST') {
      const payload = JSON.parse(event.body || '{}');
      const data = await supabaseRequest('products', {
        method: 'POST',
        body: payload,
        prefer: 'resolution=merge-duplicates,return=representation',
      });
      return json(200, { data });
    }

    if (action === 'products' && event.httpMethod === 'DELETE') {
      const id = qs.id;
      if (!id) return json(400, { error: 'id requis' });
      await supabaseRequest(`products?id=eq.${encodeURIComponent(id)}`, { method: 'DELETE' });
      return json(200, { ok: true });
    }

    if (action === 'orders' && event.httpMethod === 'GET') {
      const data = await supabaseRequest(
        'orders?select=*&order=created_at.desc&limit=100',
      );
      return json(200, { data });
    }

    if (action === 'pickup' && event.httpMethod === 'GET') {
      const data = await supabaseRequest('pickup_points?select=*&order=city.asc');
      return json(200, { data });
    }

    return json(404, { error: 'Action inconnue' });
  } catch (e) {
    return json(e.statusCode || 500, {
      error: e.message || 'Erreur serveur',
      details: e.details || null,
    });
  }
};
