const request = require('supertest');
const gameRoutes = require('../../routes/game');
const dataManager = require('../../data_manager');
const { createTestApp } = require('../../test_utils/test_helper');

// Mock dependencies
jest.mock('../../data_manager');

describe('Game Routes', () => {
    let app;

    beforeEach(() => {
        app = createTestApp();
        app.use('/', gameRoutes);
    });

    describe('GET /game', () => {
        it('should redirect to home if user is not logged in', async () => {
            const response = await request(app)
                .get('/game')
                .expect(302);

            expect(response.header.location).toBe('/');
        });

        it('should render game page with player data when logged in', async () => {
            const mockPlayerData = {
                id: 1,
                loginname: 'testuser',
                name: 'Test User',
                civ: 1,
                email: 'test@example.com',
                score: 100,
                turn: 1,
                turns_free: 99,
                alliance_id: null,
                resources: {
                    gold: 1000,
                    food: 500,
                    wood: 300,
                    iron: 200,
                    tools: 100,
                    wine: 0,
                    people: 10,
                },
                buildings: {
                    woodcutter: 1,
                    hunter: 1,
                    farmer: 1,
                    house: 1,
                    iron_mine: 0,
                    gold_mine: 0,
                    tool_maker: 0,
                    weapon_smith: 0,
                    fort: 0,
                    tower: 0,
                    town_center: 1,
                    market: 0,
                    warehouse: 0,
                    stable: 0,
                    winery: 0,
                    wall: 0,
                },
                military: {
                    swordsman: 0,
                    archers: 0,
                    horseman: 0,
                    catapults: 0,
                    macemen: 0,
                    trained_peasants: 0,
                    thieves: 0,
                },
                equipment: {
                    swords: 0,
                    bows: 0,
                    horses: 0,
                    maces: 0,
                },
                land: {
                    f_land: 10,
                    m_land: 5,
                    p_land: 5,
                    free_f_land: 5,
                    free_m_land: 2,
                    free_p_land: 2,
                },
            };

            dataManager.getPlayerData.mockResolvedValue(mockPlayerData);

            const response = await request(app)
                .get('/game')
                .set('Cookie', ['connect.sid=test-session'])
                .expect(200);

            expect(response.text).toContain('game');
            expect(dataManager.getPlayerData).toHaveBeenCalledWith(1);
        });

        it('should handle errors when loading player data', async () => {
            dataManager.getPlayerData.mockRejectedValue(new Error('Database error'));

            const response = await request(app)
                .get('/game')
                .set('Cookie', ['connect.sid=test-session'])
                .expect(500);

            expect(response.text).toContain('Error loading game data');
        });
    });
});
