const sequelize = require('./config/database');
const dataManager = require('./data_manager');

beforeAll(async () => {
    try {
        await dataManager.initializeDatabase();
    } catch (error) {
        console.error('Unable to connect to the database:', error);
        throw error;
    }
});

afterAll(async () => {
    await sequelize.close();
}); 