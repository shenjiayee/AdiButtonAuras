local _, ns = ...
ns = ns['__LibSpellbook-1.0']

local lib = ns.lib
if not lib then return end

local FoundSpell = ns.FoundSpell
local CleanUp    = ns.CleanUp

local supportedBookTypes = {
	covenant = true,
	pet      = true,
	pvp      = true,
	spell    = true,
	talent   = true,
}

local playerClass
local spellUpgrades = {
	DEATHKNIGHT = {
		{
			316575, -- Heart Strike (Rank 2) Blood 23
			316634, -- Blood Boil (Rank 2) Blood 24
			316746, -- Marrowrend (Rank 2) Blood 41
			316664, -- Death and Decay (Rank 2) Blood 43
			316616, -- Rune Tap (Rank 2) Blood 44
			316714, -- Veteran of the Third War (Rank 2) Blood 49
			317090, -- Heart Strike (Rank 3) Blood 52
			317133, -- Vampiric Blood (Rank 2) Blood 56
		}, -- [1]
		{
			343252, -- Might of the Frozen Wastes (Rank 2) Frost 24
			278223, -- Death Strike (Rank 2) Frost 28
			316794, -- Remorseless Winter (Rank 2) Frost 34
			316838, -- Rime (Rank 2) Frost 41
			316803, -- Frost Strike (Rank 2) Frost 43
			316849, -- Pillar of Frost (Rank 2) Frost 49
			317198, -- Obliterate (Rank 2) Frost 52
			317230, -- Empower Rune Weapon (Rank 2) Frost 56
			317214, -- Killing Machine (Rank 2) Frost 58
		}, -- [2]
		{
			316867, -- Festering Strike (Rank 2) Unholy 24
			278223, -- Death Strike (Rank 2) Unholy 28
			46584, -- Raise Dead (Rank 2) Unholy 29
			316941, -- Death Coil (Rank 2) Unholy 41
			316916, -- Death and Decay (Rank 2) Unholy 43
			316961, -- Apocalypse (Rank 2) Unholy 49
			325554, -- Dark Transformation (Rank 2) Unholy 52
			317234, -- Scourge Strike (Rank 2) Unholy 56
			343755, -- Apocalypse (Rank 3) Unholy 58
		}, -- [3]
		[5] = {
			343257, -- Death's Advance (Rank 2) Death Knight 49
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	DEMONHUNTER = {
		{
			320413, -- Chaos Strike (Rank 2) Havoc 14
			320422, -- Metamorphosis (Rank 2) Havoc 20
			320402, -- Blade Dance (Rank 2) Havoc 22
			320415, -- Eye Beam (Rank 2) Havoc 23
			320377, -- Immolation Aura (Rank 3) Havoc 27
			320383, -- Demonic Wards (Rank 2) Havoc 28
			320416, -- Fel Rush (Rank 2) Havoc 28
			320770, -- Unrestrained Fury (Rank 1) Havoc 32
			320407, -- Blur (Rank 2) Havoc 33
			320412, -- Chaos Nova (Rank 2) Havoc 38
			320635, -- Vengeful Retreat (Rank 2) Havoc 41
			343006, -- Unrestrained Fury (Rank 2) Havoc 43
			320654, -- Mastery: Demonic Presence (Rank 2) Havoc 44
			320420, -- Darkness (Rank 2) Havoc 47
			320421, -- Metamorphosis (Rank 3) Havoc 48
			343017, -- Fel Rush (Rank 3) Havoc 52
			320645, -- Metamorphosis (Rank 4) Havoc 54
			343206, -- Chaos Strike (Rank 3) Havoc 56
			343311, -- Eye Beam (Rank 3) Havoc 58
		}, -- [1]
		{
			321021, -- Soul Cleave (Rank 2) Vengeance 14
			321067, -- Metamorphosis (Rank 2) Vengeance 20
			320794, -- Sigil of Flame (Rank 2) Vengeance 22
			320378, -- Immolation Aura (Rank 3) Vengeance 27
			320639, -- Fel Devastation (Rank 2) Vengeance 23
			320381, -- Demonic Wards (Rank 2) Vengeance 28
			320791, -- Infernal Strike (Rank 2) Vengeance 28
			320387, -- Throw Glaive (Rank 3) Vengeance 32
			320418, -- Sigil of Misery (Rank 2) Vengeance 33
			320962, -- Fiery Brand (Rank 2) Vengeance 38
			321028, -- Demon Spikes (Rank 2) Vengeance 41
			320382, -- Demonic Wards (Rank 3) Vengeance 43
			321299, -- Mastery: Fel Blood (Rank 2) Vengeance 44
			320417, -- Sigil of Silence (Rank 2) Vengeance 48
			321068, -- Metamorphosis (Rank 3) Vengeance 48
			343016, -- Infernal Strike (Rank 3) Vengeance 52
			343010, -- Fiery Brand (Rank 3) Vengeance 54
			343207, -- Soul Cleave (Rank 3) Vengeance 56
		}, -- [2]
		[5] = {
			320364, -- Immolation Aura (Rank 2) Demon Hunter 18
			320386, -- Throw Glaive (Rank 2) Demon Hunter 19
			183782, -- Disrupt (Rank 2) Demon Hunter 29
			320313, -- Consume Magic (Rank 2) Demon Hunter 37
			320379, -- Spectral Sight (Rank 2) Demon Hunter 42
			320361, -- Disrupt (Rank 3) Demon Hunter 46
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	DRUID = {
		{
			231050, -- Sunfire (Rank 2) Balance 32
			328023, -- Moonfire (Rank 3) Balance 33
			231042, -- Moonkin Form (Rank 2) Balance 37
			328021, -- Eclipse (Rank 2) Balance 47
			327541, -- Starfall (Rank 2) Balance 54
			328022, -- Starsurge (Rank 2) Balance 58
		}, -- [1]
		{
			231057, -- Shred (Rank 2) Feral 36
			231052, -- Rake (Rank 2) Feral 39
			231283, -- Swipe (Rank 2) Feral 42
			231063, -- Shred (Rank 3) Feral 42
			231055, -- Tiger's Fury (Rank 2) Feral 47
			343232, -- Shred (Rank 4) Feral 54
			343223, -- Berserk (Rank 2) Feral 58
		}, -- [2]
		{
			270100, -- Bear Form (Rank 2) Guardian 12
			231070, -- Ironfur (Rank 2) Guardian 33
			273048, -- Frenzied Regeneration (Rank 2) Guardian 39
			231064, -- Mangle (Rank 2) Guardian 42
			328767, -- Survival Instincts (Rank 2) Guardian 47
			288826, -- Stampeding Roar (Rank 2) Guardian 49
			301768, -- Frenzied Regeneration (Rank 3) Guardian 54
			343240, -- Berserk (Rank 2) Guardian 58
		}, -- [3]
		{
			231040, -- Rejuvenation (Rank 2) Restoration 26
			231050, -- Sunfire (Rank 2) Restoration 32
			328025, -- Wild Growth (Rank 2) Restoration 49
			326228, -- Innervate (Rank 2) Restoration 52
			197061, -- Ironbark (Rank 2) Restoration 56
		}, -- [4]
		{
			326646, -- Moonfire (Rank 2) Druid 9
			159456, -- Travel Form (Rank 2) Druid 20
			327993, -- Barkskin (Rank 2) Druid 44
			328024, -- Rebirth (Rank 2) Druid 46
			231032, -- Regrowth (Rank 2) Druid 52
			343238, -- Entangling Roots (Rank 2) Druid 56
		}, -- [5]
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	HUNTER = {
		{
			231548, -- Bestial Wrath (Rank 2) Beast Mastery 34
			231546, -- Exhilaration (Rank 2) Beast Mastery 44
			262838, -- Cobra Shot (Rank 2) Beast Mastery 49
		}, -- [1]
		{
			321018, -- Steady Shot (Rank 2) Marksmanship 11
			321293, -- Arcane Shot (Rank 2) Marksmanship 14
			321281, -- Rapid Fire (Rank 2) Marksmanship 28
			231546, -- Exhilaration (Rank 2) Marksmanship 44
		}, -- [2]
		{
			321026, -- Wing Clip (Rank 2) Survival 13
			263186, -- Kill Command (Rank 2) Survival 28
			294029, -- Carve (Rank 2) Survival 32
			231550, -- Harpoon (Rank 2) Survival 38
			231546, -- Exhilaration (Rank 2) Survival 44
			321290, -- Wildfire Bombs (Rank 2) Survival 49
		}, -- [3]
		[5] = {
			343241, -- Aspect of the Cheetah (Rank 2) Hunter 46
			343242, -- Mend Pet (Rank 2) Hunter 52
			343244, -- Tranquilizing Shot (Rank 2) Hunter 54
			343247, -- Improved Traps (Rank 2) Hunter 56
			343248, -- Kill Shot (Rank 2) Hunter 58
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	MAGE = {
		{
			321752, -- Arcane Explosion (Rank 2) Arcane 18
			321758, -- Clearcasting (Rank 2) Arcane 23
			231564, -- Arcane Barrage (Rank 2) Arcane 31
			321420, -- Clearcasting (Rank 3) Arcane 32
			321747, -- Slow (Rank 2) Arcane 38
			343208, -- Arcane Power (Rank 2) Arcane 41
			231565, -- Evocation (Rank 2) Arcane 43
			343215, -- Touch of the Magi (Rank 2) Arcane 46
			321745, -- Prismatic Barrier (Rank 2) Arcane 48
			321526, -- Arcane Barrage (Rank 3) Arcane 52
			321742, -- Presence of Mind (Rank 2) Arcane 54
			321739, -- Arcane Power (Rank 3) Arcane 56
		}, -- [1]
		{
			231568, -- Fire Blast (Rank 2) Fire 18
			157642, -- Fireball (Rank 2) Fire 33
			231567, -- Fire Blast (Rank 4) Fire 37
			321707, -- Dragon's Breath (Rank 2) Fire 38
			343194, -- Fireball (Rank 3) Fire 41
			343230, -- Flamestrike (Rank 2) Fire 43
			343222, -- Phoenix Flames (Rank 2) Fire 46
			231630, -- Critical Mass (Rank 2) Fire 47
			321708, -- Blazing Barrier (Rank 2) Fire 48
			321709, -- Flamestrike (Rank 3) Fire 52
			321711, -- Pyroblast (Rank 2) Fire 54
			321710, -- Combustion (Rank 2) Fire 56
		}, -- [2]
		{
			231582, -- Shatter (Rank 2) Frost 27
			343175, -- Ice Lance (Rank 2) Frost 33
			231584, -- Brain Freeze (Rank 2) Frost 37
			343177, -- Frostbolt (Rank 2) Frost 41
			343180, -- Cone of Cold (Rank 2) Frost 43
			343183, -- Frost Nova (Rank 2) Frost 46
			236662, -- Blizzard (Rank 2) Frost 47
			321684, -- Mastery: Icicles (Rank 2) Frost 48
			321696, -- Blizzard (Rank 3) Frost 52
			321699, -- Cold Snap (Rank 2) Frost 54
			321702, -- Icy Veins (Rank 2) Frost 56
		}, -- [3]
		[5] = {
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	MONK = {
		{
			322522, -- Stagger (Rank 2) Brewmaster 26
			322700, -- Spinning Crane Kick (Rank 2) Brewmaster 33
			231602, -- Vivify (Rank 2) Brewmaster 37
			322510, -- Celestial Brew (Rank 2) Brewmaster 41
			322102, -- Expel Harm (Rank 2) Brewmaster 43
			343743, -- Purifying Brew (Rank 2) Brewmaster 47
			322960, -- Fortifying Brew (Rank 2) Brewmaster 48
			325095, -- Touch of Death (Rank 3) Brewmaster 52
			328682, -- Zen Meditation (Rank 2) Brewmaster 56
			322740, -- Invoke Niuzao, the Black Ox (Rank 2) Brewmaster 58
		}, -- [1]
		{
			262840, -- Rising Sun Kick (Rank 2) Mistweaver 26
			281231, -- Renewing Mist (Rank 2) Mistweaver 29
			231876, -- Thunder Focus Tea (Rank 2) Mistweaver 33
			231633, -- Essence Font (Rank 2) Mistweaver 34
			274586, -- Vivify (Rank 2) Mistweaver 37
			231605, -- Enveloping Mist (Rank 2) Mistweaver 38
			343744, -- Life Coccoon (Rank 2) Mistweaver 41
			322104, -- Expel Harm (Rank 2) Mistweaver 43
			325208, -- Fortifying Brew (Rank 2) Mistweaver 48
			344360, -- Touch of Death (Rank 3) Mistweaver 52
			325214, -- Expel Harm (Rank 3) Mistweaver 54
		}, -- [2]
		{
			261916, -- Blackout Kick (Rank 2) Windwalker 17
			261917, -- Blackout Kick (Rank 3) Windwalker 23
			262840, -- Rising Sun Kick (Rank 2) Windwalker 26
			343730, -- Spinning Crane Kick (Rank 2) Windwalker 33
			231602, -- Vivify (Rank 2) Windwalker 37
			343731, -- Disable (Rank 2) Windwalker 41
			322106, -- Expel Harm (Rank 2) Windwalker 43
			322719, -- Afterlife (Rank 2) Windwalker 46
			231627, -- Storm, Earth, and Fire (Rank 2) Windwalker 47
			325208, -- Fortifying Brew (Rank 2) Windwalker 48
			325215, -- Touch of Death (Rank 3) Windwalker 52
			344487, -- Flying Serpent Kick (Rank 2) Windwalker 54
			323999, -- Invoke Xuen, the White Tiger (Rank 2) Windwalker 58
		}, -- [3]
		[5] = {
			328669, -- Roll (Rank 2) Monk 9
			328670, -- Provoke (Rank 2) Monk 39
			322113, -- Touch of Death (Rank 2) Monk 44
			344359, -- Paralysis (Rank 2) Monk 56
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	PALADIN = {
		{
			272906, -- Holy Shock (Rank 2) Holy 18
			231644, -- Judgment (Rank 3) Holy 29
			231667, -- Crusader Strike (Rank 3) Holy 33
			231642, -- Beacon of Light (Rank 2) Holy 42
			327979, -- Avenging Wrath (Rank 3) Holy 48
		}, -- [1]
		{
			342348, -- Crusader Strike (Rank 2) Protection 11
			315867, -- Judgment (Rank 3) Protection 16
			344172, -- Consecration (Rank 2) Protection 18
			317907, -- Mastery: Divine Bulwark (Rank 2) Protection 19
			327980, -- Consecration (Rank 3) Protection 23
			231663, -- Judgment (Rank 4) Protection 29
			317854, -- Hammer of the Righteous (Rank 2) Protection 33
			315921, -- Word of Glory (Rank 2) Protection 34
			231665, -- Avenger's Shield (Rank 3) Protection 44
		}, -- [2]
		{
			342348, -- Crusader Strike (Rank 2) Retribution 11
			315867, -- Judgment (Rank 3) Retribution 16
			231663, -- Judgment (Rank 4) Retribution 29
			231667, -- Crusader Strike (Rank 3) Retribution 33
			327981, -- Blade of Justice (Rank 2) Retribution 34
			317912, -- Art of War (Rank 2) Retribution 48
		}, -- [3]
		[5] = {
			327977, -- Judgment (Rank 2) Paladin 8
			317872, -- Avenging Wrath (Rank 2) Paladin 43
			200327, -- Blessing of Sacrifice (Rank 2) Paladin 47
			317911, -- Divine Steed (Rank 2) Paladin 49
			317906, -- Retribution Aura (Rank 2) Paladin 56
			326730, -- Hammer of Wrath (Rank 2) Paladin 58
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	PRIEST = {
		{
			262861, -- Smite (Rank 2) Discipline 13
			231682, -- Mind Blast (Rank 2) Discipline 18
			343726, -- Shadowfiend (Rank 2) Discipline 32
			322115, -- Power Word: Radiance (Rank 2) Discipline 39
			285485, -- Focused Will (Rank 2) Discipline 43
			322112, -- Holy Nova (Rank 2) Discipline 47
		}, -- [1]
		{
			262861, -- Smite (Rank 2) Holy 13
			63733, -- Holy Words (Rank 2) Holy 26
			285485, -- Focused Will (Rank 2) Holy 43
			322112, -- Holy Nova (Rank 2) Holy 47
			319912, -- Prayer of Mending (Rank 2) Holy 48
		}, -- [2]
		{
			319899, -- Mind Blast (Rank 2) Shadow 13
			319904, -- Shadowfiend (Rank 2) Shadow 32
			231688, -- Void Bolt (Rank 2) Shadow 37
			319908, -- Void Eruption (Rank 2) Shadow 39
			322108, -- Dispersion (Rank 2) Shadow 44
			322110, -- Vampiric Embrace (Rank 2) Shadow 47
			322116, -- Vampiric Touch (Rank 2) Shadow 48
			342991, -- Shadow Mend (Rank 2) Shadow 56
		}, -- [3]
		[5] = {
			327821, -- Fade (Rank 2) Priest 17
			327820, -- Shadow Word: Pain (Rank 2) Priest 27
			322107, -- Shadow Word: Death (Rank 2) Priest 46
			327830, -- Mass Dispel (Rank 2) Priest 54
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	ROGUE = {
		{
			279877, -- Sinister Strike (Rank 2) Assassination 12
			319473, -- Mastery: Potent Assassin (Rank 2) Assassination 41
			319066, -- Wound Poison (Rank 2) Assassination 44
			231719, -- Garrote (Rank 2) Assassination 46
			330542, -- Improved Poisons (Rank 2) Assassination 52
			344362, -- Slice and Dice (Rank 2) Assassination 56
			319032, -- Shiv (Rank 2) Assassination 58
		}, -- [1]
		{
			279876, -- Sinister Strike (Rank 2) Outlaw 12
			35551, -- Combat Potency (Rank 2) Outlaw 43
			235484, -- Between the Eyes (Rank 2) Outlaw 44
			331851, -- Blade Flurry (Rank 2) Outlaw 52
			319600, -- Grappling Hook (Rank 2) Outlaw 56
			344363, -- Evasion (Rank 2) Outlaw 58
		}, -- [2]
		{
			328077, -- Symbols of Death (Rank 2) Subtlety 43
			245751, -- Sprint (Rank 3) Subtlety 43
			231716, -- Eviscerate (Rank 2) Subtlety 44
			319949, -- Backstab (Rank 2) Subtlety 46
			319951, -- Shuriken Storm (Rank 2) Subtlety 56
			319178, -- Shadow Vault (Rank 2) Subtlety 58
		}, -- [3]
		[5] = {
			231691, -- Sprint (Rank 2) Rogue 31
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	SHAMAN = {
		{
			231721, -- Lava Burst (Rank 2) Elemental 20
			231722, -- Chain Lightning (Rank 2) Elemental 43
			343190, -- Elemental Fury (Rank 2) Elemental 52
			343226, -- Fire Elemental Totem (Rank 2) Elemental 58
		}, -- [1]
		{
			334033, -- Lava Lash (Rank 2) Enhancement 22
			319930, -- Stormbringer (Rank 2) Enhancement 43
			334308, -- Chain Lightning (Rank 2) Enhancement 52
			343211, -- Windfury Totem (Rank 2) Enhancement 58
		}, -- [2]
		{
			231721, -- Lava Burst (Rank 2) Restoration 20
			231780, -- Chain Heal (Rank 2) Restoration 23
			231785, -- Tidal Waves (Rank 2) Restoration 27
			343182, -- Mana Tide Totem (Rank 2) Restoration 52
			343205, -- Healing Tide Totem (Rank 2) Restoration 58
		}, -- [3]
		[5] = {
			318044, -- Lightning Bolt (Rank 2) Shaman 6
			343196, -- Astral Shift (Rank 2) Shaman 54
			343198, -- Hex (Rank 2) Shaman 56
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	WARLOCK = {
		{
			317031, -- Corruption (Rank 2) Affliction 14
			231792, -- Agony (Rank 2) Affliction 28
			231791, -- Unstable Affliction (Rank 2) Affliction 43
			231811, -- Soulstone (Rank 2) Affliction 48
			334342, -- Corruption (Rank 3) Affliction 54
			334315, -- Unstable Affliction (Rank 3) Affliction 56
		}, -- [1]
		{
			231811, -- Soulstone (Rank 2) Demonology 48
			334727, -- Call Dreadstalkers (Rank 2) Demonology 54
			334591, -- Fel Firebolt (Rank 2) Demonology 56
			334585, -- Summon Demonic Tyrant (Rank 2) Demonology 58
		}, -- [2]
		{
			231793, -- Conflagrate (Rank 2) Destruction 23
			231811, -- Soulstone (Rank 2) Destruction 48
			335174, -- Havoc (Rank 2) Destruction 54
			335189, -- Rain of Fire (Rank 2) Destruction 56
			335175, -- Summon Infernal (Rank 2) Destruction 58
		}, -- [3]
		[5] = {
			317138, -- Unending Resolve (Rank 2) Warlock 39
			342914, -- Fear (Rank 2) Warlock 52
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
	WARRIOR = {
		{
			316405, -- Execute (Rank 2) Arms 13
			231830, -- Execute (Rank 3) Arms 18
			261901, -- Slam (Rank 2) Arms 20
			316440, -- Overpower (Rank 2) Arms 28
			316411, -- Colossus Smash (Rank 2) Arms 37
			316432, -- Sweeping Strikes (Rank 2) Arms 42
			261900, -- Mortal Strike (Rank 2) Arms 44
			316534, -- Slam (Rank 3) Arms 48
			316441, -- Overpower (Rank 3) Arms 49
			315948, -- Die by the Sword (Rank 2) Arms 52
			316433, -- Sweeping Strikes (Rank 3) Arms 58
		}, -- [1]
		{
			316402, -- Execute (Rank 2) Fury 13
			316403, -- Execute (Rank 3) Fury 18
			316424, -- Enrage (Rank 2) Fury 20
			316435, -- Whirlwind (Rank 2) Fury 22
			316452, -- Raging Blow (Rank 2) Fury 27
			316412, -- Rampage (Rank 2) Fury 28
			316474, -- Enraged Regeneration (Rank 2) Fury 32
			12950, -- Whirlwind (Rank 3) Fury 37
			316453, -- Raging Blow (Rank 3) Fury 42
			316519, -- Rampage (Rank 3) Fury 44
			316537, -- Bloodthirst (Rank 2) Fury 48
			316425, -- Enrage (Rank 3) Fury 49
			316828, -- Recklessness (Rank 2) Fury 52
			231827, -- Execute (Rank 4) Fury 58
		}, -- [2]
		{
			316405, -- Execute (Rank 2) Protection 13
			316523, -- Shield Slam (Rank 2) Protection 10
			231830, -- Execute (Rank 3) Protection 18
			231834, -- Shield Slam (Rank 3) Protection 28
			316778, -- Ignore Pain (Rank 2) Protection 29
			316414, -- Thunder Clap (Rank 2) Protection 37
			316790, -- Shield Slam (Rank 4) Protection 44
			316428, -- Vanguard (Rank 2) Protection 48
			316464, -- Demoralizing Shout (Rank 2) Protection 49
			316438, -- Avatar (Rank 2) Protection 52
			316834, -- Shield Wall (Rank 2) Protection 58
		}, -- [3]
		[5] = {
			319157, -- Charge (Rank 2) Warrior 8
			319158, -- Victory Rush (Rank 2) Warrior 11
			231847, -- Shield Block (Rank 2) Warrior 22
			316825, -- Rallying Cry (Rank 2) Warrior 56
		},
		["patch"] = "9.0.2",
		["build"] = "36165",
	},
}

local function ScanUpgrades()
	playerClass = playerClass or select(2, UnitClass('player'))
	local upgrades = CopyTable(spellUpgrades[playerClass][5] or {})
	local spec = GetSpecialization()

	if spec > 0 and spec < 5 then
		for _, spell in next, spellUpgrades[playerClass][spec] or {} do
			upgrades[#upgrades + 1] = spell
		end
	end

	local changed = false
	for _, id in next, upgrades do
		if IsPlayerSpell(id) then
			local name = GetSpellInfo(id)
			changed = FoundSpell(id, name, 'upgrade') or changed
		end
	end

	return changed
end

local function ScanCovenantAbilities()
	local changed = false

	local spells = {
		[313347] = GetSpellInfo(313347), -- Covenant Ability
		[326526] = GetSpellInfo(326526), -- Signature Ability
	}

	for id, name in next, spells do
		local newName, _, _, _, _, _, newID = GetSpellInfo(name)
		if newID ~= id then
			changed = FoundSpell(newID, newName, 'covenant') or changed
		end
	end

	return changed
end

local function ScanFlyout(flyoutId, bookType)
	local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutId)

	if not isKnown or numSlots < 1 then return end

	local changed = false
	for i = 1, numSlots do
		local _, id, isKnown, name = GetFlyoutSlotInfo(flyoutId, i)

		if isKnown then
			changed = FoundSpell(id, name, bookType) or changed
		end
	end

	return changed
end

local function ScanTalents()
	local changed = false
	local spec = GetActiveSpecGroup()
	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			local _, _, _, _, _, spellId, _, _, _, isKnown, isGrantedByAura = GetTalentInfo(tier, column, spec)
			if isKnown or isGrantedByAura then
				local name = GetSpellInfo(spellId)
				changed = FoundSpell(spellId, name, 'talent') or changed
			end
		end
	end

	return changed
end

local function ScanPvpTalents()
	local changed = false
	if C_PvP.IsWarModeDesired() then
		local selectedPvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
		for _, talentId in next, selectedPvpTalents do
			local _, name, _, _, _, spellId = GetPvpTalentInfoByID(talentId)
			if IsPlayerSpell(spellId) then
				changed = FoundSpell(spellId, name, 'pvp') or changed
			end
		end
	end
end

local function ScanSpellbook(bookType, numSpells, offset)
	local changed = false
	offset = offset or 0

	for i = offset + 1, offset + numSpells do
		local spellType, actionId = GetSpellBookItemInfo(i, bookType)
		if spellType == 'SPELL' then
			local name, _, spellId = GetSpellBookItemName(i, bookType)
			changed = FoundSpell(spellId, name, bookType) or changed

			local link = GetSpellLink(i, bookType)
			if link then
				local id, n = link:match('spell:(%d+):%d+\124h%[(.+)%]')
				id = tonumber(id)
				if id ~= spellId then
					-- TODO: check this
					-- print('Differing ids from link and spellbook', id, spellId)
					changed = FoundSpell(id, n, bookType) or changed
				end
			end
		elseif spellType == 'FLYOUT' then
			changed = ScanFlyout(actionId, bookType)
		elseif spellType == 'PETACTION' then
			local name, _, spellId = GetSpellBookItemName(i, bookType)
			changed = FoundSpell(spellId, name, bookType) or changed
		elseif not spellType or spellType == 'FUTURESPELL' then
			break
		end
	end

	return changed
end

local function ScanSpells(event)
	local changed = false
	ns.generation = ns.generation + 1

	for tab = 1, 3 do
		local _, _, offset, numSpells = GetSpellTabInfo(tab)
		changed = ScanSpellbook('spell', numSpells, offset) or changed
	end

	changed = ScanUpgrades() or changed

	local numPetSpells = HasPetSpells()
	if numPetSpells then
		changed = ScanSpellbook('pet', numPetSpells) or changed
	end

	local inCombat = InCombatLockdown()
	if not inCombat then
		changed = ScanTalents() or changed
	end

	changed = ScanPvpTalents() or changed
	changed = ScanCovenantAbilities() or changed

	local current = ns.generation
	for id, generation in next, ns.spells.lastSeen do
		if generation < current then
			local bookType = ns.spells.book[id]
			if supportedBookTypes[bookType] and (not inCombat or bookType ~= 'talent') then
				CleanUp(id)
				changed = true
			end
		end
	end

	if changed then
		lib.callbacks:Fire('LibSpellbook_Spells_Changed')
	end

	if event == 'PLAYER_ENTERING_WORLD' then
		lib:UnregisterEvent(event, ScanSpells)
	end
end

lib:RegisterEvent('PLAYER_ENTERING_WORLD', ScanSpells)
lib:RegisterEvent('PVP_TIMER_UPDATE', ScanSpells, true)
lib:RegisterEvent('SPELLS_CHANGED', ScanSpells)
