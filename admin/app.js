const STORAGE_KEY = 'voltify_admin_token';
const API = '/.netlify/functions/admin-api';

const loginView = document.getElementById('login-view');
const appView = document.getElementById('app-view');
const loginError = document.getElementById('login-error');
const formError = document.getElementById('form-error');
const dialog = document.getElementById('product-dialog');
const form = document.getElementById('product-form');

let token = sessionStorage.getItem(STORAGE_KEY) || '';
let products = [];
let currentView = 'products';

function money(n) {
  return new Intl.NumberFormat('fr-FR').format(Number(n || 0)) + ' FCFA';
}

// Doit rester aligné sur lib/data/mock/catalog_taxonomy.dart : un produit rangé
// dans un rayon absent de l'app n'apparaît nulle part en boutique.
// `devis: true` = rayon sur mesure, sans prix ferme.
const TAXONOMY = [
  { id: 'deco_interieure', label: 'Décoration intérieure', children: [
    { id: 'revetements_muraux', label: 'Revêtements muraux' },
    { id: 'plafonds', label: 'Plafonds', devis: true },
    { id: 'eclairage_deco', label: 'Éclairage décoratif' },
    { id: 'sols', label: 'Sols' },
    { id: 'mur_tv', label: 'Décoration TV / mur TV', devis: true },
    { id: 'miroiterie', label: 'Miroiterie et verre' },
    { id: 'ameublement', label: 'Décoration et ameublement' },
  ]},
  { id: 'deco_exterieure', label: 'Décoration extérieure', children: [
    { id: 'facades', label: 'Façades', devis: true },
    { id: 'terrasses', label: 'Terrasses', devis: true },
    { id: 'jardins', label: 'Jardins' },
    { id: 'eclairage_exterieur', label: 'Éclairage extérieur' },
    { id: 'clotures', label: 'Clôtures et séparation', devis: true },
    { id: 'pergolas', label: 'Pergolas et espaces extérieurs', devis: true },
  ]},
  { id: 'menuiserie', label: 'Menuiserie moderne', children: [
    { id: 'bois_panneaux', label: 'Bois — Panneaux' },
    { id: 'bois_finitions', label: 'Bois — Finitions' },
    { id: 'aluminium', label: 'Menuiserie aluminium', devis: true },
    { id: 'alu_accessoires', label: 'Aluminium — Accessoires' },
    { id: 'metallique', label: 'Menuiserie métallique' },
    { id: 'meubles_mesure', label: 'Meubles sur mesure', devis: true },
    { id: 'portes', label: 'Portes modernes', devis: true },
    { id: 'quincaillerie', label: 'Quincaillerie moderne' },
  ]},
  { id: 'enseignes', label: 'Enseignes & signalétique', children: [
    { id: 'enseignes_lumineuses', label: 'Enseignes lumineuses', devis: true },
    { id: 'enseignes_non_lumineuses', label: 'Enseignes non lumineuses', devis: true },
    { id: 'materiaux_enseignes', label: 'Matériaux pour enseignes' },
    { id: 'caissons', label: 'Caissons', devis: true },
    { id: 'signaletique', label: 'Signalétique', devis: true },
  ]},
  { id: 'fabrication', label: 'Fabrication & pose', children: [
    { id: 'outillage_bois', label: 'Travail du bois' },
    { id: 'outillage_metal', label: 'Travail du métal' },
    { id: 'machines_enseignes', label: "Fabrication d'enseignes", devis: true },
    { id: 'outillage_pose', label: 'Pose' },
  ]},
  { id: 'electrique', label: 'Matériel électrique', children: [
    { id: 'led', label: 'LED' },
    { id: 'alimentation', label: 'Alimentation' },
    { id: 'luminaires_techniques', label: 'Luminaires techniques' },
    { id: 'installation', label: 'Installation' },
  ]},
  { id: 'vitrerie', label: 'Vitrerie & verre', children: [
    { id: 'types_verre', label: 'Types de verre' },
    { id: 'applications_verre', label: 'Applications', devis: true },
  ]},
  { id: 'consommables', label: 'Finitions & consommables', children: [
    { id: 'peintures_colles', label: 'Peintures, vernis & colles' },
    { id: 'abrasifs_coupe', label: 'Abrasifs & outils de coupe' },
    { id: 'visserie', label: 'Visserie & fixations' },
    { id: 'adhesifs', label: 'Adhésifs & films' },
  ]},
];

function categoryLabel(id) {
  return TAXONOMY.find((c) => c.id === id)?.label || id;
}

function fillCategorySelects(categoryId, subcategoryId) {
  const catSel = document.getElementById('f-category');
  const subSel = document.getElementById('f-subcategory');
  catSel.innerHTML = TAXONOMY.map((c) => `<option value="${c.id}">${c.label}</option>`).join('');
  const selected = categoryId || TAXONOMY[0].id;
  catSel.value = selected;
  const children = TAXONOMY.find((c) => c.id === selected)?.children || [];
  subSel.innerHTML = children
    .map((s) => `<option value="${s.id}">${s.label}${s.devis ? ' — sur devis' : ''}</option>`)
    .join('');
  if (subcategoryId) subSel.value = subcategoryId;
}

