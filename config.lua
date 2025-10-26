Config = {}

-- Territory System Configuration

-- Territory settings - you can add as many territories as you want
-- Each territory has its own location, rewards, and capture time

Config.Teritorije = {
    -- Territory 1 - Coastal area near the military base
    {
        ime = "Territory 1",                    -- Display name on map
        pedModel = `a_m_m_afriamer_01`,         -- NPC model for territory
        pedCoord = vector4(-1427.9624, 2654.3782, 1.5294, 50.7043),  -- NPC position (x, y, z, heading)
        blipSprite = 175,                       -- Blip icon (175 = gang territory)
        blipBoja = 1,                           -- Blip color (1 = red)
        vrijemeZauzimanja = 5,                  -- Capture time in seconds (5 sec for testing)
        novacPoSatu = 50000,                    -- Money per hour for owners ($50,000)
        itemi = {                               -- Items given to player who captures
            { name = "weapon_specialcarbine", count = 5 },      -- Special Carbine weapon
            { name = "ammo-rifle", count = 350 }                -- Rifle ammo
        }
    },
    
    -- Territory 2 - Sandy Shores area
    {
        ime = "Territory 2", 
        pedModel = `a_m_m_afriamer_01`,
        pedCoord = vector4(1337.0525, 4392.8804, 43.3532, 170.0929),
        blipSprite = 175,
        blipBoja = 1,
        vrijemeZauzimanja = 300,                -- 5 minutes capture time
        novacPoSatu = 50000,
        itemi = {
            { name = "weapon_specialcarbine", count = 5 },
            { name = "ammo-rifle", count = 350 }
        }
    },
    
    -- Territory 3 - Mount Chiliad area
    {
        ime = "Territory 3",
        pedModel = `a_m_m_afriamer_01`,
        pedCoord = vector4(3291.9832, 3143.2717, 252.3050, 143.1239),
        blipSprite = 175,
        blipBoja = 1,
        vrijemeZauzimanja = 300,                -- 5 minutes capture time
        novacPoSatu = 50000,
        itemi = {
            { name = "weapon_specialcarbine", count = 5 },
            { name = "ammo-rifle", count = 350 }
        }
    },
    
    -- Territory 4 - Los Santos industrial area
    {
        ime = "Territory 4",
        pedModel = `a_m_m_afriamer_01`,
        pedCoord = vector4(-1845.0907, -1195.5562, 18.1842, 154.2360),
        blipSprite = 175,
        blipBoja = 1,
        vrijemeZauzimanja = 300,                -- 5 minutes capture time
        novacPoSatu = 50000,
        itemi = {
            { name = "weapon_specialcarbine", count = 5 },
            { name = "ammo-rifle", count = 350 }
        }
    }
}

-- Money payout interval (1 hour in milliseconds)
-- Territory owners receive money every hour based on novacPoSatu

Config.TimerNovaca = 60000 * 60

-- IMPORTANT NOTES FOR SERVER OWNERS:
-- 1. Make sure all weapon and item names exist in your inventory
-- 2. Territory 1 has 5-second capture time for testing - change to 300 for production
-- 3. Only players with jobs (not unemployed) can capture territories
-- 4. The player who captures gets personal item rewards + org gets money over time
-- 5. Set waypoint on territory blip on map and open pause menu to view territory info