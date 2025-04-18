require('dotenv').config();
const express = require('express');
const session = require('express-session');
const SQLiteStore = require('connect-sqlite3')(session);
const path = require('path');
const dataManager = require('./data_manager');

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
    if (req.session.userId) {
        res.redirect('/game');
    } else {
        res.render('login', { message: '' });
    }
});

app.get('/register', (req, res) => {
    res.render('register', { message: '' });
});

app.post('/register', async (req, res) => {
    const { loginname, password, name, civ, email } = req.body;
    
    try {
        const result = await dataManager.createPlayer(loginname, password, name, civ, email);
        res.render('login', { 
            message: { 
                type: 'success', 
                text: 'Account created successfully! Please check your email for validation code.' 
            } 
        });
    } catch (error) {
        res.render('register', { 
            message: { type: 'error', text: 'An error occurred during registration' } 
        });
    }
});

app.post('/login', async (req, res) => {
    const { loginname, password } = req.body;
    
    try {
        const user = await dataManager.authenticatePlayer(loginname, password);
        
        if (!user) {
            return res.render('login', { message: 'Invalid login name or password' });
        }
        
        // Update last load time and log login
        await dataManager.updateLastLoad(user.id);
        await dataManager.logLogin(
            user.id,
            req.ip,
            req.headers.referer || '',
            req.headers['user-agent'] || ''
        );
        
        // Set session
        req.session.userId = user.id;
        req.session.loginname = user.loginname;
        
        res.redirect('/game');
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).render('login', { message: 'An error occurred during login' });
    }
});

app.get('/logout', async (req, res) => {
    if (req.session.userId) {
        await dataManager.updateLastLoad(req.session.userId);
    }
    
    req.session.destroy(err => {
        if (err) {
            console.error('Error destroying session:', err);
        }
        res.redirect('/');
    });
});

app.get('/game', requireAuth, async (req, res) => {
    try {
        const [resources, buildings, military] = await Promise.all([
            dataManager.getPlayerResources(req.session.userId),
            dataManager.getPlayerBuildings(req.session.userId),
            dataManager.getPlayerMilitary(req.session.userId)
        ]);
        
        res.render('game', {
            user: {
                id: req.session.userId,
                loginname: req.session.loginname
            },
            resources,
            buildings,
            military
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