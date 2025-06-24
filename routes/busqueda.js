// routes/busqueda.js
const express = require('express');
const router = express.Router();
const { db } = require('../config/database');

router.get('/mascotas', (req, res) => {
  const termino = req.query.q;

  console.log('🟡 Término recibido:', termino);

  if (!termino || termino.trim() === '') {
    console.log('❌ Término vacío o nulo');
    return res.status(400).json({
      success: false,
      message: 'Debe enviar un término para la búsqueda'
    });
  }

  const like = `%${termino.toLowerCase()}%`;

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
