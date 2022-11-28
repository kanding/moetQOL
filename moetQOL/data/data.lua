local _, ns	= ...
ns.Data	= {} -- add the core to the namespace ONLY ONCE

--non specific data
ns.Data.ERROR_BLACKLIST = {
    ["ERR_ABILITY_COOLDOWN"] = true,           -- Ability is not ready yet. (Ability)
    ["ERR_ITEM_COOLDOWN"] = true,
    ["ERR_SPELL_OUT_OF_RANGE"] = true,
    ["ERR_BADATTACKPOS"] = true,
    ["ERR_OUT_OF_ENERGY"] = true,              -- Not enough energy. (Err)
    ["ERR_OUT_OF_RANGE"] = true,
    ["ERR_OUT_OF_FURY"] = true,                -- Not enough fury.
    ["ERR_OUT_OF_RAGE"] = true,                -- Not enough rage.
    ["ERR_OUT_OF_FOCUS"] = true,               -- Not enough focus.
    ["ERR_ATTACK_MOUNTED"] = true,
    ["ERR_NO_ATTACK_TARGET"] = true,           -- There is nothing to attack.
    ["SPELL_FAILED_MOVING"] = true,
    ["SPELL_FAILED_AFFECTING_COMBAT"] = true,
    ["ERR_NOT_IN_COMBAT"] = true,
    ["SPELL_FAILED_UNIT_NOT_INFRONT"] = true,
    ["ERR_BADATTACKFACING"] = true,
    ["SPELL_FAILED_TOO_CLOSE"] = true,
    ["ERR_INVALID_ATTACK_TARGET"] = true,      -- You cannot attack that target.
    ["ERR_SPELL_COOLDOWN"] = true,             -- Spell is not ready yet. (Spell)
    ["SPELL_FAILED_NO_COMBO_POINTS"] = true,   -- That ability requires combo points.
    ["SPELL_FAILED_TARGETS_DEAD"] = true,      -- Your target is dead.
    ["SPELL_FAILED_SPELL_IN_PROGRESS"] = true, -- Another action is in progress. (Spell)
    ["SPELL_FAILED_TARGET_AURASTATE"] = true,  -- You can't do that yet. (TargetAura)
    ["SPELL_FAILED_CASTER_AURASTATE"] = true,  -- You can't do that yet. (CasterAura)
    ["SPELL_FAILED_NO_ENDURANCE"] = true,      -- Not enough endurance
    ["SPELL_FAILED_BAD_TARGETS"] = true,       -- Invalid target
    ["SPELL_FAILED_NOT_MOUNTED"] = true,       -- You are mounted
    ["SPELL_FAILED_NOT_ON_TAXI"] = true,       -- You are in flight
}

