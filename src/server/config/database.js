const { Sequelize } = require('sequelize');
const path = require('path');

function getDatabasePath() {
    const dbName = process.env.NODE_ENV === 'test' ? 'test.db' : 'game.db';
    return path.join(__dirname, '../../db', dbName);
}

const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: getDatabasePath(),
    logging: process.env.NODE_ENV === 'test' ? false : console.log
});

module.exports = sequelize; 