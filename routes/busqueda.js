// routes/busqueda.js
const express = require('express');
const router = express.Router();
const { db } = require('../config/database');

router.get('/mascotas', (req, res) => {
  console.log('✅ Ruta /busqueda/mascotas accedida');

  const terminoRaw = req.query.q;
  console.log('📥 Término crudo recibido:', terminoRaw);

  // Manejo robusto del término
  let termino = '';
  if (typeof terminoRaw === 'string') {
    termino = decodeURIComponent(terminoRaw).trim().toLowerCase();
  }

  if (!termino || termino.length === 0) {
    console.log('❌ Término vacío después de limpiar');
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
      console.error('🔴 Error en la consulta SQL:', err);
      return res.status(500).json({
        success: false,
        message: 'Error al buscar mascotas'
      });
    }

    console.log(`✅ Resultados encontrados: ${results.length}`);
    res.json({ success: true, mascotas: results });
  });
});

module.exports = router;

