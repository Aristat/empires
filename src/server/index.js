require('dotenv').config();
const express = require('express');
const session = require('express-session');
const SQLiteStore = require('connect-sqlite3')(session);
const path = require('path');
const dataManager = require('./data_manager');
const configManager = require('./config/config_manager');

const app = express();
const port = process.env.PORT || 3000;

// Session configuration
app.use(session({
    store: new SQLiteStore({
        db: 'src/db/game.db',
        table: 'sessions'
    }),
    secret: process.env.SESSION_SECRET || 'your-secret-key',
    resave: false,
    saveUninitialized: false,
    cookie: {
        maxAge: 24 * 60 * 60 * 1000 // 24 hours
    }
}));

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '../public')));

// Set view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '../public/views'));

// Authentication middleware
const requireAuth = (req, res, next) => {
    if (req.session.userId) {
        next();
    } else {
        res.redirect('/');
    }
};

// Routes
app.get('/', (req, res) => {
    console.log(req.session.userId);

    if (req.session.userId) {
        res.redirect('/game');
    } else {
        res.render('login', { message: '' });
    }
});

app.get('/register', (req, res) => {
    const civilizations = configManager.getAllCivilizations();
    res.render('register', { 
        message: '',
        civilizations 
    });
});

app.post('/register', async (req, res) => {
    const { loginname, password, name, civ, email } = req.body;
    
    // Validate civilization ID
    if (!configManager.validateCivilizationId(parseInt(civ))) {
        return res.render('register', { 
            message: { 
                type: 'error', 
                text: 'Invalid civilization selected' 
            },
            civilizations: configManager.getAllCivilizations()
        });
    }
    
    try {
        await dataManager.createPlayer(loginname, password, name, parseInt(civ), email);
        res.render('login', { 
            message: { 
                type: 'success', 
                text: 'Account created successfully! Please check your email for validation code.' 
            } 
        });
    } catch (error) {
        res.render('register', { 
            message: { 
                type: 'error', 
                text: 'An error occurred during registration' 
            },
            civilizations: configManager.getAllCivilizations()
        });
    }
});

app.post('/login', async (req, res) => {
    const { loginname, password } = req.body;
    
    try {
        const result = await dataManager.authenticatePlayer(loginname, password);
        
        if (!result.success) {
            return res.render('login', { 
                message: { 
                    type: 'error', 
                    text: result.message || 'Invalid login name or password' 
                } 
            });
        }
        
        // Set session
        req.session.userId = result.player.id;
        req.session.loginname = result.player.loginname;
        
        res.redirect('/game');
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).render('login', { 
            message: { 
                type: 'error', 
                text: 'An error occurred during login' 
            } 
        });
    }
});

app.get('/logout', async (req, res) => {    
    req.session.destroy(err => {
        if (err) {
            console.error('Error destroying session:', err);
        }
        res.redirect('/');
    });
});

app.get('/game', requireAuth, async (req, res) => {
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
                land: playerData.land
            }
        });
    } catch (error) {
        console.error('Error loading game data:', error);
        res.status(500).render('error', { message: 'Error loading game data' });
    }
});

// Start server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
}); 