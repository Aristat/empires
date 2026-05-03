# Empires

A turn-based browser strategy game set in medieval times. Each turn represents one month of in-game time. Players build and grow their empire by gathering resources, constructing buildings, training armies, researching technologies, exploring new land, and competing against other players through trade, diplomacy, and warfare.

**Key features:**
- 8 playable civilizations, each with a unique special unit and stat bonuses/penalties
- Resource economy: gold, food, wood, iron, tools, wine, horses, and weapons
- Building queue system with configurable production percentages
- Army combat with score-ratio penalties, wine morale boosts, and repeated-attack diminishing returns
- Catapult and thief covert operations
- Global and local trade markets
- Great Wall defense system with decay mechanics
- 18 research types across military, production, and empire categories
- Seasonal production (farms idle in winter, wood heating required)
- In-game documentation system per game instance

Built with Ruby on Rails 7.1, PostgreSQL, Redis, Tailwind CSS.

## History

In my free time I port the game from cloudfusion to rails. Original source code https://sourceforge.net/projects/ad1000/files/

## TODO list

- [ ] Implement alliances
- [ ] Testing logic/balance with multiple users

## How to run the game

1. Clone the repository
2. Run `bundle install`
3. Run `rails db:create db:migrate db:seed`
4. Run `rails s`
5. Open your browser and go to `http://localhost:3000`
6. Join to game
