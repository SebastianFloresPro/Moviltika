// routes/busqueda.js
const express = require('express');
const router = express.Router();
const { db } = require('../config/database');

router.get('/mascotas', (req, res) => {
  console.log('✅ Ruta /busqueda/mascotas accedida');
  console.log('📥 Query recibida:', req.query);

  let termino = req.query.q;

  if (typeof termino === 'string') {
    termino = decodeURIComponent(termino.trim().toLowerCase());
  } else {
    termino = '';
  }

  if (!termino) {
    console.log('❌ Falta parámetro término o es vacío');
    return res.status(400).json({
      success: false,
      message: 'Debe proporcionar un término para buscar'
    });
  }

  const like = `%${termino}%`;

  const sql = `
    SELECT mascota.*, centrosdeadopcion.nombrecentro 
    FROM mascota 
    JOIN centrosdeadopcion ON mascota.idcentro = centrosdeadopcion.idcentro
    WHERE LOWER(mascota.nombre) LIKE ? OR LOWER(mascota.especie) LIKE ?
  `;

  db.query(sql, [like, like], (err, results) => {
    if (err) {
      console.error('🔴 Error en la búsqueda:', err);
      return res.status(500).json({
        success: false,
        message: 'Error al buscar mascotas'
      });
    }

    console.log(`✅ Mascotas encontradas: ${results.length}`);
    res.json({ success: true, mascotas: results });
  });
});

module.exports = router;
