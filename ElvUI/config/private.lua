local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Locked Settings, These settings are stored for your character only regardless of profile options.

V['general'] = {
	['loot'] = true,
	['lootRoll'] = true,
	["normTex"] = "ElvUI Norm",
	["glossTex"] = "ElvUI Norm",
	["dmgfont"] = "ElvUI Combat",
	["namefont"] = "ElvUI Font",
	['chatBubbles'] = 'backdrop',
	['chatBubbleFont'] = "ElvUI Font",
	['chatBubbleFontSize'] = 14,
	['pixelPerfect'] = true,
	['lfrEnhancement'] = true,
	['replaceBlizzFonts'] = true,
	['smallerWorldMap'] = true,
	['minimap'] = {
		['enable'] = true,
		['hideGarrison'] = true,
		['hideCalendar'] = true,
	},
}

V['bags'] = {
	['enable'] = true,
	['bagBar'] = false,
}

V["nameplate"] = {
	["enable"] = true,
}

V['auras'] = {
	['enable'] = true,
	['disableBlizzard'] = true,
	
	["masque"] = {
		["buffs"] = false,
		["debuffs"] = false,
		["consolidatedBuffs"] = false,
	},
}

V['chat'] = {
	['enable'] = true,
}

V['skins'] = {
	['ace3'] = {
		['enable'] = true,
	},
	['blizzard'] = {
		['enable'] = true,
		['achievement'] = true,
		['achievement_popup'] = true,
		['archaeology'] = true,
		['arena'] = true,
		['arenaregistrar'] = true,
		['auctionhouse'] = true,
		['bags'] = true,
		['barber'] = true,
		['bgmap'] = true,
		['bgscore'] = true,
		['binding'] = true,
		['calendar'] = true,
		['character'] = true,
		['debug'] = true,
		['dressingroom'] = true,
		['encounterjournal'] = true,
		['friends'] = true,
		['gbank'] = true,
		['glyph'] = true,
		['gossip'] = true,
		['greeting'] = true,
		['guildregistrar'] = true,
		['help'] = true,
		['inspect'] = true,
		['lfd'] = true,
		['lfguild'] = true,
		['lfr'] = true,
		['macro'] = true,
		['mail'] = true,
		['merchant'] = true,
		['mirrorTimers'] = true,
		['misc'] = true,
		['petition'] = true,
		['pvp'] = true,
		['quest'] = true,
		['raid'] = true,
		['reforge'] = true,
		['socket'] = true,
		['spellbook'] = true,
		['stable'] = true,
		['tabard'] = true,
		['talent'] = true,
		['taxi'] = true,
		['timemanager'] = true,
		['trade'] = true,
		['tradeskill'] = true,
		['trainer'] = true,
		['transmogrification'] = true,
		['voidstorage'] = true,
		['worldmap'] = true,
	},
}

V['tooltip'] = {
	['enable'] = true,
}

V['unitframe'] = {
	['enable'] = true,
	['disabledBlizzardFrames'] = {
		['player'] = true,
		['target'] = true,
		['focus'] = true,
		['boss'] = true,
		['arena'] = true,
		['party'] = true,
		['raid'] = true,
	},
}

V["actionbar"] = {
	["enable"] = true,

	["masque"] = {
		["actionbars"] = false,
		["petBar"] = false,
		["stanceBar"] = false,
	},
}

V["cooldown"] = {
	enable = true
}