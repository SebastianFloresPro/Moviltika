// routes/busqueda.js
const express = require('express');
const router = express.Router();
const { db } = require('../config/database');

router.get('/mascotas', (req, res) => {
  console.log('📥 Accediendo a /busqueda/mascotas');
  console.log('🔎 Query recibida:', req.query);

  const terminoRaw = req.query.q;

  // Verificación segura del término
  if (typeof terminoRaw !== 'string' || !terminoRaw.trim()) {
    console.log('❌ Término inválido:', terminoRaw);
    return res.status(400).json({
      success: false,
      message: 'Debe proporcionar un término para buscar'
    });
  }

  const termino = terminoRaw.trim().toLowerCase();
  const like = `%${termino}%`;

  const sql = `
    SELECT mascota.*, centrosdeadopcion.nombrecentro 
    FROM mascota 
    JOIN centrosdeadopcion ON mascota.idcentro = centrosdeadopcion.idcentro
    WHERE LOWER(mascota.nombre) LIKE ? OR LOWER(mascota.especie) LIKE ?
  `;

  db.query(sql, [like, like], (err, results) => {
    if (err) {
      console.error('🔴 Error en consulta:', err);
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

