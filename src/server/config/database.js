const { Sequelize } = require('sequelize');
const path = require('path');
const logger = require('../services/logger');

function getDatabasePath() {
    const dbPath = path.join(__dirname, '../../db', process.env.DB_NAME);
    logger.debug('Database path:', dbPath);
    return dbPath;
}

const params = {
    dialect: 'sqlite',
    storage: getDatabasePath(),
}

if (process.env.NODE_ENV === 'test') {
    params.logging = false;
} else {
    params.logging =  (msg) => logger.debug(msg);
}

const sequelize = new Sequelize(params);    

module.exports = sequelize;
