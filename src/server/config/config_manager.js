const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

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
            console.log('Civilizations configuration loaded successfully');
        } catch (err) {
            console.error('Error loading civilizations configuration:', err);
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
