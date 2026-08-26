const STORAGE_KEY = 'voltify_admin_session';

const loginView = document.getElementById('login-view');
const appView = document.getElementById('app-view');
const loginError = document.getElementById('login-error');
const formError = document.getElementById('form-error');
const dialog = document.getElementById('product-dialog');
const form = document.getElementById('product-form');

let supabase = null;
let products = [];
let currentView = 'products';

function money(n) {
  return new Intl.NumberFormat('fr-FR').format(Number(n || 0)) + ' FCFA';
}

function categoryLabel(id) {
  return ({
    smartphones: 'Smartphones',
    ordinateurs: 'Ordinateurs',
    tv: 'TV & Vidéo',
    audio: 'Audio',
    accessoires: 'Accessoires',
    eclairage: 'Éclairage LED',
    electromenager: 'Électroménager',
  })[id] || id;
}

function showError(el, msg) {
  el.hidden = !msg;
  el.textContent = msg || '';
}

function getSession() {
  try {
    return JSON.parse(sessionStorage.getItem(STORAGE_KEY) || 'null');
  } catch {
    return null;
  }
}

function saveSession(url, key) {
  sessionStorage.setItem(STORAGE_KEY, JSON.stringify({ url, key }));
}

function clearSession() {
  sessionStorage.removeItem(STORAGE_KEY);
}

function createClient(url, key) {
  return window.supabase.createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

async function connect(url, key) {
  supabase = createClient(url, key);
  const { error } = await supabase.from('products').select('id').limit(1);
  if (error) throw error;
  saveSession(url, key);
  loginView.hidden = true;
  appView.hidden = false;
  await refreshAll();
}

document.getElementById('btn-login').addEventListener('click', async () => {
  showError(loginError, '');
  const url = document.getElementById('sb-url').value.trim();
  const key = document.getElementById('sb-key').value.trim();
  if (!url || !key) {
    showError(loginError, 'URL et clé service_role requis.');
    return;
  }
  try {
    await connect(url, key);
  } catch (e) {
    showError(
      loginError,
      (e && e.message) ||
        'Connexion impossible. Vérifiez la clé et que les tables existent (docs/supabase_setup_all.sql).',
    );
  }
});

document.getElementById('btn-logout').addEventListener('click', () => {
  clearSession();
  supabase = null;
  appView.hidden = true;
  loginView.hidden = false;
});

document.querySelectorAll('.nav-item').forEach((btn) => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.nav-item').forEach((b) => b.classList.remove('active'));
    btn.classList.add('active');
    currentView = btn.dataset.view;
    document.getElementById('products-view').hidden = currentView !== 'products';
    document.getElementById('orders-view').hidden = currentView !== 'orders';
    document.getElementById('pickup-view').hidden = currentView !== 'pickup';
    document.getElementById('btn-new').hidden = currentView !== 'products';
    document.getElementById('search').hidden = currentView !== 'products';
    const titles = {
      products: ['Produits', 'Catalogue synchronisé avec l’app mobile'],
      orders: ['Commandes', 'Histor des commandes clients'],
      pickup: ['Points de retrait', 'Magasins Voltify'],
    };
    document.getElementById('view-title').textContent = titles[currentView][0];
    document.getElementById('view-sub').textContent = titles[currentView][1];
  });
});

document.getElementById('search').addEventListener('input', () => renderProducts());

document.getElementById('btn-new').addEventListener('click', () => openProductDialog());

document.getElementById('btn-cancel').addEventListener('click', () => dialog.close());

form.addEventListener('submit', async (e) => {
  e.preventDefault();
  showError(formError, '');
  const payload = {
    id: document.getElementById('f-id').value.trim(),
    name: document.getElementById('f-name').value.trim(),
    brand: document.getElementById('f-brand').value.trim(),
    category_id: document.getElementById('f-category').value,
    price: Number(document.getElementById('f-price').value || 0),
    old_price: document.getElementById('f-old-price').value
      ? Number(document.getElementById('f-old-price').value)
      : null,
    badge: document.getElementById('f-badge').value.trim() || null,
    description: document.getElementById('f-description').value.trim(),
    rating: Number(document.getElementById('f-rating').value || 4.5),
    review_count: Number(document.getElementById('f-reviews').value || 0),
    in_stock: document.getElementById('f-stock').checked,
    points_reward: Number(document.getElementById('f-points').value || 50),
    loyalty_track: document.getElementById('f-track').value,
    specs: document
      .getElementById('f-specs')
      .value.split('\n')
      .map((s) => s.trim())
      .filter(Boolean),
  };

  const originalId = document.getElementById('f-id-original').value;
  try {
    if (originalId && originalId !== payload.id) {
      const { error: delErr } = await supabase.from('products').delete().eq('id', originalId);
      if (delErr) throw delErr;
    }
    const { error } = await supabase.from('products').upsert(payload);
    if (error) throw error;
    dialog.close();
    await loadProducts();
  } catch (err) {
    showError(formError, err.message || 'Enregistrement impossible');
  }
});

