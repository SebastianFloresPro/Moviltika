require('dotenv').config();
const mysql = require('mysql2');
const { Sequelize } = require('sequelize');

// Crear pool de conexiones
const dbConnection = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'aliceg',
    database: process.env.DB_DATABASE || 'dbtikapaw',
    port: process.env.DB_PORT ? parseInt(process.env.DB_PORT) : 3306,
    connectionLimit: 10,
});

// Wrapper para usar .query como antes
const db = {
    query: (sql, params, callback) => {
        return dbConnection.query(sql, params, callback);
    }
};

// Sequelize
const sequelize = new Sequelize(
    process.env.DB_DATABASE || 'dbtikapaw',
    process.env.DB_USER || 'root',
    process.env.DB_PASSWORD || 'aliceg',
    {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT ? parseInt(process.env.DB_PORT) : 3306,
        dialect: 'mysql',
        logging: false,
    }
);

// Probar conexión Sequelize
sequelize.authenticate()
    .then(() => console.log('Conexión a la base de datos con Sequelize establecida correctamente'))
    .catch(err => console.error('Error al conectar con Sequelize:', err));

module.exports = {
    db,
    sequelize
};

