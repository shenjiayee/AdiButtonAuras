local _, ns = ...
ns = ns['__LibSpellbook-1.0']

local lib = ns.lib
if not lib then return end

local FoundSpell = ns.FoundSpell
local CleanUp    = ns.CleanUp

local azeriteSlots = {
	[_G.INVSLOT_HEAD]     = true,
	[_G.INVSLOT_SHOULDER] = true,
	[_G.INVSLOT_CHEST]    = true,
}

-- azeriteSpells[spellID] = '135' -- slots concatenated
local azeriteSpells = {}
local playerSpecID

local function RemoveSpell(slot, id)
	local spellRemoved = false

	for spell, slots in next, azeriteSpells do
		if not id or id == spell then
			slots = slots:gsub(slot, '')
			if slots == '' then
				azeriteSpells[spell] = nil
				CleanUp(spell)
				spellRemoved = true
			else
				azeriteSpells[spell] = slots
			end

			if id == spell then break end
		end
	end

	return spellRemoved
end

local function AddSpell(slot, id)
	local isNew = false
	local slots = azeriteSpells[id]

	if slots then
		if not slots:find(slot) then
			azeriteSpells[id] = slots .. slot
		end
	else
		azeriteSpells[id] = tostring(slot)
		isNew = FoundSpell(id, GetSpellInfo(id), 'azerite')
	end

	return isNew
end

local function UpdateActivePowers(itemLocation)
	local heartLocation = C_AzeriteItem.FindActiveAzeriteItem()

	-- the player has not unlocked Heart of Azeroth but has azerite items
	if not heartLocation then return false end

	local changed = false
	local azeriteLevel = C_AzeriteItem.GetPowerLevel(heartLocation)
	local tiers = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation)

	for tier, info in next, tiers do
		if tier < #tiers and info.unlockLevel <= azeriteLevel then
			for _, powerID in next, info.azeritePowerIDs do
				local spellID = C_AzeriteEmpoweredItem.GetPowerInfo(powerID).spellID
				local slot = itemLocation:GetEquipmentSlot()

				if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID)
						and C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(powerID, playerSpecID) then
					changed = AddSpell(slot, spellID) or changed
				else
					changed = RemoveSpell(slot, spellID) or changed
				end
			end
		end
	end

	return changed
end

local function ScanAzeriteItem(event, itemLocation)
	if not itemLocation:IsEquipmentSlot() then
		return false
	end

	local changed = UpdateActivePowers(itemLocation)

	if changed and event == 'AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED' then
		lib.callbacks:Fire('LibSpellbook_Spells_Changed')
	end

	return changed
end

local function ScanEquipmentSlot(event, slot, isEmpty, suppressAllChangedMessage)
	local changed = false

	if azeriteSlots[slot] then
		local itemLink = GetInventoryItemLink('player', slot)
		itemLink = itemLink and itemLink:match('item:%d+:+%d+:%d+:(.-)|h')
		if isEmpty or itemLink ~= azeriteSlots[slot] then
			azeriteSlots[slot] = itemLink or true
			changed = RemoveSpell(slot)
		end

		if not isEmpty then
			local itemLocation = ItemLocation:CreateFromEquipmentSlot(slot)
			local isAzeriteItem = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)
			if isAzeriteItem then
				changed = ScanAzeriteItem(event, itemLocation) or changed
			end
		end
	end

	if changed and not suppressAllChangedMessage then
		lib.callbacks:Fire('LibSpellbook_Spells_Changed')
	end

	return changed
end

local function ScanAzeriteSpells(event)
	if not playerSpecID or event == 'PLAYER_SPECIALIZATION_CHANGED' then
		playerSpecID = GetSpecializationInfo(GetSpecialization()) or 0
		if playerSpecID == 0 then return end
	end

	local changed = false
	for slot in next, azeriteSlots do
		local isEmpty = not GetInventoryItemID('player', slot)
		changed = ScanEquipmentSlot(event, slot, isEmpty, true) or changed
	end

	if changed then
		lib.callbacks:Fire('LibSpellbook_Spells_Changed')
	end

	if event == 'PLAYER_ENTERING_WORLD' then
		lib:UnregisterEvent(event, ScanAzeriteSpells)
	end
end

lib:RegisterEvent('AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED', ScanAzeriteItem)
lib:RegisterEvent('PLAYER_ENTERING_WORLD', ScanAzeriteSpells)
lib:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', ScanEquipmentSlot)
lib:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', ScanAzeriteSpells, true)
