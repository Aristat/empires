const bcrypt = require('bcrypt');
const Player = require('./models/Player');
const sequelize = require('./config/database');

class DataManager {
    constructor() {
        this.initializeDatabase();
    }

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

            // Initialize all required tables for new player
            // Note: In Sequelize, we would typically define these as models and use associations
            // For now, we'll keep the raw SQL for these tables as they were in the original code
            const initPromises = [
                sequelize.query(
                    'INSERT INTO resources (player_id, gold, food, wood, iron, tools, wine) VALUES (?, ?, ?, ?, ?, ?, ?)',
                    { replacements: [player.id, 1000, 500, 300, 200, 100, 0] }
                ),
                sequelize.query(
                    'INSERT INTO military (player_id) VALUES (?)',
                    { replacements: [player.id] }
                ),
                sequelize.query(
                    'INSERT INTO military_equipment (player_id) VALUES (?)',
                    { replacements: [player.id] }
                ),
                sequelize.query(
                    'INSERT INTO land (player_id) VALUES (?)',
                    { replacements: [player.id] }
                )
            ];

            await Promise.all(initPromises);

            return {
                id: player.id,
                loginname: player.loginname,
                name: player.name,
                civ: player.civ,
                email: player.email,
                validationCode: player.validation_code
            };
        } catch (err) {
            console.error('Error creating player:', err);
            throw err;
        }
    }

    async authenticatePlayer(loginname, password) {
        try {
            const player = await Player.findOne({
                where: { loginname }
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
                    validated: player.validated,
                    is_admin: player.is_admin,
                    alliance_id: player.alliance_id,
                    score: player.score,
                    turn: player.turn,
                    turns_free: player.turns_free,
                    last_turn: player.last_turn
                }
            };
        } catch (err) {
            console.error('Error authenticating player:', err);
            return { success: false, message: 'Authentication error' };
        }
    }
}

module.exports = new DataManager(); 