ns.Data.DRAGONLANDS_GOSSIP = {
    --Might change later but simple check for now.
    MinLevel = 60,
    MaxLevel = 69,

    --Orgrimmar
    ["Ebyssian"] = {choice=1},
    ["Boss Magor"] = {choice=1},
    ["Cataloger Coralie"] = {choice=1},
    ["Pathfinder Tacha"] = {choice=1},
    ["Kodethi"] = {choice=1},
    ["Archmage Khadgar"] = {choice=1},
    
    --Waking Shores
    ["Ambassador Fastrasz"] = {choice=2}, --assuming hs counts
    ["Embassy Visitor Log"] = {choice=1},
    ["Sendrax"] = {choice=1, phrase={"Why aren't the dragons here", "Send the signal flare", "Lead me to Dragonheart"}}, --fix 3
    ["Talonstalker Kavia"] = {choice=1},
    ["Right"] = {choice=1},
    ["Left"] = {choice=1},
    ["Majordomo Selistra"] = {choice={1,3}},
    ["Alexstrasza The Life-Binder"] = {choice=1},
    ["Xius"] = {choice=1},
    ["Akxall"] = {choice=1},
    ["Mother Elion"] = {choice=1},
    ["Thomas Bright"] = {choice=1},
    ["Lifecaller Tzadrak"] = {choice=1}, --HS ruby life
    ["Veritistrasz"] = {choice=2}, 
    ["Sabellian"] = {choice=1},
    ["Celormu"] = {choice=1},
    ["Zahkrana"] = {choice=1},
    ["Lord Andestrasz"] = {choice=1},
    ["Lithragosa"] = {choice=2},
    ["Scalecommander Emberthal"] = {choice=1},
    ["Tong the Fixer"] = {choice=3}, -- sets hearth?
    ["Archivist Edress"] = {choice=1},
    ["Forgemaster Bazentus"] = {choice=1},
    ["Fao the Relentless"] = {choice=1},
    ["Blacktalon Avenger"] = {choice=1},
    ["Blacktalon Assassin"] = {choice=1},
    ["Wrathion"] = {choice=1},
    --Don't use wrathion ride option for 1st part of quest, use mount
    ["Baskilan"] = {choice=1},
    ["Alexstrasza the Life-Binder"] = {choice=1},
    ["Beleaguered Explorer"] = {choice=1},
    ["Elementalist Taiyang"] = {choice=1},

    --Ohn'ahran Plains
    ["Sansok Khan"] = {choice=1},
    ["Mirojin"] = {choice=1}, --hs ohinir
    ["Aru"] = {choice=1},
    ["Belika"] = {choice=1},
    ["Beastmaster Nuqut"] = {choice=1},
    ["Ohn Seshteng"] = {choice=1, phrase="I am ready"},
    ["Scout Tomul"] = {choice=1},
    --Centaur caravan chain skippable escorts
    ["Nokhud Fighter"] = {choice=1},
    ["Nokhud Spearthrower"] = {choice=1},
    ["Nokhud Brute"] = {choice=1},
    ["Gemisath"] = {phrase="I am here to help"},
    ["Khansguard Akato"] = {choice=1},
    ["Quartermaster Gensai"] = {choice=1},
    ["Scout Khenyug"] = {choice=1},
    ["Herbalist Agura"] = {choice=1},
    ["Khansguard Hojin"] = {choice=1},
    ["Boku's Belongings"] = {choice=1},
    ["Unidentified Centaur"] = {choice=1},
    ["Himia, The Blessed"] = {choice=1},
    --Think it was at this point set hearth at Ohn'iri springs to avoid awful backtrack?
    ["Khanam Matra Sarest"] = {choice={1,3}},
    --Dismount green dargon and fly
    ["Guard-Captain Alowen"] = {choice=1},
    ["Sidra the Mender"] = {choice=1},
    ["Sariosa"] = {choice=2},
    ["Viranikus"] = {choice=1},
    ["Boku"] = {choice=1},
    ["Merithra"] = {choice=1},
    ["Gerithus"] = {choice=1},
    ["Tigari Khan"] = {choice=3},

    --Azure Span
    ["Vel Tal IX"] = {choice=1}, -- sets hearth
    ["Korrikunit the Whalebringer"] = {choice=1},
    ["Supply Portal"] = {choice=1},
    ["Jokomuupat"] = {choice=1},
    ["Babunituk"] = {choice=1},
    ["Brena"] = {choice=1},
    ["Akiun"] = {choice=1},
    ["Tuskarr Fisherman"] = {choice=1},
    ["Tuskarr Hunter"] = {choice=1},
    ["Tuskarr Craftsman"] = {choice=1},
    ["Festering Gnoll"] = {choice=1},
    ["Rotting Root"] = {choice=1},
    ["Kalecgos"] = {choice=1},
    --Elder Nappa ez quest, don't set hearth
    ["Elder Poa"] = {choice=1}, -- {choice=1} repeatedly
    ["Sindragosa"] = {choice=1},
    ["Lingering Image"] = {choice=1},
    ["Julk"] = {choice=1},
    ["Old Grimtusk"] = {choice=1},
    ["Alia Sunsoar"] = {choice=1},
    ["Mysterious Apparition"] = {choice=1},
    ["Valthrux"] = {choice=1},

    --Valdrakken
    ["Tithris"] = {choice=1}, --set hearth
    ["Valdrakken Citizen"] = {choice=1},
    ["Badly Injured Guardian"] = {choice=1},
    ["Mangled Corpse"] = {choice=1},
    ["Private Shikzar"] = {choice=1},
    ["Guardian Velomir"] = {choice=1},
    ["Chromie"] = {choice=1, phrase="Tell Chromie you're ready"},
    ["Andantenormu"] = {choice=1},
    ["Siaszerathel"] = {choice=1},
    ["Aeonormu"] = {choice=1},
    ["Soridormi"] = {choice=1},
    ["Nozdormu"] = {choice=1},
    ["Aesthis"] = {choice=1},
}

