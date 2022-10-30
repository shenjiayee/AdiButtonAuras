local _, ns = ...
ns['__LibSpellbook-1.0'] = {}
ns = ns['__LibSpellbook-1.0']

local MAJOR, MINOR = 'LibSpellbook-1.0', 28
assert(LibStub, MAJOR .. ' requires LibStub.')

local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

ns.lib = lib

-- TODO: expose spells through the lib object?
local spells = {
	book     = {}, -- spellId = bookType
	byId     = {}, -- spellId = spellName
	byName   = {}, -- spellName = { id1 = true, id2 = true, ... }
	lastSeen = {}, -- spellId = generation
}

local book, byId, byName, lastSeen = spells.book, spells.byId, spells.byName, spells.lastSeen
ns.spells = spells

local event_meta = {
	__call = function(handlers, ...)
		for _, handler in next, handlers do
			handler(...)
		end
	end
}

lib.callbacks = lib.callbacks or LibStub('CallbackHandler-1.0'):New(lib)
if lib.events then
	lib.events:UnregisterAllEvents()

	for event in next, lib.events do
		if event == event:upper() then
			lib.events[event] = nil
		end
	end
else
	lib.events = CreateFrame('Frame')
	lib.events:SetScript('OnEvent', function(self, event, ...)
		self[event](event, ...)
	end)
end

-- incremented on every spells scan
ns.generation = 0

--- Register an event handler.
-- @function LibSpellbook:RegisterEvent
-- @param  string    the event for which the handler is to be registered
-- @param  function  the event handler
-- @param  boolean   indicates if the event should be registered for the player only
function lib:RegisterEvent(event, handler, isUnitEvent)
	if type(handler) ~= 'function' then
		error(('Attempted to register event [%s] with a non-function handler.'):format(event))
	end

	local events = self.events
	local current = events[event]

	if not current then
		events[event] = handler
	else
		if type(current) == 'function' then
			if current ~= handler then
				events[event] = setmetatable({current, handler}, event_meta)
			end
		else
			for _, func in next, current do
				if func == handler then return end
			end
			current[#current + 1] = handler
		end
	end

	local isRegistered, unit = events:IsEventRegistered(event)

	if not isRegistered or not isUnitEvent and unit then
		if isUnitEvent then
			events:RegisterUnitEvent(event, 'player')
		else
			events:RegisterEvent(event)
		end
	end
end

--- Unregister an event handler.
-- @function LibSpellbook:UnregisterEvent
-- @param  string    the event for which the handler is to be unregistered
-- @param  function  the event handler to be unregistered
function lib:UnregisterEvent(event, handler)
	if not handler then return end

	local current = self.events[event]
	local cleanUp = false

	if (type(current) == 'table') then
		for i, func in next, current do
			if func == handler then
				current[i] = nil
				break
			end
		end
		if not next(current) then
			cleanUp = true
		end
	end

	if cleanUp or current == handler then
		self.events:UnregisterEvent(event)
		self.events[event] = nil
	end
end

local function Resolve(spell)
	local type = type(spell)
	if type == 'number' then
		return spell
	elseif type == 'string' then
		local ids = byName[spell]
		if ids then
			return next(ids)
		else
			return tonumber(spell:match('spell:(%d+)'))
		end
	end
end

--- Return all associated spell identifiers.
-- @function LibSpellbook:GetAllIds
-- @param   string|number  a spell name, link or identifier
-- @return  table          a table of associated spell identifiers
function lib:GetAllIds(spell)
	local id = Resolve(spell)
	local name = id and byId[id]
	return name and byName[name]
end

--- Return the associated spell type.
-- @function LibSpellbook:GetBookType
-- @param   string|number  a spell name, link or identifier
-- @return  ?string        the associated spell type
function lib:GetBookType(spell)
	local id = Resolve(spell)
	return id and book[id]
end

--- Return whether spells have already been scanned
-- @function LibSpellbook:HasSpells
-- @return  boolean
function lib:HasSpells()
	return next(byId) and ns.generation > 0
end

--- Return whether the spell is known to the player or their pet.
-- If `bookType` is specified, it has to match it.
-- @function LibSpellbook:IsKnown
-- @param   string|number  a spell name, link or identifier
-- @param   ?string        a spell type
-- @return  ?boolean
function lib:IsKnown(spell, bookType)
	local id = Resolve(spell)
	if id and byId[id] then
		return not bookType or bookType == book[id]
	end
end

local function iterator(bookType, id)
	local name
	repeat
		id, name = next(byId, id)
		if id and book[id] == bookType then
			return id, name
		end
	until not id
end

--- Iterate over all spells.
-- @function LibSpellbook:IterateSpells
-- @param   ?string   the spell type over which to iterate
-- @return  iterator  returns a spell identifier and name on every iteration
-- @usage
--   for id, name in LibSpellbook:IterateSpells() do
--     -- do something
--   end
function lib:IterateSpells(bookType)
	if bookType then
		return iterator, bookType
	end

	return next, byId
end

function ns.FoundSpell(id, name, bookType)
	if not (id and name) then return end

	local isNew = not lastSeen[id]
	if byName[name] then
		byName[name][id] = true
	else
		byName[name] = { [id] = true }
	end
	byId[id] = name
	book[id] = bookType
	lastSeen[id] = ns.generation

	if isNew then
		lib.callbacks:Fire('LibSpellbook_Spell_Added', id, bookType, name)
	end

	return isNew
end

function ns.CleanUp(id)
	local name = byId[id]
	local bookType = book[id]
	byName[name][id] = nil
	if not next(byName[name]) then
		byName[name] = nil
	end
	byId[id] = nil
	book[id] = nil
	lastSeen[id] = nil

	lib.callbacks:Fire('LibSpellbook_Spell_Removed', id, bookType, name)
end
