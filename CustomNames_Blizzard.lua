local lib = LibStub("CustomNames")
local tracked = setmetatable({}, { __mode = "k" })
local hooked = {}
local callbackOwner = {}
local npcNames = lib.GetCharList()

local function Accessible(value)
    return not (issecretvalue and issecretvalue(value))
        and not (canaccessvalue and not canaccessvalue(value))
end

local function Alias(unit)
    if not Accessible(unit) or type(unit) ~= "string" or not UnitExists(unit) then return end
    local name, realm = UnitName(unit)
    if not Accessible(name) or not Accessible(realm) or not name then return end
    local player = UnitIsPlayer(unit)
    if not Accessible(player) then return end
    local custom
    if player then
        custom = lib.UnitName(unit)
    else
        -- NPC names are stored without a realm by CustomNames.Set(unit, alias).
        custom = npcNames[name]
    end
    if Accessible(custom) and type(custom) == "string" and custom ~= name then return custom end
end

local function Apply(text, state)
    if state.writing then return end
    local unit = state.frame.displayedUnit
    if not Accessible(unit) then return end
    unit = unit or state.frame.unit or state.unit
    if not Accessible(unit) then return end
    local custom = Alias(unit)
    state.writing = true
    text:SetText(custom or state.original)
    state.writing = false
end

local function Track(frame, unit)
    if not frame or (frame.IsForbidden and frame:IsForbidden()) then return end
    local text = frame.name or frame.Name
    if not text and frame.GetName then
        local name = frame:GetName()
        if Accessible(name) and type(name) == "string" then
            text = _G[name .. "Name"] or _G[name .. "TextureFrameName"]
            if name == "PlayerFrame" then text = text or _G.PlayerName end
        end
    end
    if not text or not text.SetText or not text.GetText then return end
    local state = tracked[text]
    if not state then
        state = { frame = frame, unit = unit, original = text:GetText() }
        tracked[text] = state
        hooksecurefunc(text, "SetText", function(self, value)
            if state.writing then return end
            state.original = value
            Apply(self, state)
        end)
        if text.SetFormattedText then
            hooksecurefunc(text, "SetFormattedText", function(self)
                if state.writing then return end
                state.original = self:GetText()
                Apply(self, state)
            end)
        end
    end
    state.frame, state.unit = frame, unit
    Apply(text, state)
end

local function Supported(frame)
    if not frame or (frame.IsForbidden and frame:IsForbidden()) then return false end
    local name = frame.GetName and frame:GetName()
    if not Accessible(name) or type(name) ~= "string" then return false end
    return name == "PlayerFrame" or name == "PetFrame" or name == "TargetFrame"
        or name == "FocusFrame" or name == "TargetFrameToT" or name == "FocusFrameToT"
        or name:match("^PartyMemberFrame%d") or name:match("^PartyFrameMemberFrame%d")
        or name:match("^CompactPartyFrameMember%d") or name:match("^CompactRaidFrame%d")
        or name:match("^CompactRaidGroup%dMember%d") or name:match("^Boss%dTargetFrame")
        or name:match("^ArenaEnemyFrame%d") or name:match("^ArenaEnemyMatchFrame%d")
        or name:match("^ArenaEnemyPrepFrame%d")
end

local function OnNameUpdate(frame)
    if Supported(frame) then Track(frame) end
end

local function Discover()
    for _, name in ipairs({ "PlayerFrame", "PetFrame", "TargetFrame", "FocusFrame", "TargetFrameToT", "FocusFrameToT" }) do
        Track(_G[name])
    end
    for i = 1, 5 do
        Track(_G["PartyMemberFrame" .. i], "party" .. i)
        Track(_G["PartyMemberFrame" .. i .. "PetFrame"], "partypet" .. i)
        Track(_G["Boss" .. i .. "TargetFrame"], "boss" .. i)
        Track(_G["ArenaEnemyFrame" .. i], "arena" .. i)
        Track(_G["ArenaEnemyFrame" .. i .. "PetFrame"], "arenapet" .. i)
        Track(_G["ArenaEnemyMatchFrame" .. i], "arena" .. i)
        if PartyFrame then
            local member = PartyFrame["MemberFrame" .. i]
            Track(member, "party" .. i)
            if member then Track(member.PetFrame, "partypet" .. i) end
        end
        Track(_G["CompactPartyFrameMember" .. i], "party" .. i)
    end
    for i = 1, 40 do Track(_G["CompactRaidFrame" .. i]) end
    for group = 1, 8 do
        for member = 1, 5 do Track(_G["CompactRaidGroup" .. group .. "Member" .. member]) end
    end
    for _, name in ipairs({ "UnitFrame_Update", "UnitFrame_UpdateName", "CompactUnitFrame_UpdateName" }) do
        if not hooked[name] and type(_G[name]) == "function" then
            hooksecurefunc(name, OnNameUpdate)
            hooked[name] = true
        end
    end
end

local function Refresh()
    npcNames = lib.GetCharList()
    Discover()
    for text, state in pairs(tracked) do Apply(text, state) end
end

for _, event in ipairs({ "Name_Added", "Name_Update", "Name_Removed" }) do
    lib.RegisterCallback(callbackOwner, event, Refresh)
end

local events = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "ADDON_LOADED", "GROUP_ROSTER_UPDATE", "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "UNIT_PET", "UNIT_NAME_UPDATE", "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "ARENA_OPPONENT_UPDATE", "PLAYER_REGEN_ENABLED" }) do
    -- Some event names do not exist on older client branches.
    pcall(events.RegisterEvent, events, event)
end
events:SetScript("OnEvent", function() Discover() end)
Discover()