document.getElementById('f-category')?.addEventListener('change', () => {
  fillCategorySelects(document.getElementById('f-category').value);
});

document.getElementById('f-image-file')?.addEventListener('change', async (e) => {
  const file = e.target.files?.[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = async () => {
    const dataUrl = String(reader.result || '');
    const base64 = dataUrl.split(',')[1];
    const preview = document.getElementById('f-image-preview');
    preview.src = dataUrl;
    preview.style.display = 'block';
    try {
      const res = await api('upload', {
        method: 'POST',
        body: { filename: file.name, contentType: file.type, base64 },
      });
      document.getElementById('f-image-url').value = res.url;
    } catch (err) {
      alert(err.message || 'Upload image impossible');
    }
  };
  reader.readAsDataURL(file);
});

function showError(el, msg) {
  el.hidden = !msg;
  el.textContent = msg || '';
}

function escapeHtml(str) {
  return String(str ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

async function api(action, { method = 'GET', body, id } = {}) {
  const url = new URL(API, window.location.origin);
  url.searchParams.set('action', action);
  if (id) url.searchParams.set('id', id);
  const res = await fetch(url.toString(), {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const err = new Error(data.error || `Erreur ${res.status}`);
    err.status = res.status;
    throw err;
  }
  return data;
}

function enterApp(username) {
  document.body.classList.remove('is-login');
  document.body.classList.add('is-app');
  loginView.hidden = true;
  appView.hidden = false;
  document.getElementById('admin-name').textContent = username || 'Administrateur';
}

function logout() {
  token = '';
  sessionStorage.removeItem(STORAGE_KEY);
  document.body.classList.remove('is-app');
  document.body.classList.add('is-login');
  appView.hidden = true;
  loginView.hidden = false;
  document.getElementById('password').value = '';
}

document.getElementById('toggle-password').addEventListener('click', () => {
  const input = document.getElementById('password');
  const btn = document.getElementById('toggle-password');
  const show = input.type === 'password';
  input.type = show ? 'text' : 'password';
  btn.textContent = show ? '🙈' : '👁';
  btn.setAttribute('aria-label', show ? 'Masquer le mot de passe' : 'Afficher le mot de passe');
});

document.getElementById('btn-login').addEventListener('click', async () => {
  showError(loginError, '');
  const username = document.getElementById('username').value.trim();
  const password = document.getElementById('password').value;
  if (!username || !password) {
    showError(loginError, 'Identifiant et mot de passe requis.');
    return;
  }
  try {
    const data = await api('login', { method: 'POST', body: { username, password } });
    token = data.token;
    sessionStorage.setItem(STORAGE_KEY, token);
    enterApp(data.username);
    await refreshAll();
  } catch (e) {
    showError(loginError, e.message || 'Connexion impossible');
  }
});

document.getElementById('password').addEventListener('keydown', (e) => {
  if (e.key === 'Enter') document.getElementById('btn-login').click();
});

document.getElementById('btn-logout').addEventListener('click', logout);

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
    subcategory_id: document.getElementById('f-subcategory').value,
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
    image_url: document.getElementById('f-image-url').value || null,
    specs: document
      .getElementById('f-specs')
      .value.split('\n')
      .map((s) => s.trim())
      .filter(Boolean),
  };

  const originalId = document.getElementById('f-id-original').value;
  try {
    if (originalId && originalId !== payload.id) {
      await api('products', { method: 'DELETE', id: originalId });
    }
    await api('products', { method: 'POST', body: payload });
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
  document.getElementById('f-name').value = product?.name || '';
  document.getElementById('f-brand').value = product?.brand || '';
  fillCategorySelects(product?.category_id || 'deco_interieure', product?.subcategory_id);
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
  document.getElementById('f-image-url').value = product?.image_url || '';
  document.getElementById('f-image-file').value = '';
  const preview = document.getElementById('f-image-preview');
  if (product?.image_url) {
    preview.src = product.image_url;
    preview.style.display = 'block';
  } else {
    preview.removeAttribute('src');
    preview.style.display = 'none';
  }
  dialog.showModal();
}

async function loadProducts() {
  const { data } = await api('products');
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
      try {
        await api('products', { method: 'DELETE', id: btn.dataset.del });
        await loadProducts();
      } catch (e) {
        alert(e.message);
      }
    });
  });
}

async function loadOrders() {
  const { data } = await api('orders');
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
  const { data } = await api('pickup');
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
  await loadProducts();
  await Promise.all([loadOrders().catch(() => {}), loadPickup().catch(() => {})]);
}

(async function boot() {
  document.body.classList.add(token ? 'is-app' : 'is-login');
  if (!token) {
    loginView.hidden = false;
    appView.hidden = true;
    return;
  }
  try {
    enterApp('Administrateur');
    await refreshAll();
  } catch (e) {
    if (e.status === 401) logout();
  }
})();