ns.Data.SHADOWLANDS_GOSSIP = {
    --Might change later but simple check for now.
    MinLevel = 48,
    MaxLevel = 59,

    --Maw
    ["Nazgrim"] = {choice=1},
    ["Lady Jaina Proudmoore"] = {choice=1},
    ["Highlord Darion Mograine"] = {choice=1},
    ["Ve'nari"] = {choice=1},
    ["Alexandros Mograine"] = {choice=1},

    --Bastion
    ["Kleia"] = {choice=1},
    ["Greeter Mnemis"] = {choice=1},
    ["Sika"] = {choice=1},
    ["Sparring Aspirant"] = {choice=1},
    ["Kalisthene"] = {choice=1},
    ["Disciple Fotima"] = {choice=1},
    ["Disciple Lykaste"] = {choice=1},
    ["Disciple Helene"] = {choice=1},
    ["Vulnerable Aspirant"] = {choice=1},
    ["Eridia"] = {choice=1},
    ["Fallen Disciple Nikolon"] = {choice=1},
    ["Disciple Kosmas"] = {choice=1},
    ["Vesiphone"] = {choice=1},
    ["Mikanikos"] = {choice=1},
    ["Polemarch Adrestes"] = {choice=1},
    ["Thanikos"] = {choice=1},
    ["Caretaker Mirene"] = {choice=1}, --innkeep set hearthstone
    ["Akiris"] = {{choice={1,2}}, --fast pick steward

    --Maldraxxus
    ["Arena Spectator"] = {choice=1},
    ["Baroness Draka"] = {choice=1},
    ["Baron Vyraz"] = {choice=1},
    ["Chosen Protector"] = {choice=1},
    ["Head Summoner Perex"] = {choice=1},
    ["Drill Sergeant Telice"] = {choice=1},
    ["Secutor Mevix"] = {choice=1},
    ["Bonesmith Heirmir"] = {choice=1},
    ["Vial Master Lurgy"] = {choice=1},
    ["Foul-Tongue Cyrlix"] = {choice=1},
    ["Boil Master Yetch"] = {choice=1},
    ["Baroness Vashj"] = {choice={1,2}},
    ["Aspirant Thales"] = {choice=1},
    ["Salvaged Praetor"] = {choice=1},
    ["Gunn Gorgebone"] = {choice=1},
    ["Scrapper Minoire"] = {choice=1},
    ["Rencissa the Dynamo"] = {choice=1},
    ["Marcel Mullby"] = {choice=2},
    ["Tester Sahaari"] = {choice=1},
    ["Valuator Malus"] = {choice=1},
    ["Ta'eran"] = {choice=1},
    ["Odew Testan"] = {choice=1}, --set hearthstone battlefield

    --Ardenweald
    ["Hunt-Captain Korayn"] = {choice=1},
    ["Lady Moonberry"] = {choice=1,2}},
    ["Featherlight"] = {choice={1,2}},
    ["Korenth"] = {choice=1},
    ["Te'zan"] = {choice=1},
    ["Wagonmaster Derawyn"] = {choice=1},
    ["Nelwyn"] = {choice=1},
    ["\"Granny\""] = {choice=1},
    ["Dreamweaver"] = {choice={2,3}},
    ["Ara'lon"] = {choice=1},
    ["Rury"] = {choice=1},
    ["Awool"] = {choice=1},
    ["Slanknen"] = {choice=1},
    ["Groonoomcrooek"] = {choice=1},
    ["Elder Finnan"] = {choice=1},
    ["Elder Gwenna"] = {choice=1},
    ["Niya"] = {choice=1},
    ["Proglo"] = {choice=1},
    ["Dreamer's Vision"] = {choice=1},
    ["Droman Aliothe"] = {choice=1},
    ["Winter Queen"] = {choice=1},
    ["Taiba"] = {choice=2}, --Innkeeper hibernal
    ["Nolon"] = {choice=2}, --Innkeeper first place

    --Revendreth
    ["Lord Chamberlain"] = {choice=1},
    ["Sire Denathrius"] = {choice=2},
    ["Courier Araak"] = {choice={1,2}},
    ["Tubbins"] = {choice={1,2}},
    ["Theotar"] = {choice=1},
    ["Projection of Prince Renathal"] = {choice=1},
    ["Courier Rokalai"] = {choice=2},
    ["Soul of Keltesh"] = {choice=1},
    ["Globknob"] = {choice=1},
    ["Ilka"] = {choice=1},
    ["Samu"] = {choice=1},
    ["Darkhaven Villager"] = {choice=1},
    ["Cobwobble"] = {choice=1},
    ["Dobwobble"] = {choice=1},
    ["Slobwobble"] = {choice=1},
    ["Sinreader Nicola"] = {choice=1},
    ["The Fearstalker"] = {choice=1},
    ["The Accuser"] = {choice=1},
    ["Venthyr Writing Desk"] = {choice=1}, -- (not a unit)
    ["Prince Renathal"] = {choice=1},
    ["Tremen Winefang"] = {choice=1}, --innkeeper Darkhaven

    --Oribos
    ["Protector Captain"] = {choice=1},
    ["Overseer Kah-Delen"] = {choice=1},
    ["Tal-Inara"] = {choice=1},
    ["Ebon Blade Acolyte"] = {choice=1},
    ["Foreman Au'brak"] = {choice=1},
    ["Caretaker Kah-Rahm"] = {choice=1},
    ["Host Ta'rela"] = {choice=3},
    ["Fatescribe Roh-Tahl"] = {choice=1},
    ["Overseer Ta'readon"] = {choice=1},
    ["Overseer Kah-Sher"] = {choice=1},
    ["Pathscribe Roh-Avonavi"] = {choice=1},
}