function openProductDialog(product) {
  showError(formError, '');
  document.getElementById('dialog-title').textContent = product ? 'Modifier le produit' : 'Nouveau produit';
  document.getElementById('f-id-original').value = product?.id || '';
  document.getElementById('f-id').value = product?.id || '';
  document.getElementById('f-id').disabled = false;
  document.getElementById('f-name').value = product?.name || '';
  document.getElementById('f-brand').value = product?.brand || '';
  document.getElementById('f-category').value = product?.category_id || 'smartphones';
  document.getElementById('f-badge').value = product?.badge || '';
  document.getElementById('f-price').value = product?.price ?? '';
  document.getElementById('f-old-price').value = product?.old_price ?? '';
  document.getElementById('f-points').value = product?.points_reward ?? 50;
  document.getElementById('f-rating').value = product?.rating ?? 4.5;
  document.getElementById('f-reviews').value = product?.review_count ?? 0;
  document.getElementById('f-track').value = product?.loyalty_track || 'lumineux';
  document.getElementById('f-description').value = product?.description || '';
  document.getElementById('f-specs').value = Array.isArray(product?.specs) ? product.specs.join('\n') : '';
  document.getElementById('f-stock').checked = product?.in_stock !== false;
  dialog.showModal();
}

async function loadProducts() {
  const { data, error } = await supabase.from('products').select('*').order('name');
  if (error) throw error;
  products = data || [];
  renderProducts();
}

function renderProducts() {
  const q = (document.getElementById('search').value || '').toLowerCase().trim();
  const list = products.filter(
    (p) =>
      !q ||
      p.name.toLowerCase().includes(q) ||
      p.brand.toLowerCase().includes(q) ||
      (p.category_id || '').includes(q),
  );
  const body = document.getElementById('products-body');
  if (!list.length) {
    body.innerHTML = '<tr><td colspan="6" class="muted center">Aucun produit</td></tr>';
    return;
  }
  body.innerHTML = list
    .map(
      (p) => `
      <tr>
        <td>
          <div class="product-name">${escapeHtml(p.name)}</div>
          <div class="product-brand">${escapeHtml(p.brand)} · ${escapeHtml(p.id)}</div>
        </td>
        <td>${escapeHtml(categoryLabel(p.category_id))}</td>
        <td class="price">${money(p.price)}</td>
        <td><span class="badge ${p.in_stock ? '' : 'out'}">${p.in_stock ? 'En stock' : 'Rupture'}</span></td>
        <td>${p.points_reward || 0}</td>
        <td>
          <div class="row-actions">
            <button class="btn ghost small" data-edit="${escapeHtml(p.id)}">Éditer</button>
            <button class="btn danger small" data-del="${escapeHtml(p.id)}">Suppr.</button>
          </div>
        </td>
      </tr>`,
    )
    .join('');

  body.querySelectorAll('[data-edit]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const product = products.find((p) => p.id === btn.dataset.edit);
      if (product) openProductDialog(product);
    });
  });
  body.querySelectorAll('[data-del]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      if (!confirm('Supprimer ce produit ?')) return;
      const { error } = await supabase.from('products').delete().eq('id', btn.dataset.del);
      if (error) {
        alert(error.message);
        return;
      }
      await loadProducts();
    });
  });
}

async function loadOrders() {
  const { data, error } = await supabase
    .from('orders')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(100);
  if (error) throw error;
  const body = document.getElementById('orders-body');
  if (!data?.length) {
    body.innerHTML = '<tr><td colspan="6" class="muted center">Aucune commande</td></tr>';
    return;
  }
  body.innerHTML = data
    .map(
      (o) => `
      <tr>
        <td>${escapeHtml(o.id)}</td>
        <td>
          <div class="product-name">${escapeHtml(o.customer_name || '')}</div>
          <div class="product-brand">${escapeHtml(o.phone || '')}</div>
        </td>
        <td class="price">${money(o.total)}</td>
        <td>${escapeHtml(o.payment_method || '')}</td>
        <td>${o.delivery_mode === 'pickup' ? 'Retrait' : 'Livraison'}</td>
        <td>${o.created_at ? new Date(o.created_at).toLocaleString('fr-FR') : ''}</td>
      </tr>`,
    )
    .join('');
}

async function loadPickup() {
  const { data, error } = await supabase.from('pickup_points').select('*').order('city');
  if (error) throw error;
  const body = document.getElementById('pickup-body');
  if (!data?.length) {
    body.innerHTML = '<tr><td colspan="4" class="muted center">Aucun point de retrait</td></tr>';
    return;
  }
  body.innerHTML = data
    .map(
      (p) => `
      <tr>
        <td class="product-name">${escapeHtml(p.name)}</td>
        <td>${escapeHtml(p.city)}</td>
        <td>${escapeHtml(p.address)}</td>
        <td>${escapeHtml(p.hours)}</td>
      </tr>`,
    )
    .join('');
}

async function refreshAll() {
  await Promise.all([loadProducts(), loadOrders().catch(() => {}), loadPickup().catch(() => {})]);
}

function escapeHtml(str) {
  return String(str ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

(async function boot() {
  const session = getSession();
  if (!session?.url || !session?.key) return;
  document.getElementById('sb-url').value = session.url;
  try {
    await connect(session.url, session.key);
  } catch {
    clearSession();
  }
})();
