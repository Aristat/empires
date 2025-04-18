const bcrypt = require('bcrypt');
const { Player } = require('./models');
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

            const player = await Player.create({
                loginname,
                password: hashedPassword,
                name,
                civ,
                email,
                validation_code: validationCode
            });

            return {
                id: player.id,
                loginname: player.loginname,
                name: player.name,
                civ: player.civ,
                email: player.email,
                created_on: player.created_on,
                validated: player.validated,
                validation_code: player.validation_code,
                last_load: player.last_load,
                is_admin: player.is_admin,
                alliance_id: player.alliance_id,
                score: player.score,
                turn: player.turn,
                turns_free: player.turns_free,
                last_turn: player.last_turn,
                killed_by: player.killed_by,
                killed_by_name: player.killed_by_name,
                // Resources
                gold: player.gold,
                food: player.food,
                wood: player.wood,
                iron: player.iron,
                tools: player.tools,
                wine: player.wine,
                people: player.people,
                // Buildings
                houses: player.houses,
                farms: player.farms,
                woodcutters: player.woodcutters,
                mines: player.mines,
                blacksmiths: player.blacksmiths,
                wineries: player.wineries,
                markets: player.markets,
                // Military
                soldiers: player.soldiers,
                archers: player.archers,
                cavalry: player.cavalry,
                // Equipment
                swords: player.swords,
                bows: player.bows,
                horses: player.horses,
                // Land
                land_owned: player.land_owned,
                land_fertile: player.land_fertile,
                land_forest: player.land_forest,
                land_mountain: player.land_mountain
            };
        } catch (error) {
            if (error.name === 'SequelizeUniqueConstraintError') {
                throw new Error('Login name already exists');
            }
            throw error;
        }
    }

    async authenticatePlayer(loginname, password) {
        try {
            const player = await Player.findOne({ where: { loginname } });
            if (!player) {
                return null;
            }

            const isValid = await bcrypt.compare(password, player.password);
            if (!isValid) {
                return null;
            }

            return {
                id: player.id,
                loginname: player.loginname,
                name: player.name,
                civ: player.civ,
                email: player.email,
                created_on: player.created_on,
                validated: player.validated,
                validation_code: player.validation_code,
                last_load: player.last_load,
                is_admin: player.is_admin,
                alliance_id: player.alliance_id,
                score: player.score,
                turn: player.turn,
                turns_free: player.turns_free,
                last_turn: player.last_turn,
                killed_by: player.killed_by,
                killed_by_name: player.killed_by_name,
                // Resources
                gold: player.gold,
                food: player.food,
                wood: player.wood,
                iron: player.iron,
                tools: player.tools,
                wine: player.wine,
                people: player.people,
                // Buildings
                houses: player.houses,
                farms: player.farms,
                woodcutters: player.woodcutters,
                mines: player.mines,
                blacksmiths: player.blacksmiths,
                wineries: player.wineries,
                markets: player.markets,
                // Military
                soldiers: player.soldiers,
                archers: player.archers,
                cavalry: player.cavalry,
                // Equipment
                swords: player.swords,
                bows: player.bows,
                horses: player.horses,
                // Land
                land_owned: player.land_owned,
                land_fertile: player.land_fertile,
                land_forest: player.land_forest,
                land_mountain: player.land_mountain
            };
        } catch (error) {
            console.error('Error authenticating player:', error);
            throw error;
        }
    }

    async updatePlayer(playerId, updates) {
        try {
            const player = await Player.findByPk(playerId);
            if (!player) {
                throw new Error('Player not found');
            }

            await player.update(updates);
            return player;
        } catch (error) {
            console.error('Error updating player:', error);
            throw error;
        }
    }
}

module.exports = new DataManager(); 