const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Military = sequelize.define('Military', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    player_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    swordsman: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    archers: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    horseman: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    catapults: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    macemen: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    trained_peasants: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    thieves: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    tableName: 'military',
    timestamps: false
});

module.exports = Military; 