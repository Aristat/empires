const express = require('express');

const router = express.Router();
const dataManager = require('../data_manager');

// Authentication middleware
const requireAuth = (req, res, next) => {
    if (req.session.userId) {
        next();
    } else {
        res.redirect('/');
    }
};

// Game routes
router.get('/game', requireAuth, async (req, res) => {
    try {
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
        console.error('Error loading game data:', error);
        res.status(500).render('error', { message: 'Error loading game data' });
    }
});

module.exports = router;
