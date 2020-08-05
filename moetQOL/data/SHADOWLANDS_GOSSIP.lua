local _, ns	= ...
ns.Data	= {} -- add the core to the namespace

--[[
    ["NPC NAME"] = GOSSIP_OPTION

    Gossip option number is seperate from quests.
    So one talk/speech bubble option = 1, regardless
    of whether or not there are quests to pickup/hand-in

    Run:
    /run print(C_GossipInfo.GetNumOptions())

    with talking frame open.
]]

ns.Data.SHADOWLANDS_GOSSIP = {
    --Maw
    ["Nazgrim"] = 1,
    ["Lady Jaina Proudmoore"] = 1,
    ["Highlord Darion Mograine"] = 1,

    --Bastion
    ["Kleia"] = 1,
    ["Greeter Mnemis"] = 1,
    ["Sika"] = 1,
    ["Sparring Aspirant"] = 1,
    ["Kalisthene"] = 1,
    ["Disciple Fotima"] = 1,
    ["Disciple Lykaste"] = 1,
    ["Disciple Helene"] = 1,

    --Maldraxxus
    ["Arena Spectator"] = 1,

    --Ardenweald
    ["Hunt-Captain Korayn"] = 1,
    ["Lady Moonberry"] = {1,2},
    ["Featherlight"] = {1,2},
    ["Korenth"] = 1,
    ["Te'zan"] = 1,
    ["Wagonmaster Derawyn"] = 1,
    ["Nelwyn"] = 1,
    ["\"Granny\""] = 1,
    ["Dreamweaver"] = 3,
    ["Ara'lon"] = 1,

    --Revendreth
    ["Lord Chamberlain"] = 1,
    ["Sire Denathrius"] = 2,
    ["Courier Araak"] = 2,
    ["Tubbins"] = 2,
    ["Theotar"] = 1,
    ["Projection of Prince Renathal"] = 1,

    --Oribos

}