const sequelize = require('./config/database');

afterAll(async () => {
    // Clean up test database
    await sequelize.drop();
    await sequelize.close();
}); 