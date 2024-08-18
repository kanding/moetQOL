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

--Quests will not be auto accepted if they are on this list by name or id
--They will still be completed.
ns.Data.AUTOQUESTBLACKLIST_ACCEPT = {
    ["Brax's Brass Knuckles"] = true,
}

ns.Data.AUTOQUESTBLACKLIST_COMPLETION = {
}

ns.Data.GOSSIPBLACKLIST = {
    ["Yes. I'm ready to observe the Ascendance Day speech."] = true,
}

ns.Data.WARLANDS_GOSSIP = {
    MinLevel = 70,
    MaxLevel = 79,

    --DALARAN
    ["Archmage Khadgar"] = {phrase = {"I'll wait for you here", "I'm ready to depart", "What do you need me to do"}},
    ["Elise Starseeker"] = {phrase = {"Brann wanted me to check"}},
    ["Magni Bronzebeard"] = {phrase = {"I'm ready", "I am ready to go"}},

    -- ISLE OF DORN BEGIN
    --Stones of Dornogal quest
    ["Thrall"] = {phrase = {"What is the plan"}},
    ["Oathsworn Peacekeeper"] = {questName = "Stones of Dornogal", phrase = "Profession Trainer"},
    ["Breem"] = {choice=2,phrase = "Introduce yourself"}, --<Introduce yourself with Councilward's Signet.>
    ["Ronesh"] = {choice=1,phrase = "Introduce yourself"},
    -- Ronesh also if set hearthstone option 1 (will clash with quest) yes we set hs
    ["Brann Bronzebeard"] = {phrase={"You made it, Brann", "Let's go save the earthen", "What will you do now?", "Moira needs you both"}},
    ["Merrix"] = {phrase = {"Tell me another time", "Let's do it"}},
    ["Pottery Jar"] = {choice=1},
    ["Kaldrinn"] = {choice=1},
    ["Adelgonn"] = {phrase = {"Are you Adelgonn", "We can give them the details later"}},
    ["Betta"] = {choice=1},
    ["Garrak"] = {choice=1},
    ["Maluc"] = {choice=1},
    ["Kodun"] = {choice=1, phrase="Hand over the pottery"},
    ["Kurron"] = {choice=1},
    ["Opalcreg Worker"] = {choice=1},
    ["Explorers' League Supplies"] = {choice=1},
    ["Foreman Pivk"] = {choice=1, phrase={"I'll guard the cart", "Let's get this cart moving"}},
    ["Eiggard"] = {choice=1},
    ["Merrimack"] = {choice=1},
    ["Bertola"] = {choice=1},
    ["Findorn"] = {choice=1}, --(1,Carry Findorn to the pool)
    ["Ebona"] = {choice=1}, -- (1,How is Ebona doing?)
    ["Urtago"] = {choice=1}, -- (1,It is done.)
    ["Korgran"] = {choice=1}, -- (1,I am ready to begin)
    ["Rancher Tofstrun"] = {choice=1},
    ["Rancher Fuoleim"] = {choice=1},
    ["Rancher Kiespuch"] = {choice=1},
    ["Harmot"] = {choice=1},
    ["Baelgrim"] = {phrase = {"Let's go. <Queue for follower dungeon.>", "Skip conversation", "I have finished setting up"}}, -- quest: Calling the Stormriders, choice = 1, and quest: Lasting Repairs, count = 2
    -- ISLE OF DORN END

    -- THE RINGING DEEPS
    ["Innkeeper Brax"] = {phrase = {"Make this inn"}},-- set hearth
    ["Speaker Brinthe"] = {phrase = {"Who is this"}},
    ["Igram Underwing"] = {phrase = {"Are you Underwing"}},
    ["Speaker Jurlax"] = {phrase = {"Speaker Jurlax"}},
    ["Watcher Toki"] = {choice = 1, questName = "Cogs in the Machine"},
    ["Emergency Militia"] = {phrase = "Speaker Brinthe and I are going to investigate"},
    ["Skitter"] = {phrase = {"I'm ready to retrieve", "Let's get out of here"}}, -- maybe not ? if queue
    ["Concerned Machine Speaker"] = {choice = 1},
    ["Agitated Machine Speaker"] = {choice = 1},
    ["Scrit"] = {phrase = {"Give the Sticky Wax to Scrit"}},
    ["Berrund the Gleaming"] = {choice = 1},
    ["Nebb"] = {phrase = {"Give Nebb the Queen's venom"}},
    ["Resting Miner"] = {choice = 1},
    ["Foreman Gesa"] = {choice = 1},
    ["Foreman Otan"] = {choice = 1},
    ["Moira Thaurissan"] = {phrase = {"I'm ready"}},

    --HALLOWFALL
    ["Anduin Wrynn"] = {phrase = {"I'm ready"}},
    ["Flight Observer Viktorina"] = {phrase = {"Have you seen Sophietta"}},
    ["Errick Ryston"] = {phrase = {"Seen Edwyn?"}},
    ["Headmaster Fynch"] = {phrase = {"Have you seen Edwyn?"}},
    ["Engineering Instructor Morgaen"] = {phrase = {"Did Edwyn come through here?"}},
    ["Edwyn Wyndsmithe"] = {phrase = {"Sophietta needs her notebook"}},
    ["Faerin Lothar"] = {phrase = {"Look closer at the tower", "Tell Faerin what you learned", "I'm ready"}},
    ["Kelther Hearthen"] = {choice = 1},
    ["Velhanite Citizen"] = {choice = 1},
    ["Velhanite Child"] = {choice = 1},
    ["Maximillian Velhan"] = {phrase = {"Don't worry"}},
    ["Auralia Steelstrike"] = {phrase = {"I can contact the Trading Post"}},
    ["Letter of Recommendation"] = {choice = 1},
    ["Shinda Creedpike"] = {phrase = {"I don't have time for this"}},
    ["Nalina Ironsong"] = {phrase = {"Purchase a round of drinks"}},
    ["Arathi Reserve"] = {choice = 1},
    ["Arathi Orphan"] = {choice = 1},
    ["Alleria Windrunner"] = {phrase = {"Bring down the bubble"}},
    ["Arathi Stalwart"] = {choice = 1},
    ["Taenar Strongoth"] = {phrase = {"Let's light the Sacred Flame"}},

    --AZJKAHET
    ["Orweyna"] = {phrase = {"Where do we go from here"}},
    ["Widow Arak'nai"] = {sequence={
        questId = 78392,
        -- map objective index to gossip
        talkMap = {
            [1] = "Tell me about yourself",
            [2] = "Tell me about the enemy forces",
            [3] = "Tell me about the Ascended",
            [4] = "Tell me about the Queen's inner circle"
        }
    }, phrase = {"I need to inform you", "Begin Severed Threads conference"}},
    ["Flynn Fairwind"] = {phrase = {"Look where Flynn"}},
    ["Monte Gazlowe"] = {phrase = {"Nudge Gazlowe", "I am ready"}},
    ["High Arcanist Savor"] = {phrase = {"Hello?", "Have you seen Anduin?", "Meet up at the transport wagons"}},
    ["Wriggling Web"] = {choice = 1},
    ["Siegehold Gateminder"] = {choice = 1},
    ["Executor Nizrek"] = {phrase = {"The Weaver wants to take out"}},
    ["Nana Lek'kel"] = {phrase = {"Me? Why?", "Step away"}},
    ["Klaskin"] = {phrase = {"Are you Arax'ne's husband", "Motion for Klaskin to follow"}},
    ["On'hiea"] = {choice = 1},
    ["Ney'leia"] = {choice = 1},
    ["Ysabel Gleamgaard"] = {phrase = {"Ney'leia says they are not offended", "Of course"}},
    ["Baer"] = {choice = 2},
    ["Worker Yareh'losh"] = {choice = 1},
    ["Hannan"] = {phrase = {"Tell Hannan to follow you out of the cave"}},
    ["Sammy Fizzvolt"] = {choice = 1},
    ["Murfie"] = {phrase = {"What can you tell me about the goblins here"}},
    ["Grigg"] = {phrase = {"What can you tell me about the goblins here"}},
    ["Jenni Boombuckle"] = {phrase = {"Are you in charge here"}},
    ["Ren'khat"] = {choice = 1},
    ["Grand Overspinner Antourix"] = {choice = 1},
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