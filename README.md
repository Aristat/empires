# README

## History

In my free time I port the game from cloudfusion to rails. Original source code https://sourceforge.net/projects/ad1000/files/

## TODO list

- [x] Finish research mechanic
- [ ] Implement scores tables
- [ ] Implement train army logic
- [ ] Implement attack logic
- [ ] Implement glob trade market
- [ ] Refactoring magic constants in game, prepare documentation, formulas, etc
- [ ] Right now I use `Cursor` to generate FE/UI, need to refactor and improve better visibility
- [ ] Improve buildings and other tables to related per Game to be able run multiple different games with different settings
- [ ] Cover by specs and tests BE logic
- [ ] Cover by E2E tests FE logic
- [ ] Implement CI/CD and deploy to cloud solution like EC2/Heroku/other place by Docker container
- [ ] Implement LRU cache logic to reduce SQL queries
- [ ] Move translations to I18n to support multi languages
- [ ] Add lockers to avoid parallel data insert/update to database per user

## How to run the game

1. Clone the repository
2. Run `bundle install`
3. Run `rails db:create db:migrate db:seed`
4. Run `rails s`
5. Open your browser and go to `http://localhost:3000`
6. Join to game
