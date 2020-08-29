local _, ns	= ...

--[[
    ["NPC NAME"] = GOSSIP_OPTION

    Count ONLY speech bubble options.

    Run:
    /run print(C_GossipInfo.GetNumOptions())

    with talking frame open.
]]

ns.Data.SHADOWLANDS_GOSSIP = {
    --Maw
    ["Nazgrim"] = 1,
    ["Lady Jaina Proudmoore"] = 1,
    ["Highlord Darion Mograine"] = 1,
    ["Ve'nari"] = 1,
    ["Alexandros Mograine"] = 1,

    --Bastion
    ["Kleia"] = 1,
    ["Greeter Mnemis"] = 1,
    ["Sika"] = 1,
    ["Sparring Aspirant"] = 1,
    ["Kalisthene"] = 1,
    ["Disciple Fotima"] = 1,
    ["Disciple Lykaste"] = 1,
    ["Disciple Helene"] = 1,
    ["Vulnerable Aspirant"] = 1,
    ["Eridia"] = 1,
    ["Fallen Disciple Nikolon"] = 1,
    ["Disciple Kosmas"] = 1,
    ["Vesiphone"] = 1,
    ["Mikanikos"] = 1,
    ["Polemarch Adrestes"] = 1,
    ["Thanikos"] = 1,
    ["Caretaker Mirene"] = 1, --innkeep set hearthstone
    ["Akiris"] = 1, --fast pick steward

    --Maldraxxus
    ["Arena Spectator"] = 1,
    ["Baroness Draka"] = 1,
    ["Baron Vyraz"] = 1,
    ["Chosen Protector"] = 1,
    ["Head Summoner Perex"] = 1,
    ["Drill Sergeant Telice"] = 1,
    ["Secutor Mevix"] = 1,
    ["Bonesmith Heirmir"] = 1,
    ["Vial Master Lurgy"] = 1,
    ["Foul-Tongue Cyrlix"] = 1,
    ["Boil Master Yetch"] = 1,
    ["Baroness Vashj"] = {1,2},
    ["Aspirant Thales"] = 1,
    ["Salvaged Praetor"] = 1,
    ["Gunn Gorgebone"] = 1,
    ["Scrapper Minoire"] = 1,
    ["Rencissa the Dynamo"] = 1,
    ["Marcel Mullby"] = 2,
    ["Tester Sahaari"] = 1,
    ["Valuator Malus"] = 1,
    ["Ta'eran"] = 1,
    ["Odew Testan"] = 1, --set hearthstone battlefield

    --Ardenweald
    ["Hunt-Captain Korayn"] = 1,
    ["Lady Moonberry"] = {1,2},
    ["Featherlight"] = {1,2},
    ["Korenth"] = 1,
    ["Te'zan"] = 1,
    ["Wagonmaster Derawyn"] = 1,
    ["Nelwyn"] = 1,
    ["\"Granny\""] = 1,
    ["Dreamweaver"] = {2,3},
    ["Ara'lon"] = 1,
    ["Rury"] = 1,
    ["Awool"] = 1,
    ["Slanknen"] = 1,
    ["Groonoomcrooek"] = 1,
    ["Elder Finnan"] = 1,
    ["Elder Gwenna"] = 1,
    ["Niya"] = 1,
    ["Proglo"] = 1,
    ["Dreamer's Vision"] = 1,
    ["Droman Aliothe"] = 1,
    ["Winter Queen"] = 1,
    ["Taiba"] = 2, --Innkeeper hibernal
    ["Nolon"] = 2, --Innkeeper first place

    --Revendreth
    ["Lord Chamberlain"] = 1,
    ["Sire Denathrius"] = 2,
    ["Courier Araak"] = 2,
    ["Tubbins"] = 2,
    ["Theotar"] = 1,
    ["Projection of Prince Renathal"] = 1,
    ["Courier Rokalai"] = 2,
    ["Soul of Keltesh"] = 1,
    ["Globknob"] = 1,
    ["Ilka"] = 1,
    ["Samu"] = 1,
    ["Darkhaven Villager"] = 1,
    ["Courier Araak"] = 1,
    ["Cobwobble"] = 1,
    ["Dobwobble"] = 1,
    ["Slobwobble"] = 1,
    ["Sinreader Nicola"] = 1,
    ["The Fearstalker"] = 1,
    ["The Accuser"] = 1,
    ["Venthyr Writing Desk"] = 1, -- (not a unit)
    ["Tubbins"] = 1,
    ["Prince Renathal"] = 1,
    ["Tremen Winefang"] = 1, --innkeeper Darkhaven

    --Oribos
    ["Protector Captain"] = 1,
    ["Overseer Kah-Delen"] = 1,
    ["Tal-Inara"] = 1,
    ["Ebon Blade Acolyte"] = 1,
    ["Foreman Au'brak"] = 1,
    ["Caretaker Kah-Rahm"] = 1,
    ["Host Ta'rela"] = 1,
    ["Fatescribe Roh-Tahl"] = 1,
    ["Overseer Ta'readon"] = 1,
    ["Overseer Kah-Sher"] = 1,

}