const express = require('express');
const router = express.Router();
const dataManager = require('../data_manager');
const logger = require('../services/logger');

// Authentication middleware
const requireAuth = (req, res, next) => {
    if (req.session.userId) {
        next();
    } else {
        logger.warn(`Unauthorized access attempt to /game from ${req.ip}`);
        res.redirect('/');
    }
};

// Game routes
router.get('/game', requireAuth, async (req, res) => {
    try {
        logger.info(`Loading game data for user ${req.session.userId}`);
        const playerData = await dataManager.getPlayerData(req.session.userId);

        res.render('game', {
            user: {
                id: playerData.id,
                loginname: playerData.loginname,
                name: playerData.name,
                civ: playerData.civ,
                email: playerData.email,
                score: playerData.score,
                turn: playerData.turn,
                turns_free: playerData.turns_free,
                alliance_id: playerData.alliance_id,
                resources: playerData.resources,
                buildings: playerData.buildings,
                military: playerData.military,
                equipment: playerData.equipment,
                land: playerData.land,
            },
        });
    } catch (error) {
        logger.error(`Error loading game data for user ${req.session.userId}: ${error.message}`, error);
        res.status(500).send(error.message);
    }
});

module.exports = router;
