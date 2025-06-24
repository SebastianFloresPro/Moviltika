const express = require('express');
const router = express.Router();
const { db } = require('../config/database');

// Ruta: GET /busqueda/mascotas?q=termino
router.get('/mascotas', (req, res) => {
  let termino = req.query.q;

  // Validar y limpiar término
  if (typeof termino === 'string') {
    termino = decodeURIComponent(termino.trim().toLowerCase());
  } else {
    termino = '';
  }

  console.log('🟡 Término recibido para búsqueda:', `"${termino}"`);

  // Validación de término vacío
  if (!termino) {
    console.log('❌ Término vacío o inválido');
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
      console.error('🔴 Error al ejecutar búsqueda SQL:', err);
      return res.status(500).json({
        success: false,
        message: 'Error interno al buscar mascotas'
      });
    }

    console.log(`✅ Mascotas encontradas: ${results.length}`);
    res.json({ success: true, mascotas: results });
  });
});

module.exports = router;

