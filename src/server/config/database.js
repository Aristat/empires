const { Sequelize } = require('sequelize');
const path = require('path');

function getDatabasePath() {
    console.log("Database path:", path.join(__dirname, '../../db', process.env.DB_NAME));

    return path.join(__dirname, '../../db', process.env.DB_NAME);
}

const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: getDatabasePath(),
    logging: process.env.NODE_ENV === 'test' ? false : console.log
});

module.exports = sequelize; 