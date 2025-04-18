const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Land = sequelize.define('Land', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    player_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    f_land: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    m_land: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    p_land: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    tableName: 'land',
    timestamps: false
});

module.exports = Land; 