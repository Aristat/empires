const bcrypt = require('bcrypt');
const { Player, Resource, Building, Military, MilitaryEquipment, Land } = require('./models');
const sequelize = require('./config/database');

class DataManager {
    async initializeDatabase() {
        try {
            await sequelize.authenticate();
            console.log('Connected to the SQLite database.');
            
            // Sync all models with the database
            await sequelize.sync();
            console.log('Database schema synchronized successfully');
        } catch (err) {
            console.error('Error initializing database:', err);
            throw err;
        }
    }

    async createPlayer(loginname, password, name, civ, email) {
        try {
            const hashedPassword = await bcrypt.hash(password, 10);
            const validationCode = Math.random().toString(36).substring(2, 15);

            // Create player and all related records in a transaction
            const result = await sequelize.transaction(async (t) => {
                const player = await Player.create({
                    loginname,
                    password: hashedPassword,
                    name,
                    civ,
                    email,
                    validation_code: validationCode
                }, { transaction: t });

                // Create related records
                await Promise.all([
                    Resource.create({
                        player_id: player.id,
                        gold: 1000,
                        food: 500,
                        wood: 300,
                        iron: 200,
                        tools: 100,
                        wine: 0
                    }, { transaction: t }),
                    Building.create({
                        player_id: player.id
                    }, { transaction: t }),
                    Military.create({
                        player_id: player.id
                    }, { transaction: t }),
                    MilitaryEquipment.create({
                        player_id: player.id
                    }, { transaction: t }),
                    Land.create({
                        player_id: player.id
                    }, { transaction: t })
                ]);

                return player;
            });

            return {
                id: result.id,
                loginname: result.loginname,
                name: result.name,
                civ: result.civ,
                email: result.email,
                validationCode: result.validation_code
            };
        } catch (err) {
            console.error('Error creating player:', err);
            throw err;
        }
    }

    async authenticatePlayer(loginname, password) {
        try {
            const player = await Player.findOne({
                where: { loginname },
                include: [
                    { model: Resource },
                    { model: Building },
                    { model: Military },
                    { model: MilitaryEquipment },
                    { model: Land }
                ]
            });

            if (!player) {
                return { success: false, message: 'Player not found' };
            }

            const passwordMatch = await bcrypt.compare(password, player.password);
            if (!passwordMatch) {
                return { success: false, message: 'Invalid password' };
            }

            // Update last_load timestamp
            await player.update({ last_load: new Date() });

            return {
                success: true,
                player: {
                    id: player.id,
                    loginname: player.loginname,
                    name: player.name,
                    civ: player.civ,
                    email: player.email,
                    score: player.score,
                    turn: player.turn,
                    turns_free: player.turns_free,
                    alliance_id: player.alliance_id,
                    resources: player.Resource,
                    buildings: player.Building,
                    military: player.Military,
                    equipment: player.MilitaryEquipment,
                    land: player.Land
                }
            };
        } catch (err) {
            console.error('Error authenticating player:', err);
            throw err;
        }
    }

    async getPlayerData(playerId) {
        try {
            const player = await Player.findOne({
                where: { id: playerId },
                include: [
                    { model: Resource },
                    { model: Building },
                    { model: Military },
                    { model: MilitaryEquipment },
                    { model: Land }
                ]
            });

            if (!player) {
                throw new Error('Player not found');
            }

            return {
                id: player.id,
                loginname: player.loginname,
                name: player.name,
                civ: player.civ,
                email: player.email,
                score: player.score,
                turn: player.turn,
                turns_free: player.turns_free,
                alliance_id: player.alliance_id,
                resources: player.Resource,
                buildings: player.Building,
                military: player.Military,
                equipment: player.MilitaryEquipment,
                land: player.Land
            };
        } catch (err) {
            console.error('Error getting player data:', err);
            throw err;
        }
    }

    async updatePlayerResources(playerId, resourceUpdates) {
        try {
            const resource = await Resource.findOne({ where: { player_id: playerId } });
            if (!resource) {
                throw new Error('Resource record not found');
            }

            await resource.update(resourceUpdates);
            return resource;
        } catch (err) {
            console.error('Error updating player resources:', err);
            throw err;
        }
    }

    async updatePlayerBuildings(playerId, buildingUpdates) {
        try {
            const building = await Building.findOne({ where: { player_id: playerId } });
            if (!building) {
                throw new Error('Building record not found');
            }

            await building.update(buildingUpdates);
            return building;
        } catch (err) {
            console.error('Error updating player buildings:', err);
            throw err;
        }
    }

    async updatePlayerMilitary(playerId, militaryUpdates) {
        try {
            const military = await Military.findOne({ where: { player_id: playerId } });
            if (!military) {
                throw new Error('Military record not found');
            }

            await military.update(militaryUpdates);
            return military;
        } catch (err) {
            console.error('Error updating player military:', err);
            throw err;
        }
    }

    async updatePlayerEquipment(playerId, equipmentUpdates) {
        try {
            const equipment = await MilitaryEquipment.findOne({ where: { player_id: playerId } });
            if (!equipment) {
                throw new Error('Equipment record not found');
            }

            await equipment.update(equipmentUpdates);
            return equipment;
        } catch (err) {
            console.error('Error updating player equipment:', err);
            throw err;
        }
    }

    async updatePlayerLand(playerId, landUpdates) {
        try {
            const land = await Land.findOne({ where: { player_id: playerId } });
            if (!land) {
                throw new Error('Land record not found');
            }

            await land.update(landUpdates);
            return land;
        } catch (err) {
            console.error('Error updating player land:', err);
            throw err;
        }
    }
}

module.exports = new DataManager(); 