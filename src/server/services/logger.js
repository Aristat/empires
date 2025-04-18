const winston = require('winston');
const path = require('path');

// Define log levels
const levels = {
    error: 0,
    warn: 1,
    info: 2,
    http: 3,
    debug: 4,
};

// Define log colors
const colors = {
    error: 'red',
    warn: 'yellow',
    info: 'green',
    http: 'magenta',
    debug: 'white',
};

// Add colors to winston
winston.addColors(colors);

// Define log format
const format = winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
    winston.format.colorize({ all: true }),
    winston.format.errors({ stack: true }),
    winston.format.printf((info) => {
        let message = `${info.timestamp} ${info.level}: ${info.message}`;
        
        if (info.error && info.error.stack) {
            message += `\n${info.error.stack}`;
        } else if (info.stack) {
            message += `\n${info.stack}`;
        }
        
        return message;
    }),
);

const transports = [
    new winston.transports.Console(),
];

// Create the logger
const logger = winston.createLogger({
    level: process.env.NODE_ENV === 'development' ? 'debug' : 'info',
    levels,
    format,
    transports,
});

logger.stream = {
    write: (message) => logger.http(message.trim()),
};

const originalError = logger.error;
logger.error = function(msg, error) {
    if (error instanceof Error) {
        return originalError.call(this, msg, { error });
    }
    return originalError.call(this, msg);
};

module.exports = logger; 