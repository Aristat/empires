const yaml = require('js-yaml');
const fs = require('fs');
const path = require('path');
const logger = require('../services/logger');

class ConfigManager {
    constructor() {
        this.civilizations = null;
        this.loadConfig();
    }

    loadConfig() {
        try {
            const configPath = path.join(__dirname, 'civilizations.yaml');
            const fileContents = fs.readFileSync(configPath, 'utf8');
            const config = yaml.load(fileContents);
            this.civilizations = config.civilizations;
            logger.info('Civilizations configuration loaded successfully');
        } catch (err) {
            logger.error('Error loading civilizations configuration:', err);
            throw err;
        }
    }

    getCivilization(id) {
        return this.civilizations.find((civ) => civ.id === id);
    }

    getAllCivilizations() {
        return this.civilizations;
    }

    validateCivilizationId(id) {
        return this.civilizations.some((civ) => civ.id === id);
    }
}

module.exports = new ConfigManager();
