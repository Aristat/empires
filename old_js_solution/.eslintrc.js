module.exports = {
    env: {
        node: true,
        es2021: true,
        jest: true,
    },
    extends: 'airbnb-base',
    parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
    },
    rules: {
        indent: ['error', 4],
        'linebreak-style': ['error', 'unix'],
        quotes: ['error', 'single'],
        semi: ['error', 'always'],
        'no-console': 'off',
        'import/no-extraneous-dependencies': ['error', {
            devDependencies: ['**/*.test.js', '**/*.spec.js'],
        }],
    },
};
