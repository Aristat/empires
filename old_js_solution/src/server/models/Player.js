const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Player = sequelize.define('Player', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    loginname: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
    },
    password: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    civ: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    email: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    created_on: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
    validated: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    validation_code: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    last_load: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
    is_admin: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    alliance_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
    },
    score: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    turn: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    turns_free: {
        type: DataTypes.INTEGER,
        defaultValue: 100,
    },
    last_turn: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
    killed_by: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    killed_by_name: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    // Resources
    gold: {
        type: DataTypes.INTEGER,
        defaultValue: 1000,
    },
    food: {
        type: DataTypes.INTEGER,
        defaultValue: 500,
    },
    wood: {
        type: DataTypes.INTEGER,
        defaultValue: 300,
    },
    iron: {
        type: DataTypes.INTEGER,
        defaultValue: 200,
    },
    tools: {
        type: DataTypes.INTEGER,
        defaultValue: 100,
    },
    wine: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    people: {
        type: DataTypes.INTEGER,
        defaultValue: 10,
    },
    // Buildings
    woodcutter: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    hunter: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    farmer: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    house: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    iron_mine: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    gold_mine: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    tool_maker: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    weapon_smith: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    fort: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    tower: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    town_center: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    market: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    warehouse: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    stable: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    winery: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    wall: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    // Military
    swordsman: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    archers: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    horseman: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    catapults: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    macemen: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    trained_peasants: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    thieves: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    // Equipment
    swords: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    bows: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    horses: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    maces: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    // Land
    f_land: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    m_land: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
    p_land: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
    },
}, {
    tableName: 'players',
    timestamps: false,
});

module.exports = Player;
