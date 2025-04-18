const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Building = sequelize.define('Building', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    player_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    woodcutter: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    hunter: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    farmer: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    house: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    iron_mine: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    gold_mine: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    tool_maker: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    weapon_smith: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    fort: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    tower: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    town_center: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    market: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    warehouse: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    stable: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    winery: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    wall: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    tableName: 'buildings',
    timestamps: false
});

module.exports = Building; 