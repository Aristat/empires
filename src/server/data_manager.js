const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
const path = require('path');
const fs = require('fs');

class DataManager {
    constructor() {
        this.db = new sqlite3.Database(path.join(__dirname, '../db/game.db'), (err) => {
            if (err) {
                console.error('Error opening database:', err);
            } else {
                console.log('Connected to the SQLite database.');
                this.initializeDatabase();
            }
        });
    }

    async initializeDatabase() {
        const schema = fs.readFileSync(path.join(__dirname, '../db/schema.sql'), 'utf8');
        return new Promise((resolve, reject) => {
            this.db.exec(schema, (err) => {
                if (err) {
                    console.error('Error initializing database:', err);
                    reject(err);
                } else {
                    console.log('Database schema initialized successfully');
                    resolve();
                }
            });
        });
    }

    async createPlayer(loginname, password, name, civ, email) {
        const hashedPassword = await bcrypt.hash(password, 10);
        const validationCode = Math.random().toString(36).substring(2, 15);
        
        return new Promise((resolve, reject) => {
            this.db.run(
                'INSERT INTO players (loginname, password, name, civ, email, validation_code) VALUES (?, ?, ?, ?, ?, ?)',
                [loginname, hashedPassword, name, civ, email, validationCode],
                function(err) {
                    if (err) {
                        reject(err);
                        return;
                    }
                    
                    const playerId = this.lastID;
                    console.log(playerId);
                    const db = this.db;
                    
                    // Initialize all required tables for new player
                    const initPromises = [
                        // Resources
                        new Promise((res, rej) => {
                            db.run(
                                'INSERT INTO resources (player_id, gold, food, wood, iron, tools, wine) VALUES (?, ?, ?, ?, ?, ?, ?)',
                                [playerId, 1000, 500, 300, 200, 100, 0],
                                (err) => err ? rej(err) : res()
                            );
                        }),
                        // Military
                        new Promise((res, rej) => {
                            db.run(
                                'INSERT INTO military (player_id) VALUES (?)',
                                [playerId],
                                (err) => err ? rej(err) : res()
                            );
                        }),
                        // Military Equipment
                        new Promise((res, rej) => {
                            db.run(
                                'INSERT INTO military_equipment (player_id) VALUES (?)',
                                [playerId],
                                (err) => err ? rej(err) : res()
                            );
                        }),
                        // Land
                        new Promise((res, rej) => {
                            db.run(
                                'INSERT INTO land (player_id) VALUES (?)',
                                [playerId],
                                (err) => err ? rej(err) : res()
                            );
                        }),
                        // Research
                        new Promise((res, rej) => {
                            db.run(
                                'INSERT INTO research (player_id) VALUES (?)',
                                [playerId],
                                (err) => err ? rej(err) : res()
                            );
                        })
                    ];

                    Promise.all(initPromises)
                        .then(() => {
                            resolve({
                                id: playerId,
                                loginname,
                                name,
                                civ,
                                email,
                                validationCode
                            });
                        })
                        .catch(reject);
                }
            );
        });
    }
}

module.exports = new DataManager(); 