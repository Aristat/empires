require('dotenv').config({ path: '.env.test' });
const sequelize = require('./config/database');
const dataManager = require('./data_manager');

beforeAll(async () => {
    await dataManager.initializeDatabase();
});

afterAll(async () => {
    // Clean up test database
    await sequelize.drop();
    await sequelize.close();
}); 