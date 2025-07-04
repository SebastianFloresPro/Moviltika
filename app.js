require('dotenv').config();

const express = require('express');
const session = require('express-session');
const path = require('path');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const SequelizeStore = require('connect-session-sequelize')(session.Store);
const { db, sequelize } = require('./config/database');

const app = express();
const port = process.env.PORT || 3000;

// --- CONFIGURACIÓN DE CORS ---
const allowedOrigins = [
  'http://localhost:3000',
  'https://tikapawdbp-48n3.onrender.com', // ejemplo de frontend
  'https://moviltika-production.up.railway.app', // Railway backend para Flutter
  undefined // 👈 APKs y Postman no envían origin
];

app.use(cors({
  origin: function(origin, callback) {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('CORS no permitido para el origen: ' + origin));
    }
  },
  credentials: true
}));

app.use((req, res, next) => {
  const origin = req.headers.origin;
  if (allowedOrigins.includes(origin)) {
    res.header('Access-Control-Allow-Origin', origin);
  }
  res.header('Access-Control-Allow-Credentials', 'true');
  res.header('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type,Authorization,Accept,X-Requested-With');

  if (req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }

  next();
});

// --- CONFIGURACIONES BÁSICAS ---
app.set('trust proxy', 1); // Necesario en producción (Railway, Render)

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'views')));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// --- SESIONES ---
const sessionStore = new SequelizeStore({
  db: sequelize,
  tableName: 'sessions',
  checkExpirationInterval: 15 * 60 * 1000,
  expiration: 7 * 24 * 60 * 60 * 1000
});

const isProduction = process.env.NODE_ENV === 'production';

app.use(session({
  secret: process.env.SESSION_SECRET || '91119adbb9f0f692a5838d138883bd53',
  store: sessionStore,
  resave: false,
  saveUninitialized: false,
  proxy: true,
  cookie: {
    secure: isProduction,               // ✅ TRUE solo en Railway con HTTPS
    httpOnly: true,
    sameSite: isProduction ? 'none' : 'lax',  // ✅ 'none' si es HTTPS
    maxAge: 7 * 24 * 60 * 60 * 1000
  }
}));

sessionStore.sync();

// --- LOG de sesión y cookies ---
app.use((req, res, next) => {
  console.log('📥 Headers:', req.headers);
  console.log('🔐 Cookie recibida:', req.headers.cookie);
  console.log('🧠 Sesión:', {
    userId: req.session.userId,
    tipo: req.session.tipo,
    cookie: req.session.cookie
  });
  next();
});

// --- RUTAS ---
app.use('/', require('./routes/index'));
app.use('/usuarios', require('./routes/usuarios'));
app.use('/refugios', require('./routes/refugios'));
app.use('/mascotas', require('./routes/mascotas'));
app.use('/solicitudes', require('./routes/solicitudes'));
app.use('/busqueda', require('./routes/busqueda'));

// --- MANEJO DE ERRORES CORS ---
app.use((err, req, res, next) => {
  if (err && err.message && err.message.includes('CORS')) {
    console.error('🚫 Error de CORS:', err.message);
    return res.status(403).json({ error: err.message });
  }
  next(err);
});

// --- INICIO DEL SERVIDOR ---
app.listen(port, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${port}`);
});

