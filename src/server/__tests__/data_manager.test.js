const { DataManager } = require('../data_manager');
const { Player } = require('../models/Player');

describe('DataManager', () => {
  let dataManager;

  beforeEach(async () => {
    dataManager = new DataManager();
    // Clear the database before each test
    await Player.destroy({ where: {}, truncate: true });
  });

  describe('createPlayer', () => {
    it('should create a new player successfully', async () => {
      const playerData = {
        login: 'testplayer',
        password: 'testpass',
        email: 'test@example.com',
        civilization_id: 1
      };

      const result = await dataManager.createPlayer(playerData);
      
      expect(result.success).toBe(true);
      expect(result.player).toBeDefined();
      expect(result.player.login).toBe(playerData.login);
      expect(result.player.email).toBe(playerData.email);
      expect(result.player.civilization_id).toBe(playerData.civilization_id);
    });

    it('should fail when creating a player with duplicate login', async () => {
      const playerData = {
        login: 'testplayer',
        password: 'testpass',
        email: 'test@example.com',
        civilization_id: 1
      };

      // Create first player
      await dataManager.createPlayer(playerData);

      // Try to create second player with same login
      const result = await dataManager.createPlayer(playerData);
      
      expect(result.success).toBe(false);
      expect(result.error).toBeDefined();
    });
  });

  describe('authenticatePlayer', () => {
    it('should authenticate a valid player', async () => {
      const playerData = {
        login: 'testplayer',
        password: 'testpass',
        email: 'test@example.com',
        civilization_id: 1
      };

      // Create player first
      await dataManager.createPlayer(playerData);

      const result = await dataManager.authenticatePlayer(playerData.login, playerData.password);
      
      expect(result.success).toBe(true);
      expect(result.player).toBeDefined();
      expect(result.player.login).toBe(playerData.login);
    });

    it('should fail authentication with wrong password', async () => {
      const playerData = {
        login: 'testplayer',
        password: 'testpass',
        email: 'test@example.com',
        civilization_id: 1
      };

      // Create player first
      await dataManager.createPlayer(playerData);

      const result = await dataManager.authenticatePlayer(playerData.login, 'wrongpass');
      
      expect(result.success).toBe(false);
      expect(result.error).toBeDefined();
    });

    it('should fail authentication for non-existent player', async () => {
      const result = await dataManager.authenticatePlayer('nonexistent', 'password');
      
      expect(result.success).toBe(false);
      expect(result.error).toBeDefined();
    });
  });
}); 