const configManager = require('../../config/config_manager');

describe('ConfigManager', () => {
    test('should load civilizations configuration', () => {
        const civilizations = configManager.getAllCivilizations();
        expect(civilizations).toBeDefined();
        expect(Array.isArray(civilizations)).toBe(true);
        expect(civilizations.length).toBeGreaterThan(0);
    });

    test('should get civilization by id', () => {
        const civ = configManager.getCivilization(1);
        expect(civ).toBeDefined();
        expect(civ.id).toBe(1);
        expect(civ.name).toBe('Vikings');
        expect(civ.bonuses).toBeDefined();
    });

    test('should validate civilization id', () => {
        expect(configManager.validateCivilizationId(1)).toBe(true);
        expect(configManager.validateCivilizationId(999)).toBe(false);
    });

    test('civilization should have correct structure', () => {
        const civ = configManager.getCivilization(1);
        expect(civ).toHaveProperty('id');
        expect(civ).toHaveProperty('name');
        expect(civ).toHaveProperty('description');
        expect(civ).toHaveProperty('bonuses');
        expect(civ.bonuses).toHaveProperty('military');
        expect(civ.bonuses).toHaveProperty('construction');
        expect(civ.bonuses).toHaveProperty('research');
    });
});
