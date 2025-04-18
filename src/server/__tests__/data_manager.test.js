const { Player } = require('../models');
const dataManager = require('../data_manager');

describe('DataManager', () => {
  describe('createPlayer', () => {
    it('should create a new player successfully', async () => {
      const loginname = 'testplayer';
      const password = 'testpass';
      const name = 'Test Player';
      const civ = 1;
      const email = 'test@example.com';

      const result = await dataManager.createPlayer(loginname, password, name, civ, email);
      
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