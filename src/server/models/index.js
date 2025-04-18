const Player = require('./Player');
const Resource = require('./Resource');
const Building = require('./Building');
const Military = require('./Military');
const MilitaryEquipment = require('./MilitaryEquipment');
const Land = require('./Land');

// Set up relationships
Player.hasOne(Resource, { foreignKey: 'player_id' });
Resource.belongsTo(Player, { foreignKey: 'player_id' });

Player.hasOne(Building, { foreignKey: 'player_id' });
Building.belongsTo(Player, { foreignKey: 'player_id' });

Player.hasOne(Military, { foreignKey: 'player_id' });
Military.belongsTo(Player, { foreignKey: 'player_id' });

Player.hasOne(MilitaryEquipment, { foreignKey: 'player_id' });
MilitaryEquipment.belongsTo(Player, { foreignKey: 'player_id' });

Player.hasOne(Land, { foreignKey: 'player_id' });
Land.belongsTo(Player, { foreignKey: 'player_id' });

module.exports = {
    Player,
    Resource,
    Building,
    Military,
    MilitaryEquipment,
    Land
}; 