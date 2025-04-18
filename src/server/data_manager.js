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
                woodcutter: player.woodcutter,
                hunter: player.hunter,
                farmer: player.farmer,
                house: player.house,
                iron_mine: player.iron_mine,
                gold_mine: player.gold_mine,
                tool_maker: player.tool_maker,
                weapon_smith: player.weapon_smith,
                fort: player.fort,
                tower: player.tower,
                town_center: player.town_center,
                market: player.market,
                warehouse: player.warehouse,
                stable: player.stable,
                winery: player.winery,
                wall: player.wall,
                // Military
                swordsman: player.swordsman,
                archers: player.archers,
                horseman: player.horseman,
                catapults: player.catapults,
                macemen: player.macemen,
                trained_peasants: player.trained_peasants,
                thieves: player.thieves,
                // Equipment
                swords: player.swords,
                bows: player.bows,
                horses: player.horses,
                maces: player.maces,
                // Land
                f_land: player.f_land,
                m_land: player.m_land,
                p_land: player.p_land
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
                woodcutter: player.woodcutter,
                hunter: player.hunter,
                farmer: player.farmer,
                house: player.house,
                iron_mine: player.iron_mine,
                gold_mine: player.gold_mine,
                tool_maker: player.tool_maker,
                weapon_smith: player.weapon_smith,
                fort: player.fort,
                tower: player.tower,
                town_center: player.town_center,
                market: player.market,
                warehouse: player.warehouse,
                stable: player.stable,
                winery: player.winery,
                wall: player.wall,
                // Military
                swordsman: player.swordsman,
                archers: player.archers,
                horseman: player.horseman,
                catapults: player.catapults,
                macemen: player.macemen,
                trained_peasants: player.trained_peasants,
                thieves: player.thieves,
                // Equipment
                swords: player.swords,
                bows: player.bows,
                horses: player.horses,
                maces: player.maces,
                // Land
                f_land: player.f_land,
                m_land: player.m_land,
                p_land: player.p_land
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