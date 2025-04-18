const sequelize = require('./config/database');

beforeAll(async () => {
    try {
        // Disable logging during tests
        sequelize.options.logging = false;
        
        // Test the database connection
        await sequelize.authenticate();
        
        // Sync the database
        await sequelize.sync({ force: true });
    } catch (error) {
        console.error('Unable to connect to the database:', error);
        throw error;
    }
});

afterAll(async () => {
    await sequelize.close();
}); 