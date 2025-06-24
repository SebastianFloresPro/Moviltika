const express = require('express');
const router = express.Router();
const { db } = require('../config/database');

router.get('/mascotas/:termino', (req, res) => {
  const termino = req.params.termino;

  console.log('📥 Término recibido desde ruta:', termino);

  if (!termino || !termino.trim()) {
    return res.status(400).json({
      success: false,
      message: 'Debe proporcionar un término para buscar'
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

    console.log(`✅ Resultados encontrados: ${results.length}`);
    res.json({ success: true, mascotas: results });
  });
});

module.exports = router;
