const express = require('express');
const router = express.Router();
const { db } = require('../config/database');

// Ruta: GET /busqueda/mascotas?q=nombre
router.get('/mascotas', (req, res) => {
    const termino = req.query.q;

    if (!termino || termino.trim() === '') {
        return res.status(400).json({ success: false, message: 'Debe enviar un término de búsqueda' });
    }

    const likeTerm = `%${termino.toLowerCase()}%`;

    const sql = `
        SELECT mascota.*, centrosdeadopcion.nombrecentro
        FROM mascota
        JOIN centrosdeadopcion ON mascota.idcentro = centrosdeadopcion.idcentro
        WHERE LOWER(mascota.nombre) LIKE ? OR LOWER(mascota.especie) LIKE ?
    `;

    db.query(sql, [likeTerm, likeTerm], (err, results) => {
        if (err) {
            console.error('❌ Error en búsqueda de mascotas:', err);
            return res.status(500).json({ success: false, message: 'Error en la búsqueda' });
        }

        return res.json({ success: true, mascotas: results });
    });
});

module.exports = router;

