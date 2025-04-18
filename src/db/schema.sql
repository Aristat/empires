CREATE TABLE IF NOT EXISTS players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    loginname TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT NOT NULL,
    civ INTEGER NOT NULL,
    email TEXT,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    validated BOOLEAN DEFAULT 0,
    validation_code TEXT,
    last_load DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_admin BOOLEAN DEFAULT 0,
    alliance_id INTEGER,
    score INTEGER DEFAULT 0,
    turn INTEGER DEFAULT 0,
    turns_free INTEGER DEFAULT 100,
    last_turn DATETIME DEFAULT CURRENT_TIMESTAMP,
    killed_by INTEGER DEFAULT 0,
    killed_by_name TEXT,
    FOREIGN KEY (alliance_id) REFERENCES alliances(id)
);

CREATE TABLE IF NOT EXISTS login_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address TEXT,
    http_referer TEXT,
    http_user_agent TEXT,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS resources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    gold INTEGER DEFAULT 1000,
    food INTEGER DEFAULT 500,
    wood INTEGER DEFAULT 300,
    iron INTEGER DEFAULT 200,
    tools INTEGER DEFAULT 100,
    wine INTEGER DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS buildings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    type TEXT NOT NULL,
    level INTEGER DEFAULT 1,
    status INTEGER DEFAULT 1,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS military (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    soldiers INTEGER DEFAULT 0,
    archers INTEGER DEFAULT 0,
    cavalry INTEGER DEFAULT 0,
    macemen INTEGER DEFAULT 0,
    catapults INTEGER DEFAULT 0,
    trained_peasants INTEGER DEFAULT 0,
    thieves INTEGER DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS military_equipment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    swords INTEGER DEFAULT 0,
    bows INTEGER DEFAULT 0,
    horses INTEGER DEFAULT 0,
    maces INTEGER DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS land (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    farm_land INTEGER DEFAULT 0,
    mine_land INTEGER DEFAULT 0,
    plain_land INTEGER DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS research (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    attack_points INTEGER DEFAULT 0,
    defense_points INTEGER DEFAULT 0,
    thieves_strength INTEGER DEFAULT 0,
    military_losses INTEGER DEFAULT 0,
    food_production INTEGER DEFAULT 0,
    mine_production INTEGER DEFAULT 0,
    weapons_production INTEGER DEFAULT 0,
    space_effectiveness INTEGER DEFAULT 0,
    markets_output INTEGER DEFAULT 0,
    explorers INTEGER DEFAULT 0,
    catapults_strength INTEGER DEFAULT 0,
    wood_production INTEGER DEFAULT 0,
    current_research INTEGER DEFAULT 0,
    research_points INTEGER DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS alliances (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    tag TEXT UNIQUE NOT NULL,
    leader_id INTEGER,
    password TEXT,
    news TEXT,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (leader_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS alliance_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alliance_id INTEGER,
    player_id INTEGER,
    member_type INTEGER DEFAULT 0,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (alliance_id) REFERENCES alliances(id),
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS alliance_relations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    alliance_id INTEGER,
    related_alliance_id INTEGER,
    relation_type INTEGER DEFAULT 0, -- 0: neutral, 1: ally, 2: war
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (alliance_id) REFERENCES alliances(id),
    FOREIGN KEY (related_alliance_id) REFERENCES alliances(id)
);

CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_player_id INTEGER,
    to_player_id INTEGER,
    from_player_name TEXT,
    to_player_name TEXT,
    message TEXT,
    viewed BOOLEAN DEFAULT 0,
    message_type INTEGER DEFAULT 0,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_player_id) REFERENCES players(id),
    FOREIGN KEY (to_player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS attack_news (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    attack_id INTEGER,
    defense_id INTEGER,
    attack_alliance_id INTEGER,
    defense_alliance_id INTEGER,
    attack_soldiers INTEGER DEFAULT 0,
    attack_archers INTEGER DEFAULT 0,
    attack_cavalry INTEGER DEFAULT 0,
    attack_macemen INTEGER DEFAULT 0,
    attack_catapults INTEGER DEFAULT 0,
    attack_peasants INTEGER DEFAULT 0,
    attack_thieves INTEGER DEFAULT 0,
    defense_soldiers INTEGER DEFAULT 0,
    defense_archers INTEGER DEFAULT 0,
    defense_cavalry INTEGER DEFAULT 0,
    defense_macemen INTEGER DEFAULT 0,
    defense_catapults INTEGER DEFAULT 0,
    defense_peasants INTEGER DEFAULT 0,
    defense_thieves INTEGER DEFAULT 0,
    attacker_wins BOOLEAN DEFAULT 0,
    attack_type INTEGER DEFAULT 0,
    battle_details TEXT,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (attack_id) REFERENCES players(id),
    FOREIGN KEY (defense_id) REFERENCES players(id),
    FOREIGN KEY (attack_alliance_id) REFERENCES alliances(id),
    FOREIGN KEY (defense_alliance_id) REFERENCES alliances(id)
);

CREATE TABLE IF NOT EXISTS trade_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    wood INTEGER DEFAULT 0,
    food INTEGER DEFAULT 0,
    iron INTEGER DEFAULT 0,
    tools INTEGER DEFAULT 0,
    swords INTEGER DEFAULT 0,
    bows INTEGER DEFAULT 0,
    horses INTEGER DEFAULT 0,
    maces INTEGER DEFAULT 0,
    wine INTEGER DEFAULT 0,
    trade_type INTEGER DEFAULT 0,
    turns_remaining INTEGER DEFAULT 0,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS build_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    building_type TEXT NOT NULL,
    turns_remaining INTEGER DEFAULT 0,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
);

CREATE TABLE IF NOT EXISTS train_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER,
    unit_type TEXT NOT NULL,
    quantity INTEGER DEFAULT 0,
    turns_remaining INTEGER DEFAULT 0,
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(id)
); 