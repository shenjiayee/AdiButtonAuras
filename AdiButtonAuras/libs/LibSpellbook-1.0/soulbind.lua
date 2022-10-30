local _, ns = ...
ns = ns['__LibSpellbook-1.0']

local lib = ns.lib
if not lib then return end

local FoundSpell = ns.FoundSpell
local CleanUp    = ns.CleanUp

local SoulbindNodeState = _G.Enum.SoulbindNodeState
local GetActiveSoulbindID = _G.C_Soulbinds.GetActiveSoulbindID
local GetConduitSpellID = _G.C_Soulbinds.GetConduitSpellID
local GetSpellInfo = _G.GetSpellInfo
local GetSoulbindData = _G.C_Soulbinds.GetSoulbindData

local function RemoveUnlearned()
	local changed = false
	local current = ns.generation
	local lastSeen = ns.spells.lastSeen

	for id in lib:IterateSpells('soulbind') do
		if current > lastSeen[id] then
			CleanUp(id)
			changed = true
		end
	end

	return changed
end

local function ScanSoulbindSpells(event)
	ns.generation = ns.generation + 1
	local changed = false;
	local data = GetSoulbindData(GetActiveSoulbindID())

	if data and data.tree then
		for _, node in next, data.tree.nodes or {} do
			if (node.state == SoulbindNodeState.Selected) then
				local id = node.spellID

				if node.conduitID ~= 0 then
					id = GetConduitSpellID(node.conduitID, node.conduitRank)
				end

				changed = id ~= 0 and FoundSpell(id, GetSpellInfo(id), 'soulbind') or changed
			end
		end
	end

	changed = RemoveUnlearned() or changed

	if changed then
		lib:UnregisterEvent('SPELLS_CHANGED', ScanSoulbindSpells)
		lib.callbacks:Fire('LibSpellbook_Spells_Changed')
	end
end

lib:RegisterEvent('SPELLS_CHANGED', ScanSoulbindSpells)
lib:RegisterEvent('SOULBIND_FORGE_INTERACTION_ENDED', ScanSoulbindSpells)
