const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Resource = sequelize.define('Resource', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    player_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    gold: {
        type: DataTypes.INTEGER,
        defaultValue: 1000
    },
    food: {
        type: DataTypes.INTEGER,
        defaultValue: 500
    },
    wood: {
        type: DataTypes.INTEGER,
        defaultValue: 300
    },
    iron: {
        type: DataTypes.INTEGER,
        defaultValue: 200
    },
    tools: {
        type: DataTypes.INTEGER,
        defaultValue: 100
    },
    wine: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    people: {
        type: DataTypes.INTEGER,
        defaultValue: 10
    }
}, {
    tableName: 'resources',
    timestamps: false
});

module.exports = Resource; 