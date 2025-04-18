const request = require('supertest');
const path = require('path');
const authRoutes = require('../../routes/auth');
const dataManager = require('../../data_manager');
const configManager = require('../../config/config_manager');
const { createTestApp } = require('../../test_utils/test_helper');

// Mock dependencies
jest.mock('../../data_manager');
jest.mock('../../config/config_manager');

describe('Auth Routes', () => {
    let app;

    beforeEach(() => {
        app = createTestApp();
        app.use('/', authRoutes);
    });

    describe('GET /', () => {
        it('should redirect to /game if user is logged in', async () => {
            const response = await request(app)
                .get('/')
                .set('Cookie', ['connect.sid=test-session'])
                .set('X-Test-Session', '1')
                .expect(302);

            expect(response.header.location).toBe('/game');
        });

        it('should render login page if user is not logged in', async () => {
            const response = await request(app)
                .get('/')
                .expect(200);

            expect(response.text).toContain('login');
        });
    });

    describe('GET /register', () => {
        it('should render register page with civilizations', async () => {
            const mockCivilizations = [
                {
                    id: 1,
                    name: 'Vikings',
                    description: 'Seafaring warriors',
                    bonuses: {
                        military: 1.2,
                        construction: 1.0,
                        research: 1.0,
                    },
                },
                {
                    id: 2,
                    name: 'Japanese',
                    description: 'Honorable warriors',
                    bonuses: {
                        military: 1.15,
                        construction: 1.0,
                        research: 1.0,
                    },
                },
            ];

            // Mock the configManager method
            configManager.getAllCivilizations.mockReturnValue(mockCivilizations);

            const response = await request(app)
                .get('/register')
                .expect(200);

            // Check if the page contains expected elements
            expect(response.text).toContain('Create Your Empire');
            expect(response.text).toContain('Vikings');
            expect(response.text).toContain('Japanese');
            expect(response.text).toContain('Civilization Bonuses');

            // Verify the mock was called
            expect(configManager.getAllCivilizations).toHaveBeenCalled();
        });
    });

    describe('POST /register', () => {
        it('should create a new player with valid data', async () => {
            const mockPlayerData = {
                loginname: 'testuser',
                password: 'testpass',
                name: 'Test User',
                civ: 1,
                email: 'test@example.com',
            };

            configManager.validateCivilizationId.mockReturnValue(true);
            dataManager.createPlayer.mockResolvedValue({ id: 1 });

            const response = await request(app)
                .post('/register')
                .send(mockPlayerData)
                .expect(200);

            expect(response.text).toContain('Account created successfully');
            expect(dataManager.createPlayer).toHaveBeenCalledWith(
                mockPlayerData.loginname,
                mockPlayerData.password,
                mockPlayerData.name,
                mockPlayerData.civ,
                mockPlayerData.email,
            );
        });

        it('should return error for invalid civilization', async () => {
            const mockPlayerData = {
                loginname: 'testuser',
                password: 'testpass',
                name: 'Test User',
                civ: 999,
                email: 'test@example.com',
            };

            configManager.validateCivilizationId.mockReturnValue(false);
            configManager.getAllCivilizations.mockReturnValue([
                { 
                    id: 1, 
                    name: 'Vikings',
                    description: 'Seafaring warriors',
                    bonuses: {
                        military: 1.2,
                        construction: 1.0,
                        research: 1.0
                    }
                }
            ]);

            const response = await request(app)
                .post('/register')
                .send(mockPlayerData)
                .expect(200);

            expect(response.text).toContain('Invalid civilization selected');
            expect(response.text).toContain('message error');
        });
    });

    describe('POST /login', () => {
        it('should login with valid credentials', async () => {
            const mockCredentials = {
                loginname: 'testuser',
                password: 'testpass',
            };

            dataManager.authenticatePlayer.mockResolvedValue({
                success: true,
                player: {
                    id: 1,
                    loginname: 'testuser',
                },
            });

            const response = await request(app)
                .post('/login')
                .send(mockCredentials)
                .expect(302);

            expect(response.header.location).toBe('/game');
        });

        it('should return error with invalid credentials', async () => {
            const mockCredentials = {
                loginname: 'testuser',
                password: 'wrongpass',
            };

            dataManager.authenticatePlayer.mockResolvedValue(null);

            const response = await request(app)
                .post('/login')
                .send(mockCredentials)
                .expect(200);

            expect(response.text).toContain('Invalid login name or password');
            expect(response.text).toContain('message error');
        });
    });

    describe('GET /logout', () => {
        it('should destroy session and redirect to home', async () => {
            const response = await request(app)
                .get('/logout')
                .set('Cookie', ['connect.sid=test-session'])
                .expect(302);

            expect(response.header.location).toBe('/');
        });
    });
});
