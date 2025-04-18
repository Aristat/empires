const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MilitaryEquipment = sequelize.define('MilitaryEquipment', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    player_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    swords: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    bows: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    horses: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    maces: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    tableName: 'military_equipment',
    timestamps: false
});

module.exports = MilitaryEquipment; 