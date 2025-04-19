const dataManager = require('../data_manager');

const playerData = {
    loginname: 'testplayer',
    password: 'testpass',
    name: 'Test Player',
    civ: 1,
    email: 'test@example.com',
};

describe('DataManager', () => {
    describe('createPlayer', () => {
        it('should create a new player successfully', async () => {
            const result = await dataManager.createPlayer(
                playerData.loginname,
                playerData.password,
                playerData.name,
                playerData.civ,
                playerData.email,
            );

            expect(result.id).toBeDefined();
        });

        it('should fail when creating a player with duplicate login', async () => {
            await dataManager.createPlayer(
                playerData.loginname,
                playerData.password,
                playerData.name,
                playerData.civ,
                playerData.email,
            );

            await expect(dataManager.createPlayer(
                playerData.loginname,
                playerData.password,
                playerData.name,
                playerData.civ,
                playerData.email,
            )).rejects.toThrow('Login name already exists');
        });
    });

    describe('authenticatePlayer', () => {
        it('should authenticate a valid player', async () => {
            const player = await dataManager.createPlayer(
                playerData.loginname,
                playerData.password,
                playerData.name,
                playerData.civ,
                playerData.email,
            );

            const result = await dataManager.authenticatePlayer(
                playerData.loginname,
                playerData.password,
            );

            expect(result.id).toBe(player.id);
        });

        it('should fail authentication with wrong password', async () => {
            await dataManager.createPlayer(
                playerData.loginname,
                playerData.password,
                playerData.name,
                playerData.civ,
                playerData.email,
            );

            const result = await dataManager.authenticatePlayer(
                playerData.loginname,
                'wrongpass',
            );

            expect(result).toBeNull();
        });

        it('should fail authentication for non-existent player', async () => {
            const result = await dataManager.authenticatePlayer(
                'nonexistent',
                'password',
            );

            expect(result).toBeNull();
        });
    });
});
