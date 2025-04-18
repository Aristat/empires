require('dotenv').config({ path: '.env.test' });
const { afterEach } = require('@jest/globals');
const sequelize = require('./config/database');
const dataManager = require('./data_manager');

beforeAll(async () => {
    await dataManager.initializeDatabase();
});

afterEach(async () => {
    await sequelize.truncate();
});

afterAll(async () => {
    await sequelize.drop();
    await sequelize.close();
}); 