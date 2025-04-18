require('dotenv').config();
const express = require('express');
const session = require('express-session');
const SQLiteStore = require('connect-sqlite3')(session);
const path = require('path');
const dataManager = require('./data_manager');

// Import routes
const authRoutes = require('./routes/auth');
const gameRoutes = require('./routes/game');

dataManager.initializeDatabase();

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

// Use routes
app.use('/', authRoutes);
app.use('/', gameRoutes);

// Start server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
}); 