const express = require('express');
const session = require('express-session');
const SQLiteStore = require('connect-sqlite3')(session);
const path = require('path');

/**
 * Creates a configured Express app instance for testing
 * @param {Object} options - Configuration options
 * @param {boolean} [options.withSession=true] - Whether to include session middleware
 * @param {boolean} [options.withViews=true] - Whether to include view engine setup
 * @returns {Object} Configured Express app instance
 */
function createTestApp(options = {}) {
    const {
        withSession = true,
        withViews = true
    } = options;

    const app = express();
    
    // Basic middleware
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));

    // Session middleware
    if (withSession) {
        app.use(session({
            secret: 'test-secret',
            resave: false,
            saveUninitialized: false,
            store: new SQLiteStore({
                db: ':memory:',
                table: 'sessions',
            }),
        }));

        // Test session middleware
        app.use((req, res, next) => {
            if (req.headers['x-test-session']) {
                req.session.userId = 1;
                req.session.loginname = 'testuser';
            }
            next();
        });
    }

    // View engine setup
    if (withViews) {
        app.set('view engine', 'ejs');
        app.set('views', path.join(__dirname, '../../public/views'));
    }

    return app;
}

module.exports = {
    createTestApp
}; 