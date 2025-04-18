const express = require('express');

const router = express.Router();
const dataManager = require('../data_manager');
const configManager = require('../config/config_manager');

// GET routes
router.get('/', (req, res) => {
    if (req.session.userId) {
        res.redirect('/game');
    } else {
        res.render('login', { message: '' });
    }
});

router.get('/register', (req, res) => {
    const civilizations = configManager.getAllCivilizations();
    res.render('register', {
        message: '',
        civilizations,
    });
});

router.get('/logout', async (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            console.error('Error destroying session:', err);
        }
        res.redirect('/');
    });
});

// POST routes
router.post('/register', async (req, res) => {
    const {
        loginname, password, name, civ, email,
    } = req.body;

    // Validate civilization ID
    if (!configManager.validateCivilizationId(parseInt(civ, 10))) {
        return res.render('register', {
            message: {
                type: 'error',
                text: 'Invalid civilization selected',
            },
            civilizations: configManager.getAllCivilizations(),
        });
    }

    try {
        await dataManager.createPlayer(loginname, password, name, parseInt(civ, 10), email);
        return res.render('login', {
            message: {
                type: 'success',
                text: 'Account created successfully! Please check your email for validation code.',
            },
        });
    } catch (error) {
        return res.render('register', {
            message: {
                type: 'error',
                text: 'An error occurred during registration',
            },
            civilizations: configManager.getAllCivilizations(),
        });
    }
});

router.post('/login', async (req, res) => {
    const { loginname, password } = req.body;

    try {
        const result = await dataManager.authenticatePlayer(loginname, password);

        if (!result) {
            return res.render('login', {
                message: {
                    type: 'error',
                    text: 'Invalid login name or password',
                },
            });
        }

        // Set session
        req.session.userId = result.id;
        req.session.loginname = result.loginname;

        return res.redirect('/game');
    } catch (error) {
        console.error('Login error:', error);
        return res.status(500).render('login', {
            message: {
                type: 'error',
                text: 'An error occurred during login',
            },
        });
    }
});

module.exports = router;
