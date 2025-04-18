const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Player = sequelize.define('Player', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    loginname: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    password: {
        type: DataTypes.STRING,
        allowNull: false
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false
    },
    civ: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    email: {
        type: DataTypes.STRING,
        allowNull: true
    },
    created_on: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    },
    validated: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    validation_code: {
        type: DataTypes.STRING,
        allowNull: true
    },
    last_load: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    },
    is_admin: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    alliance_id: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    score: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    turn: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    turns_free: {
        type: DataTypes.INTEGER,
        defaultValue: 100
    },
    last_turn: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    },
    killed_by: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    killed_by_name: {
        type: DataTypes.STRING,
        allowNull: true
    }
}, {
    tableName: 'players',
    timestamps: false
});

module.exports = Player; 